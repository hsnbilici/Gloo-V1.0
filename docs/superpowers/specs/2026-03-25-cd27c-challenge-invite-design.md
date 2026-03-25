# CD.27c — Challenge / Invite System Design Spec

**Tarih:** 2026-03-25
**Durum:** Onaylandi
**Bagimliliklari:** CD.27a (Arkadas sistemi), CD.27b (Profil sayfasi), PvP Duel altyapisi

---

## 1. Ozet

Hibrit challenge sistemi: **Asenkron Skor Battle** (ana ozellik) + **Senkron Friend Duel** (bonus). Mutual friends arasi uygulama ici challenge + deep link ile disariya paylasim. 24 saat sure siniri. Opsiyonel Jel Ozu bahis mekanizmasi.

### Kararlar

| Karar | Secim |
|---|---|
| Kapsam | Hibrit (asenkron + senkron) |
| Desteklenen modlar | Classic, TimeTrial, ColorChef (Zen haric) |
| Sure | 24 saat |
| Hedef kitle | Mutual friends + deep link istisnasi |
| Odul | Sabit odul + opsiyonel bahis (10/25/50) |
| Gunluk limit | Free: 5, Gloo+: 20 |
| Seed mekanizmasi | Gonderici once oynar, skor gizli, reveal animasyonu |

---

## 2. Veri Modeli & Backend

### 2.1 `challenges` Tablosu (Supabase)

```sql
CREATE TABLE challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES profiles(id),
  recipient_id UUID REFERENCES profiles(id),       -- NULL = deep link (henuz claim edilmemis)
  mode TEXT NOT NULL,                               -- 'classic', 'colorChef', 'timeTrial'
  challenge_type TEXT NOT NULL DEFAULT 'score_battle', -- 'score_battle' | 'live_duel'
  seed INTEGER NOT NULL,
  wager INTEGER NOT NULL DEFAULT 0,                 -- 0 = sabit odul, >0 = bahis miktari
  sender_score INTEGER,                             -- gonderici oynadiktan sonra set edilir
  recipient_score INTEGER,                          -- alici oynadiktan sonra set edilir
  status TEXT NOT NULL DEFAULT 'pending',            -- pending, active, completed, expired, declined, cancelled
  expires_at TIMESTAMPTZ NOT NULL,                  -- created_at + 24h
  created_at TIMESTAMPTZ DEFAULT now(),
  accepted_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

-- RLS: salt okunur — tum yazmalar Edge Function uzerinden (service_role)
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY challenges_select ON challenges FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

-- Seed gizleme: alici kabul etmeden seed'i goremez
CREATE VIEW challenges_safe AS
  SELECT
    id, sender_id, recipient_id, mode, challenge_type,
    CASE
      WHEN auth.uid() = sender_id THEN seed
      WHEN status IN ('active', 'completed') THEN seed
      ELSE NULL
    END AS seed,
    wager,
    CASE
      WHEN auth.uid() = sender_id THEN sender_score
      WHEN status = 'completed' THEN sender_score
      ELSE NULL
    END AS sender_score,
    recipient_score, status,
    expires_at, created_at, accepted_at, completed_at
  FROM challenges;

-- INSERT/UPDATE/DELETE yok — tum mutasyonlar Edge Function'lar uzerinden yapilir
-- Bu sayede wager escrow, skor dogrulama ve durum gecisleri server-side zorunlu olur

-- Indeksler
CREATE INDEX idx_challenges_recipient_status ON challenges(recipient_id, status);
CREATE INDEX idx_challenges_sender_status ON challenges(sender_id, status);
CREATE INDEX idx_challenges_sender_daily ON challenges(sender_id, created_at);
CREATE INDEX idx_challenges_expires_at ON challenges(expires_at) WHERE status IN ('pending', 'active');
```

### 2.2 Server-Side Balance Ledger

