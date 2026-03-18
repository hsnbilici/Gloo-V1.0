# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**GitHub:** `https://github.com/hsnbilici/Gloo-V1.0.git` (branch: `main`)

## Komutlar

```bash
flutter pub get                                # bagimliliklari indir
flutter analyze                                # lint (0 error/warning olmali)
flutter test                                   # tum testler (1220 test)
flutter test test/game/grid_manager_test.dart   # tek test dosyasi
flutter test --name "ComboDetector"             # isimle filtrele
flutter build web --release                    # web build
flutter build apk --debug                      # android debug
flutter run -d chrome                          # web'de calistir
flutter run -d "iPhone 16 Pro"                 # iOS simulator'de calistir
./scripts/run_local.sh -d chrome               # .env ile web'de calistir
./scripts/run_local.sh -d "iPhone 17 Pro"      # .env ile iOS'ta calistir
```

### Build Workaround

Flutter `impellerc` shader compiler, proje yolunda non-ASCII karakter varsa cokuyor. ASCII-safe yola kopyalayip build edin. Web build'lar etkilenmez.

### Android Emulator

```bash
emulator -avd Gloo_Pixel8 -no-snapshot-load
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Gereksinimler

- **Flutter SDK** 3.19+ (mevcut: 3.41.2). Dart SDK: `>=3.3.0 <4.0.0`
- **Android**: `ANDROID_HOME` tanimli, AVD `Gloo_Pixel8` (1080x2400)
- **iOS**: macOS + Xcode. Flutter 3.41+ iOS'ta Swift Package Manager kullanir (CocoaPods gereksiz)

## Mimari

### Katman Yapisi ve Bagimlilik Yonu

```
app/ → features/ → providers/ → game/ → core/
                  → providers/ → data/ → core/
                  → providers/ → services/
                               → audio/
```

- `core/` — Saf Dart; Flutter bagimliligi yok. Sabitler, utils, l10n, extensions.
- `game/` — Saf Dart oyun motoru (Flutter'dan bagimsiz). GlooGame, GridManager, systems, shapes, levels, economy, pvp, physics.
- `features/` — Flutter widget'lari (14 ekran). `game_screen/` 3 part mixin ile bolunmus: `game_callbacks.dart`, `game_interactions.dart`, `game_grid_builder.dart`.
- `data/` — `local/` (SharedPreferences), `remote/` (Supabase). Tum remote metodlarda `isConfigured` guard zorunlu.
- `services/` — AnalyticsService (Firebase), AdManager, PurchaseService.
- `providers/` — Riverpod: game, audio, user, locale, pvp, service providers.

**Bilinen katman ihlalleri** (todo'da duzeltme planli):
- ~~`audio/sound_bank.dart` → `game/systems/combo_detector.dart`~~ — DUZELTILDI (Sprint 20)
- ~~`pvp_lobby_screen.dart` → `supabase_client.dart`~~ — DUZELTILDI (`currentUserIdProvider` uzerinden)
- `data/remote/pvp_realtime_service.dart` tip import'u `pvp_lobby_screen.dart`'ta — provider API'sinin parcasi, kabul edilmis risk

### Oyun Motoru

`GlooGame` saf Dart sinifidir (Flame kullanmaz). Her hamle pipeline:

```
GameScreen._onCellTap()
  → GlooGame.placePiece(cells, color)
      → GridManager.place()
      → _evaluateBoard():
          → _applySyntheses()
          → _updateColorChefProgress()
          → _clearAndScore()
          → _applyGravityAndCascade()
          → _checkTimeTrialBonus()
          → _checkLevelCompletion()
          → _evaluateNearMiss()
          → _powerUpSystem.onMoveCompleted()
      → Level modu: hedef skor / hamle siniri → onLevelComplete
  → GlooGame.checkGameOver(handShapes)