Wager escrow icin `balances` tablosu (mevcut client-side CurrencyManager'a ek olarak server-authoritative):

```sql
CREATE TABLE balances (
  user_id UUID PRIMARY KEY REFERENCES profiles(id),
  gel_ozu INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

**Migration stratejisi:**
1. `create-challenge` EF ilk wager denemesinde `balances` row yoksa UPSERT ile olusturur (client'in bildirdigi bakiyeyi kabul eder — tek seferlik).
2. Row olusturulduktan sonra `balances` tablosu otorite olur. Client bakiyesi ile uyumsuzluk olursa server kazanir.
3. Opsiyonel `sync-balance` EF: client app acilisinda cagirir, server bakiyesini doner. Client `CurrencyManager`'i gunceller.
4. Multi-device: server-authoritative — her cihaz acilista `sync-balance` ile guncel bakiyeyi alir.

Client `CurrencyManager` hala yerel state tutar (hizli UI gosterim), ama wager islemleri `balances` tablosundan dogrulanir.

### 2.3 Edge Functions (Server-Authoritative Mutasyonlar)

Tum challenge mutasyonlari Edge Function uzerinden yapilir. Client dogrudan INSERT/UPDATE yapamaz.

**`create-challenge`:**
1. Gunluk limit kontrolu (free: 5, gloo+: 20)
2. Wager > 0 ise: `balances` tablosundan bakiye kontrolu + atomik kesim
3. Seed server-side generate edilir
4. Challenge row INSERT + `sender_score` ayni islemde set edilir (gonderici zaten oynamis)
5. Push notification: aliciya bildirim (recipient_id varsa)
6. Return: challenge id + guncellenmis bakiye
7. Rate limit: 10/dk/user

**`accept-challenge`:**
1. Status = 'pending' kontrolu, auth.uid() = recipient_id
2. Wager > 0 ise: alici bakiye kontrolu + atomik kesim
3. Status → 'active', accepted_at set
4. Return: challenge (seed dahil — bu noktada acilir)
5. Rate limit: 10/dk/user

**`decline-challenge`:**
1. Status = 'pending' kontrolu, auth.uid() = recipient_id
2. Wager > 0 ise: gonderici bakiye iade
3. Status → 'declined'

**`cancel-challenge`:**
1. auth.uid() = sender_id, status = 'pending' kontrolu
2. Wager > 0 ise: gonderici bakiye iade
3. Status → 'cancelled'

**`submit-challenge-score`:**
1. Sadece recipient kullanir (sender skoru `create-challenge`'da set edilir)
2. auth.uid() = recipient_id, recipient_score NULL, status = 'active' kontrolu
3. Skor set edilir
4. Kazanan belirlenir, oduller dagitilir (`balances` atomik guncelleme), status → 'completed'
5. Return: ChallengeResult (her iki skor + odul + outcome)

**`claim-deep-link-challenge`:**
1. recipient_id NULL kontrolu
2. Expire kontrolu
3. recipient_id set edilir, status → 'active' (deep link'te wager yok)
4. Return: challenge (seed dahil)

**`expire-challenges`** (pg_cron, saatlik):
1. `status IN ('pending', 'active') AND expires_at < now()` → `status = 'expired'`
2. Wager iade: sender ve/veya recipient bakiyelerine atomik geri yukleme
3. Sender'a 5 Jel Ozu sabit odul (expire kazanci)

### 2.4 Status Akisi

```
pending    → Gonderici skoru yuklendi, alici henuz kabul etmedi
active     → Alici kabul etti (bahis varsa her iki taraftan kesildi)
completed  → Alici da oynadi, sonuclar belli
expired    → 24h doldu, alici oynamadi → gonderici kazanir
declined   → Alici reddetti (bahis iade)
cancelled  → Gonderici iptal etti (bahis iade, sadece pending'den)
```

### 2.5 Odul Yapisi

| Durum | Kazanan | Kaybeden | Berabere |
|---|---|---|---|
| Sabit odul (wager=0) | 15 Jel Ozu | 5 Jel Ozu | 10 Jel Ozu |
| Bahis (wager>0) | wager * 2 | 0 (bahis kaybedildi) | wager iade + 10 |
| Expired | Gonderici: 5 + bahis iade | — | — |

Gloo+ bonus tum odullere uygulanir (%50).

### 2.6 Gunluk Limit

`create-challenge` Edge Function icinde server-side zorunlu kontrol:
```sql
SELECT COUNT(*) FROM challenges
WHERE sender_id = $1
  AND created_at >= CURRENT_DATE
  AND created_at < CURRENT_DATE + INTERVAL '1 day';
```
Free: 5/gun, Gloo+: 20/gun. Client tarafinda da pre-check (UX icin), ama otorite server'da.

---

## 3. Dart Veri Katmani

### 3.1 Model: `Challenge`

```dart
class Challenge {
  final String id;
  final String senderId;
  final String? recipientId;
  final String senderUsername;
  final String? recipientUsername;
  final GameMode mode;
  final ChallengeType type;
  final int? seed;                   // NULL = alici henuz kabul etmedi (server gizliyor)
  final int wager;                   // 0 = sabit odul
  final int? senderScore;
  final int? recipientScore;
  final ChallengeStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;
}

enum ChallengeType { scoreBattle, liveDuel }
enum ChallengeStatus { pending, active, completed, expired, declined, cancelled }
enum ChallengeOutcome { win, loss, draw }
```

### 3.2 `ChallengeRepository` (`data/remote/challenge_repository.dart`)

Tum mutasyonlar Edge Function cagrilarindan ibarettir. Dogrudan tablo INSERT/UPDATE yok.

```
// Mutasyonlar — tumu Edge Function cagrisi
createChallenge(recipientId?, mode, type, senderScore, wager) → Future<Challenge?>
  // create-challenge EF: seed server generate, sender_score ayni anda set
acceptChallenge(challengeId) → Future<Challenge?>
  // accept-challenge EF: seed bu noktada doner
declineChallenge(challengeId) → Future<void>
  // decline-challenge EF
cancelChallenge(challengeId) → Future<void>
  // cancel-challenge EF (sadece sender, pending iken)
submitRecipientScore(challengeId, score) → Future<ChallengeResult?>
  // submit-challenge-score EF (sadece recipient kullanir)
claimDeepLinkChallenge(challengeId) → Future<Challenge?>
  // claim-deep-link-challenge EF

// Read-only queries (challenges_safe view uzerinden — skor/seed gizleme aktif)
getPendingChallenges() → Future<List<Challenge>>
getSentChallenges() → Future<List<Challenge>>
getChallengeHistory(limit) → Future<List<Challenge>>
getDailyChallengeCount() → Future<int>
```

Tum metodlarda `isConfigured` guard + try-catch + `_retry()` mevcut pattern'e uygun.

### 3.3 `ChallengeResult`

```dart
class ChallengeResult {
  final ChallengeOutcome outcome;   // win, loss, draw
  final int senderScore;
  final int recipientScore;
  final int gelReward;              // pozitif = kazanc, negatif = kayip (bahis)
}
```

### 3.4 Bahis Akisi (Tumu Server-Side)

1. `create-challenge` EF: gonderici bakiye kontrolu + atomik kesim (`balances` tablosu)
2. `accept-challenge` EF: alici bakiye kontrolu + atomik kesim
3. `submit-challenge-score` EF: kazanan belirlenir, oduller dagitilir, bakiyeler guncellenir
4. `decline-challenge` / `cancel-challenge` / `expire-challenges`: bahisler atomik iade
5. Client `CurrencyManager`: EF response'undan donen yeni bakiyeyi sync eder

---

## 4. Provider & State Management

### 4.1 `challengeProvider`

```dart
class ChallengeState {
  final List<Challenge> received;      // pending + active (alinan)
  final List<Challenge> sent;          // pending + active (gonderilen)
  final int pendingCount;              // badge sayisi
  final int dailySentCount;            // gunluk limit takibi
}
```

`ChallengeNotifier` (StateNotifierProvider):
- `loadChallenges()` — init: received + sent cek
- `sendChallenge(recipientId, mode, type, wager, seed, score)`
- `acceptChallenge(challengeId)`
- `declineChallenge(challengeId)`
- `submitScore(challengeId, score)`
- `claimDeepLink(challengeId)`
- `refresh()` — pull-to-refresh

### 4.2 Challenge Game Entegrasyonu (Route Params)

Mevcut duel pattern'i ile uyumlu — global state yerine rota parametreleri:

```
/game/challenge?challengeId=X&mode=classic&seed=Y
```

Router'da `/game/challenge` rotasi `/game/duel`'dan ONCE tanimlanir (spesifik > genel).

GameScreen challenge modunda:
1. `challengeId`, `seed` rota parametrelerinden alinir
2. Oyun biter → `game_callbacks.dart`'ta `onGameOver` icinde `submitChallengeScore` cagirilir
3. Sonuc: sender icin → "Challenge gonderildi" onay, recipient icin → skor reveal overlay

### 4.3 Badge Entegrasyonu

```dart
final pendingChallengeCountProvider = Provider<int>((ref) {
  return ref.watch(challengeProvider).pendingCount;
});
```

### 4.4 Senkron Duel Entegrasyonu

**Faz 2 — asenkron challenge stabil olduktan sonra implemente edilecek.**

Detayli akis:
1. Sender "Canli Duel" secip "Gonder & Bekle" tiklar
2. `create-challenge` EF: `challenge_type = 'liveDuel'`, `pvp_matches` row olusturur, seed atar
3. Recipient'a push notification (`syncDuelInvite`)
4. Sender bekleme ekraninda: Supabase Realtime `challenge:{challengeId}` kanalini dinler
5. Recipient kabul ederse: `accept-challenge` EF → status 'active', pvp_match aktif
6. Her iki taraf `/game/duel?matchId=X&seed=Y` rotasina yonlendirilir
7. Mevcut `GameDuelController` + `PvpRealtimeService` aynen kullanilir
8. **ELO etkisi yok** — friend duel'lar ELO'yu etkilemez (casual)
9. **Timeout:** Sender 5dk bekler. Kabul edilmezse → cancel-challenge otomatik cagirilir, "Skor Battle'a donustur?" onerisi
10. **Sender offline:** Recipient kabul ettiyse, sender'in realtime subscription'i reconnect'te match'i yakalar. 2dk iceinde baslanamazsa match expire olur.

---

## 5. UI & Routing

### 5.1 Yeni Rotalar

```
/challenges              → FriendsScreen challenges tab'ina yonlendirir
/challenge/:challengeId  → Deep link → FriendsScreen + accept dialog
```

Router'da `/challenge/:challengeId` spesifik rota `/challenges`'tan ONCE tanimlanmali.

### 5.2 HomeScreen — `_ActiveChallengeBanner`

WeeklyRivalCard pattern ile:
- Pending challenge varsa: "{username} seni {mode}'da challenge etti!"
- Wager > 0 ise amber badge: "{wager} Jel Ozu"
- Tap → FriendsScreen challenges tab
- Birden fazla: "{count} bekleyen challenge" + chevron
- 0 pending → widget gizli

### 5.3 FriendsScreen — Tab Refactor + Challenges Tab

**Onkosul:** Mevcut FriendsScreen tek bir ListView'dir, tab yapisi yoktur. Once TabBar + TabBarView refactor'u yapilmali:
- Tab 1: Kod & Arama (mevcut ust bolum)
- Tab 2: Arkadaslar & Takipciler (mevcut alt bolum)
- Tab 3: **Challenges** (yeni)

Challenges tab icerigi:

**Alinan bolumu:**
- Challenge kartlari: gonderici username, mod ikonu, kalan sure countdown, wager badge
- Buton cifti: Kabul Et / Reddet
- Kabul → bahis onay dialog (wager > 0 ise) → oyun ekranina yonlendir

**Gonderilen bolumu:**
- Challenge kartlari: alici, mod, durum chip (bekliyor/kabul edildi/tamamlandi)
- Tamamlanan challenge'larda skor karsilastirma: sender vs recipient, kazanan vurgulu

### 5.4 Challenge Gonderme Akisi

**Erisim noktalari:**
1. ProfileScreen → "Challenge Gonder" butonu (mutual friend ise)
2. FriendTile → trailing icon
3. WeeklyRivalCard → "Challenge" butonu
4. Share → deep link ile disariya
5. Game Over overlay → "Challenge" ikonu (gamesPlayed >= 3 ise)

**`SendChallengeSheet`** (bottom sheet):
1. Mod secimi: Classic / TimeTrial / ColorChef (chip row)
2. Tip secimi: Skor Battle | Canli Duel toggle (Canli Duel Faz 2'de aktif, su an disabled)
3. Bahis secimi: Yok / 10 / 25 / 50 Jel Ozu (chip row)
4. "Oyna & Gonder" butonu → GameScreen acilir, oyun bitince challenge olusturulur
   - Senkron secildiyse: "Gonder & Bekle" → push notification + 5dk bekleme

### 5.5 Skor Reveal Overlay

Challenge tamamlandiginda (alici oynadiktan sonra):
- Dramatik reveal: once alici skoru, sonra gonderici skoru counter animasyonla acilir
- Kazanan: confetti + altin border
- Wager sonucu: "+{amount} Jel Ozu" veya "-{amount} Jel Ozu"
- Butonlar: "Rematch" / "Kapat"
- **Rematch:** Roller tersine doner (eski alici yeni gonderici olur). Ayni mod, yeni seed, ayni wager. Tek tikla yeni challenge olusturur.

**Offline handling:** Oyun bittiginde network yoksa skor `SharedPreferences`'a `pending_challenge_score_{challengeId}` olarak kaydedilir. Sonraki app acilisinda `ChallengeRepository` pending skor kontrolu yapip submit eder (mevcut `_pendingVerification` IAP pattern'i ile ayni).

---

## 6. Deep Link, Share & Viral Loop

### 6.1 Deep Link

```
https://gloogame.com/challenge/{challengeId}
```
- Uygulama yukluyse → `/challenge/:challengeId` rotasi → accept dialog
- Uygulama yuklu degilse → store yonlendirme (deferred deep link)

### 6.2 ShareManager Entegrasyonu

```dart
shareChallenge(Challenge challenge, AppStrings l) → void
```
- Mesaj: "{username} seni Gloo'da {mode} challenge'a davet ediyor! {wager > 0 ? 'Bahis: {wager} Jel Ozu' : ''}"
- Link: `https://gloogame.com/challenge/{challengeId}`
- Hashtag: `#GlooChallenge`

### 6.3 Deep Link Challenge (non-mutual)

Mutual friend olmayan birine share link ile challenge gonderilebilir:
1. Gonderici oynar → challenge olusturulur (`recipient_id: null`)
2. Share link paylasilir
3. Alici linki acar → `claimDeepLinkChallenge(challengeId)` → `recipient_id` set edilir
4. Deep link challenge'larda bahis yok (guvenlik)
5. Zaten claim edilmis veya expire olduysa hata mesaji

### 6.4 Viral Dongu

```
Oyun biter → "Arkadasini Challenge Et" butonu (Game Over overlay)
  → SendChallengeSheet (mutual friends listesi)
  → veya "Link ile Paylas" (deep link challenge)
```

Game Over overlay'ine eklenen challenge ikonu: sadece `gamesPlayed >= 3` ise gosterilir.

### 6.5 Expire Yonetimi

- pg_cron (saatlik): `status='pending' AND expires_at < now()` → `status='expired'`
- Expire: gonderici bahis iade + 5 Jel Ozu sabit odul
- Push notification: expire'dan 1 saat once hatirlatma

---

## 7. Push Notification

`NotificationType` enum'a eklenenler (enum SONUNA, index kaymasini onlemek icin):
- `challengeReceived` — "{username} seni {mode}'da challenge etti!"
- `challengeExpiring` — "Challenge'in 1 saat icinde sona eriyor!"
- `syncDuelInvite` — "{username} simdi duel istiyor!"

**Notification ID stratejisi:** Mevcut singleton notification'lar (streak, daily, comeback) enum index kullanir. Challenge notification'lari ise per-challenge unique ID gerektirir (ayni anda birden fazla olabilir). Challenge UUID'nin hashCode'u notification ID olarak kullanilir:
```dart
int _challengeNotifId(String challengeId) => challengeId.hashCode.abs() % 1000000 + 1000;
```
`+1000` offset mevcut enum index'lerle (0-5) cakismayi onler.

Mevcut `FirebaseNotificationService` + `StubNotificationService` (web) pattern'i korunur.

---

## 8. l10n & Erisilebilirlik

### 8.1 Yeni l10n String'leri (~30 string, 12 dil)

Kategoriler:
- Challenge gonderme: `challengeSend`, `challengeModePick`, `challengeWagerPick`, `challengePlayAndSend`, `challengeSendWait`
- Challenge alma: `challengeReceived`, `challengeAccept`, `challengeDecline`, `challengeWagerConfirm`
- Durum: `challengePending`, `challengeActive`, `challengeCompleted`, `challengeExpired`, `challengeDeclined`
- Sonuc: `challengeYouWon`, `challengeYouLost`, `challengeDraw`, `challengeRevealScore`, `challengeRematch`
- Banner: `challengeBannerSingle`, `challengeBannerMultiple`
- Limit: `challengeDailyLimitReached`, `challengeDailyLimitGlooPlus`
- Notification: `challengeNotifReceived`, `challengeNotifExpiring`, `challengeSyncDuelInvite`
- Deep link: `challengeClaimSuccess`, `challengeClaimExpired`, `challengeClaimAlreadyClaimed`
- Bahis: `challengeWagerNone`, `challengeWager10`, `challengeWager25`, `challengeWager50`

### 8.2 Erisilebilirlik

- Tum challenge kartlarina `Semantics(label:)` — mod, gonderici, kalan sure, wager bilgisi
- Accept/Decline butonlari `Semantics(button: true, label:)`
- Skor reveal animasyonu: `SemanticsService.sendAnnouncement` ile sonuc duyurusu
- Banner: `Semantics(liveRegion: true)` ile ekran okuyucuya otomatik bildirim
- Countdown timer: `Semantics(label: l.challengeTimeRemaining(hours, minutes))`
- Reduce motion: reveal animasyonu skip, direkt sonuc goster

### 8.3 Renk Sabitleri

`color_constants.dart`'a eklenenler:
- `kChallengePrimary` — challenge kart accent (yeni ton)
- Bahis badge: mevcut `kAmber` kullanilir (alias olusturulmaz)
- `kChallengeWin` / `kChallengeLose` — sonuc renkleri (kGreen / kMuted)

Light tema karsiliklari `color_constants_light.dart`'ta. WCAG AA kontrast saglanacak.

---

## 9. Dosya Yapisi (Yeni/Degisecek)

### Yeni dosyalar:
```
lib/data/remote/challenge_repository.dart
lib/providers/challenge_provider.dart
lib/features/friends/challenge_tab.dart
lib/features/friends/challenge_widgets.dart
lib/features/friends/send_challenge_sheet.dart
lib/features/shared/challenge_reveal_overlay.dart
supabase/migrations/YYYYMMDD_create_challenges.sql
supabase/migrations/YYYYMMDD_create_balances.sql
supabase/functions/create-challenge/index.ts
supabase/functions/accept-challenge/index.ts
supabase/functions/decline-challenge/index.ts
supabase/functions/cancel-challenge/index.ts
supabase/functions/submit-challenge-score/index.ts
supabase/functions/claim-deep-link-challenge/index.ts
supabase/functions/expire-challenges/index.ts
test/challenge/challenge_repository_test.dart
test/challenge/challenge_provider_test.dart
test/challenge/challenge_widgets_test.dart
```

### Degisecek dosyalar:
```
lib/app/router.dart                                        — yeni rotalar
lib/features/home_screen/home_screen.dart                  — ActiveChallengeBanner
lib/features/friends/friends_screen.dart                   — Tab refactor + Challenges tab
lib/features/profile/profile_screen.dart                   — "Challenge Gonder" butonu
lib/features/friends/friends_widgets.dart                  — FriendTile challenge ikonu
lib/features/home_screen/widgets/weekly_rival_card.dart    — Challenge butonu
lib/features/game_screen/game_callbacks.dart               — challenge score submit
lib/features/game_screen/game_over_overlay.dart            — Challenge butonu
lib/viral/share_manager.dart                 — shareChallenge metodu
lib/services/notification_service.dart       — yeni notification type'lar
lib/core/constants/color_constants.dart      — challenge renk sabitleri
lib/core/constants/color_constants_light.dart
lib/core/l10n/app_strings.dart               — ~30 yeni string
lib/core/l10n/strings_*.dart                 — 12 dil ceviri
```