```

`GlooGame` UI'ya 15 callback ile bildirir (`onScoreGained`, `onCombo`, `onGameOver`, `onLevelComplete` vb.); Riverpod provider'larini dogrudan cagirmaz.

### State Mulkiyeti

`GameScreen` bir `GlooGame` ornegini `State` icinde dogrudan tutar (Riverpod ile degil). Riverpod yalnizca UI gosterimi icin:

| Provider | Icerik |
|---|---|
| `gameProvider(GameMode)` | score, status, filledCells, remainingSeconds, chefProgress |
| `audioSettingsProvider` | sfx/music/haptics/colorBlind/analytics/glooPlus/adsRemoved |
| `localRepositoryProvider` | `FutureProvider<LocalRepository>` SharedPreferences wrapper |
| `stringsProvider` | Aktif dildeki l10n string'leri |
| `streakProvider` | Gunluk giris serisi |
| `eloProvider` | PvP ELO puani |
| `duelProvider` | DuelState (matchId, seed, opponentElo, opponentScore, isBot) |
| `currentUserIdProvider` | `SupabaseConfig.currentUserId` — feature katmaninda dogrudan Supabase erisimini onler |

### GameMode Enum (7 mod)

`core/models/game_mode.dart`'ta tanimli (saf Dart, Flutter bagimliligi yok). `game_world.dart` re-export eder.

`classic`, `colorChef`, `timeTrial`, `zen` (Gloo+ gerekli), `daily` (seeded), `level` (50+prosedurel), `duel` (120sn, ELO, seeded)

### Hucre ve Izgara

Izgara `List<List<Cell>>` — varsayilan 8x10, Level modunda dinamik (6x6 → 10x12).

**CellType:** `normal`, `ice` (1-2 katman), `locked` (belirli renk), `stone` (engel), `gravity` (duser), `rainbow` (joker)

### Renk Sistemi

`GelColor` enum 12 renk. Elden yalnizca 4 birincil renk cikar: `red`, `yellow`, `blue`, `white`. 8 sentez rengi birlesimle olusur.

`kColorMixingTable` (`color_constants.dart`): sira bagimsiz arama. Yeni kombinasyon icin yalnizca bu tabloya giris ekle.

`GelColor.shortLabel`: Renk koru modu icin dil bagimsiz kisaltma — degistirilmemeli.

Renk adlari l10n uzerinden: `AppStrings.colorName(GelColor)`. `GelColor` uzerinde `displayName` getter'i yoktur.

UI palet sabitleri `color_constants.dart`'ta: `kBgDark`, `kCyan`, `kMuted`, `kOrange`, `kModeColors` map'i. Ekranlarda yerel renk sabiti tanimlanmamali.

### Routing

GoRouter. **ONEMLI:** Spesifik rotalar genel `/game/:mode`'dan ONCE tanimlanmali:
1. `/game/level/:levelId`
2. `/game/duel`
3. `/game/:mode` (generic)

`GameMode.fromString()` gecersiz degerleri `classic`'e dusurur.

### Dialog Gecisleri

`fadeScaleTransition` (`ui_constants.dart`): Tum `showGeneralDialog` transition builder'lari icin paylasilmis FadeTransition + ScaleTransition helper. Yeni dialog eklerken bunu kullan, inline transition builder yazma.

### DuelState.copyWith Sentinel Deseni

`DuelState.copyWith` nullable alanlari (`matchId`, `seed`, `opponentElo`) icin `_Absent` sentinel sinifi kullanir. Bu, `copyWith(matchId: null)` ile "alanı null yap" ve `copyWith()` ile "alani degistirme" arasindaki farki korur.

## Onemli Kisitlamalar

### Flutter API (3.41+)
- `withOpacity()` → `withValues(alpha:)` kullan
- `Color.red`/`.green`/`.blue` → `(color.r * 255).round()` kullan
- `color.value` → `color.toARGB32()` kullan
- Platform kontrolu: `Platform.isIOS` → `defaultTargetPlatform == TargetPlatform.iOS` kullan (`dart:io` import'u gerektirmez)

### Platform Guard'lar
- `main.dart`: Firebase init try-catch sarili. Supabase init try-catch. AdManager + PurchaseService `kIsWeb` guard. iOS `edgeToEdge`, diger `immersiveSticky`.
- `AndroidManifest.xml`: AdMob App ID zorunlu — olmadan FATAL EXCEPTION. Simdi test ID aktif.
- Web uyumsuz paketler: `google_mobile_ads`. `just_audio` web-uyumlu. `ffmpeg_kit_flutter` ve `screen_recorder` kaldirildi.

### Veri Katmani
- `LocalRepository`: SharedPreferences + `flutter_secure_storage`. Hassas veriler (elo, gel_ozu, gel_energy, pvp_wins/losses, unlocked_products, pending_verification, redeemed_codes) SecureStorage'da sifreleniyor. Migration fallback: SecureStorage'da yoksa SharedPreferences'tan okur. Constructor opsiyonel `SecureStorageInterface` alir — testlerde `FakeSecureStorage` kullanilir. `SecureStorageImpl.write(null)` anahtari siler (`delete`), bos string yazmaz. **Test notu:** Secure-storage metodlarina (getElo vb.) dokunan testler `localRepositoryProvider`'i `FakeSecureStorage` ile override etmeli — aksi halde `MissingPluginException`.
- `RemoteRepository`: Supabase. Tum metodlarda `isConfigured` guard ve try-catch zorunlu. `kDebugMode` guard'li debugPrint. `submitScore`/`submitPvpResult` icin `_retry()` ile exponential backoff (3 deneme).
- `PvpRealtimeService`: Supabase Realtime (Presence + Broadcast). Duplicate match onlemi: leksikografik ID karsilastirmasi.
- `AnalyticsService`: Lazy/null-safe Firebase wrapper — yoksa sessizce no-op.
- `firebase_options.dart` ve `supabase_client.dart`: Gercek key'ler kaynak kodda (bilinen sorun, C.4 ile `--dart-define`'a tasinacak).

### Ses ve Haptik
- `AudioManager`: `assets/audio/sfx/` ve `assets/audio/music/`. Dosya bulunamazsa sessizce atlar.
- `HapticManager`: 14 haptic profil, tam implementasyon.
- `.ogg` iOS'ta native desteklenmez — `.ogg` + `.m4a` ikili format kullanilmali.
- `SoundBank`: `onLineClear` ve `onGameOver` implementasyonu tamamlandi (AudioManager SFX + HapticManager). `onGameOver` yalnizca SFX calar (haptic yok — game over'da haptic kafa karistirici).

## l10n

12 dil: `en` (fallback), `tr`, `de`, `zh`, `ja`, `ko`, `ru`, `es`, `ar`, `fr`, `hi`, `pt`

```dart
final l = ref.watch(stringsProvider);
Text(l.scoreLabel)
```

Yeni string eklemek: (1) `app_strings.dart`'a abstract getter, (2) tum 12 `strings_*.dart`'a override, (3) cevirileri dogrula. Renk adlari icin `AppStrings.colorName(GelColor)` helper metodu mevcut.

## Linting

`flutter_lints` temel. Ek kurallar: `prefer_single_quotes`, `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_fields`, `sort_child_properties_last`, `use_super_parameters`, `avoid_print`, `always_declare_return_types`.

14 info-seviyesi sorun mevcut (13x `curly_braces_in_flow_control_structures` + 1x `prefer_const_constructors`). 0 error, 0 warning.

## Monetizasyon

- **Zen modu**: Gloo+ abonelik ile kilitli
- **AdManager**: Interstitial (4 oyunda 1), rewarded (ikinci sans), banner. Anti-frustration: 5dk'da 2 kayip → reklam yok. Test ID'ler aktif.
- **PurchaseService**: 7 IAP urunu. Sunucu tarafinda receipt dogrulama (Supabase Edge Function). `_pendingVerification` SharedPreferences'a persist ediliyor; app restart'ta otomatik retry. Abonelik expiry kontrolu `restorePurchases()` + `syncLocalProducts()` ile yapilir.
- **Redeem Code**: `ShopScreen` → `RemoteRepository.redeemCode()` → Supabase Edge Function → `PurchaseService.unlockProducts()`

## Proje Durumu (2026-03-18)

**Scorecard:** 76/100 (Sprint 20 sonrasi)

| Alan | Puan | En Kritik Sorun |
|------|:----:|-----------------|
| Mimari | 78 | State management (65), features→data bypass |
| Gameplay | 78 | ShapeGenerator static state, seeded RNG |
| UI/UX | 72 | Erisilebilirlik 38/100, Responsive 45/100 |
| QA | 79 | Integration test sifir, mock/fake yok |
| DevOps | 73 | Release hazirligi (45), iOS signing eksik |
| Backend | 77 | GDPR uyumlulugu (68), UMP SDK eksik |
| Guvenlik | 68 | Hardcoded secrets (35), certificate pinning yok |

Detayli gorev listesi ve alt alan puanlari: `_dev/tasks/todo.md`

## Detayli Dokumantasyon

| Dokuman | Amac |
|---|---|
| `_dev/docs/GDD.md` | Game Design Document — mekanikler, monetizasyon, ASO |
| `_dev/docs/TECHNICAL_ARCHITECTURE.md` | Sistem diyagrami, algoritma ornekleri |
| `_dev/docs/P0-STORE-HAZIRLIGI.md` | Store oncesi harici adimlar kilavuzu |
| `_dev/tasks/todo.md` | Yol haritasi, scorecard, kalan gorevler (P0-P3 oncelikli) |
| `_dev/tasks/lessons.md` | Sprint bazli dersler ve kurallar |
