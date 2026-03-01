# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-01
> **Durum:** Sprint 1+2+3+6 TAMAMLANDI (22/22) — QA entegrasyon GECTI
> **Kalan:** 20 madde (harici arac gerektiren) | Tamamlanan fazlar: 17 (A-Q)
> **Test:** 904 birim test (723 → 904, +181 yeni test Sprint 6'da)

---

## Sprint 1: Guvenlik & Butunluk — TAMAMLANDI (7/7)

> Ajan: Backend + Developer | QA Entegrasyon: GECTI
> flutter analyze: 0 issue | flutter test: 723/723 gecti

- [x] 1.1 — **[CRITICAL] IAP sunucu tarafli receipt dogrulama** — `supabase/functions/verify-purchase/index.ts` Edge Function olusturuldu. `purchase_service.dart`'ta `_verifyAndUnlock()` ile sunucu dogrulamasi eklendi (graceful degradation destekli). `remote_repository.dart`'a `verifyPurchase()` eklendi (isConfigured guard + try-catch).
  - Ajan: Backend
  - Kabul: Edge Function + PurchaseService + RemoteRepository guncellendi

- [x] 1.2 — **[CRITICAL] Redeem codes RLS fix** — `redeem_codes` SELECT/UPDATE RLS politikalari kaldirildi. `supabase/functions/redeem-code/index.ts` Edge Function olusturuldu (auth kontrolu + service_role ile RLS bypass). `remote_repository.dart`'taki `redeemCode()` Edge Function cagiracak sekilde guncellendi.
  - Ajan: Backend
  - Kabul: Client redeem_codes tablosuna dogrudan erisemiyor

- [x] 1.3 — **[HIGH] PvP winner/skor sunucu dogrulamasi** — `pvp_matches` UPDATE RLS kaldirildi. `submit_pvp_score()` RPC fonksiyonu eklendi. Client yalnizca kendi skorunu RPC ile gonderebilir, winner sunucu tarafinda belirlenir.
  - Ajan: Backend
  - Bagimlilik: Yok
  - Kabul: Client baska oyuncunun skorunu veya winner_id'yi degistirememeli

- [x] 1.4 — **[HIGH] Skor gonderimi sunucu dogrulama** — `scores` tablosuna `CHECK (score >= 0)` constraint eklendi. `submit_score()` RPC fonksiyonu olusturuldu (mod bazli maks skor siniri: classic 100K, colorChef 50K, timeTrial 100K, zen 999K, daily 100K, level 50K, duel 100K). `remote_repository.dart`'taki `submitScore()` RPC cagirisi ile guncellendi. Dogrudan INSERT devre disi birakildi.
  - Ajan: Backend
  - Kabul: Imkansiz skor degeri reddediliyor

- [x] 1.5 — **[HIGH] GDPR DELETE RLS politikalari** — 6 tablonun tamamina `FOR DELETE` politikasi eklendi: `profiles_delete` (auth.uid()=id), `scores_delete` (auth.uid()=user_id), `daily_tasks_delete` (auth.uid()=user_id), `pvp_matches_delete` (player1/player2), `meta_states_delete` (auth.uid()=user_id), `pvp_obstacles_delete` (match katilimcisi kontrolu).
  - Ajan: Backend
  - Kabul: Kullanici kendi verisini tum tablolardan silebilir

- [x] 1.6 — **[HIGH] calculate-elo Edge Function auth kontrolu** — Auth header dogrulamasi + match player kontrolu eklendi. Token'siz istekler 401, match'e dahil olmayan kullanicilar 403 aliyor. CORS headers eklendi.
  - Ajan: Backend
  - Kabul: Auth header olmadan 401, match'e dahil olmayan kullanici 403 aliyor

- [x] 1.7 — **[MEDIUM] debugPrint production temizligi** — ~40 `debugPrint()` cagrisini `kDebugMode` guard ile sardi. 8 dosyada toplam 45 debugPrint cagrisinin tamami `if (kDebugMode)` guard icine alindi. `flutter analyze` 0 issue, `flutter test` 723/723 gecti.
  - Ajan: Developer
  - Bagimlilik: Yok
  - Kabul: Release build'de hassas bilgi loglanmamali

---

## Sprint 2: Backend Kalite & Bug Fix — TAMAMLANDI (4/4)

> Ajan: Backend + Developer | QA Entegrasyon: GECTI (30/30 kontrol)
> flutter analyze: 0 issue | flutter test: 723/723 gecti

- [x] 2.1 — **[HIGH] Race condition fix: incrementPvpStats** — Read-then-write pattern'i Supabase RPC ile atomic increment'a donusturuldu. `supabase/schema.sql`'e `increment_pvp_stat(p_stat TEXT)` RPC fonksiyonu eklendi. `remote_repository.dart`'taki `incrementPvpStats()` metodu tek bir `_client.rpc('increment_pvp_stat')` cagrisi yapacak sekilde guncellendi.
  - Ajan: Backend
  - Bagimlilik: Yok
  - Kabul: Esanli yazma durumunda veri kaybi olmamali

- [x] 2.2 — **[HIGH] PvP matchmaking simetri fix** — `_evaluateMatches()` metodunda leksikografik ID karsilastirmasi eklendi. Yalnizca `myId.compareTo(otherId) < 0` olan oyuncu `_createAndJoinMatch()` cagiriyor; diger oyuncu presence sync ile maci algiliyor. Duplicate match riski ortadan kaldirildi.
  - Ajan: Backend
  - Bagimlilik: Yok
  - Kabul: Ayni eslestirme icin tek mac olusturulmali

- [x] 2.3 — **[MEDIUM] Streak key tutarsizligi** — `getProfile()` ve `saveProfile()` metodlarindaki `'streak'` key'i `'streak_count'` olarak degistirildi. Artik tum streak islemleri (`getProfile`, `saveProfile`, `getStreak`, `checkAndUpdateStreak`) ayni `streak_count` key'ini kullaniyor.
  - Ajan: Backend
  - Bagimlilik: Yok
  - Kabul: Streak degeri her yerde tutarli olmali

- [x] 2.4 — **[LOW] UserProfile.createdAt late init fix** — `late DateTime createdAt` → `DateTime createdAt = DateTime.now()` olarak degistirildi. `LateInitializationError` riski ortadan kaldirildi.
  - Ajan: Developer
  - Bagimlilik: Yok
  - Kabul: `LateInitializationError` olasiligi sifir olmali

---

## Sprint 3: Gorsel & Branding — TAMAMLANDI (2/2, 1 atlandi)

> Ajan: UI/UX + DevOps | QA Entegrasyon: GECTI
> flutter analyze: 0 issue | flutter test: 723/723 gecti

- [x] 3.1 — **[HIGH] Uygulama ikonu tasarla** — `tool/generate_icon.dart` ile 1024x1024 master ikon programatik uretildi. `image` paketi ile koyu gradient arka plan (#010C14) uzerine cyan (#00E5FF) jel damlasi (superellipse blob + glow + specular highlight). `flutter_launcher_icons` ile Android (5 DPI mipmap + adaptive icon w/ #010C14 background), iOS (25 ikon dosyasi), Web (4 ikon + favicon) dagitildi.
  - Ajan: UI/UX
  - Bagimlilik: Yok
  - Kabul: Her uc platform icin ikon uretilmis, varsayilan Flutter ikonu degistirilmis. flutter analyze: 0 issue, flutter test: 723/723 gecti.

- [x] 3.2 — **[HIGH] Splash screen / native splash yapilandirmasi** — `flutter_native_splash: ^2.4.0` eklendi (dependencies). Splash rengi `#010C14` (kBgDark). Android (drawable + v31 styles), iOS (LaunchScreen.storyboard + LaunchBackground), Web (CSS + splash script) uretildi. `main.dart`'ta `FlutterNativeSplash.preserve()` / `.remove()` entegrasyonu yapildi. Logo PNG'si henuz mevcut degil — renk bazli splash. flutter analyze: 0 issue (splash ile ilgili), flutter test: 723/723 gecti.
  - Ajan: DevOps
  - Bagimlilik: 3.1 (ikon tasarimi — tamamlaninca splash'e eklenecek)
  - Kabul: Uygulama acilisinda #010C14 arka planli splash gorunmeli

- [x] 3.3 — ~~Gorsel asset'ler~~ — **ATLANDI**: Proje shader + CustomPainter ile render ediyor, rasterize gorsel bagimliligi yok. Bos dizinler gelecek kullanim icin korunuyor.

---

## Sprint 4: iOS App Store Hazirligi

> Gerekli: Apple Developer Account ($99/yil) + Xcode + Fiziksel cihaz
> Ajan: DevOps | Tum maddeler HARICI hesap/cihaz gerektiriyor

- [ ] 4.1 — Apple Developer Account'ta App ID kaydet (`com.gloogame.app`)
- [ ] 4.2 — Signing & Capabilities ayarla (Xcode — Development + Distribution)
- [ ] 4.3 — In-App Purchase capability ekle
- [ ] 4.4 — App Store Connect'te 7 IAP urunu tanimla
- [ ] 4.5 — StoreKit Sandbox test *(fiziksel cihaz gerekli)*
- [ ] 4.6 — Ekran goruntuleri (6.7", 6.1", 5.5" — 12 dil)
- [ ] 4.7 — App Store onizleme videosu
- [ ] 4.8 — AdMob gercek App ID + ad unit ID'leri (iOS)
- [ ] 4.9 — TestFlight dahili + harici test
- [ ] 4.10 — Submit for Review

---

## Sprint 5: Android Play Store Hazirligi

> Gerekli: Google Play Console ($25 tek seferlik) + Android SDK + Keystore
> Ajan: DevOps | Tum maddeler HARICI hesap/cihaz gerektiriyor

- [ ] 5.1 — Android SDK kurulumu + `ANDROID_HOME` tanimlama (bu makinede eksik)
- [ ] 5.2 — Release keystore olustur + `key.properties` yapilandir
- [ ] 5.3 — `flutter build appbundle --release` basarili build
- [ ] 5.4 — Google Play Console'da uygulama olustur
- [ ] 5.5 — Store listesi: baslik, aciklama, ekran goruntuleri (12 dil)
- [ ] 5.6 — Icerik derecelendirme anketi
- [ ] 5.7 — IAP urunlerini Play Console'da tanimla
- [ ] 5.8 — AdMob gercek App ID + ad unit ID'leri (Android)
- [ ] 5.9 — Dahili test → Kapali test → Acik test → Uretim

---

## Sprint 6: Post-Launch Iyilestirmeler (Opsiyonel)

> Bunlar store yayini icin zorunlu degil. Kalite ve surdurulebilirlik icin onerilir.
> **Durum:** TAMAMLANDI (9/9 calistirilan) | Atlanan: 6 (harici arac) | Zaten mevcut: 1

### Batch 1: Kod Kalitesi (Paralel)

- [x] 6.1 — **[MEDIUM]** `home_screen.dart` parcalama (1,213 satir → `widgets/` altina 8 dosya + ana dosya ~329 satir) — TAMAMLANDI
  - Ajan: UI/UX
  - Kabul: 18 widget 8 dosyaya ayrilmis, tum importlar guncel, `flutter analyze` 0 issue, testler gecmeli

- [x] 6.2 — **[MEDIUM]** `AudioSettings` → `AppSettings` yeniden adlandirma — TAMAMLANDI. 7 dosyada tum referanslar guncellendi (`audio_provider.dart`, 4 feature, 3 test). Provider: `appSettingsProvider`.
  - Ajan: Developer
  - Kabul: Tum referanslar guncellenmis, provider adi `appSettingsProvider` olarak degismis

- [x] 6.3 — **[LOW]** `core/widgets/glow_orb.dart` → `features/shared/glow_orb.dart` tasinmasi — TAMAMLANDI. 14 dosyada import guncellendi, eski dosya ve bos dizin silindi.
  - Ajan: Developer
  - Kabul: Dosya tasinmis, 14 import guncellenmis, `flutter analyze` 0 issue

### Batch 2: Test Kapsami (Paralel)

- [x] 6.6 — **[HIGH]** Remote veri katmani testleri (`remote_repository.dart`, `pvp_realtime_service.dart`) — TAMAMLANDI. 69 test yazildi (36 RemoteRepository + 33 PvpRealtimeService). `_UnconfiguredRemoteRepository` alt sinifi ile `isConfigured=false` guard pattern'i test edildi. Supabase bagimliligi olmadan tum public metodlar dogrulanmis. `flutter analyze` 0 issue, `flutter test test/data/` 143/143 gecti.
  - Ajan: QA
  - Kabul: Birim testler yazilmis, `flutter test` gecmeli

- [x] 6.7 — **[HIGH]** Monetizasyon servis testleri (`ad_manager.dart`, `purchase_service.dart`)
  - Ajan: QA
  - Kabul: Birim testler yazilmis, `flutter test` gecmeli
  - Sonuc: 32 AdManager + 35 PurchaseService testi yazildi, 0 analyze issue, tum testler geciyor

- [x] 6.8 — **[MEDIUM]** Feature ekran testleri — TAMAMLANDI. 7 yeni test dosyasi: shop_screen (6 test), leaderboard_screen (5 test), pvp_lobby_screen (6 test), character_screen (5 test), island_screen (4 test), season_pass_screen (5 test), daily_puzzle_screen (5 test). Toplam 36 yeni widget testi. `SupabaseConfig`'a `_initialized` guard eklendi (test ortaminda Supabase.instance crash'i onlendi). `RemoteRepository.isConfigured`'a `isInitialized` kontrolu eklendi.
  - Ajan: QA
  - Kabul: 36 yeni test gecti, `flutter analyze` 0 issue, `flutter test test/features/` 68/68 gecti

### Batch 3: Mimari + CI/CD (Paralel)

- [x] 6.9 — **[MEDIUM]** Web build CI workflow ekleme (`.github/workflows/web_build.yml`) — TAMAMLANDI. Mevcut Android/iOS build pattern'ina uygun workflow olusturuldu: push to main (paths-ignore: md/docs/tasks), ubuntu-latest runner, 15dk timeout, Flutter 3.41.x stable (cached), `flutter build web --release`, artifact upload (web-release, 7 gun retention). Action versiyonlari: checkout@v4, flutter-action@v2, upload-artifact@v4.
  - Ajan: DevOps
  - Kabul: Workflow dosyasi olusturulmus, mevcut CI pattern'a uygun

- [x] 6.15 — **[HIGH]** Singleton servisler → Riverpod Provider'lara tasima (AudioManager, HapticManager, AdManager, PurchaseService, AnalyticsService) — TAMAMLANDI. `lib/providers/service_providers.dart` olusturuldu (5 provider). `AppSettingsNotifier` constructor injection ile guncellendi (lazy fallback ile geriye uyumlu). Singleton pattern korundu. `flutter analyze lib/providers/` 0 issue, `flutter test` 895/895 gecti.
  - Ajan: Developer
  - Bagimlilk: 6.2 (AudioSettings rename tamamlanmali)
  - Kabul: 5 singleton provider ile sarili, testler gecmeli

- [x] 6.16 — **[HIGH]** RemoteRepository tip guvenli DTO siniflari ekleme (raw Map → typed DTO) — 4 DTO sinifi olusturuldu (`LeaderboardEntry`, `DailyPuzzle`, `PvpMatch`, `MetaState`). `RemoteRepository`'deki 4 metod (`getGlobalLeaderboard`, `getDailyPuzzle`, `getPvpMatch`, `loadMetaState`) DTO donecek sekilde guncellendi. 5 caller (LeaderboardScreen, IslandScreen, CharacterScreen, SeasonPassScreen, QuestOverlay) guncellendi. 12 yeni DTO test eklendi. 904 test gecti, 0 analyze issue.
  - Ajan: Backend
  - Kabul: DTO siniflari olusturulmus, RemoteRepository donusleri tip guvenli

### Atlanan Gorevler

- [x] 6.10 — ~~Viewport meta tag~~ — **ZATEN MEVCUT**: `web/index.html` satir 97'de tam yapilandirilmis viewport meta tag var
- [ ] 6.4 — Firebase App Check — **ATLANDI**: Firebase Console erisiimi gerekli
- [ ] 6.5 — Firebase API key kisitlamalari — **ATLANDI**: Firebase Console erisiimi gerekli
- [ ] 6.11 — Fastlane/Shorebird — **ATLANDI**: Harici kurulum gerekli
- [ ] 6.12 — Viral pipeline e2e — **ATLANDI**: Fiziksel cihaz gerekli
- [ ] 6.13 — TikTok/Instagram share — **ATLANDI**: Fiziksel cihaz + API key gerekli
- [ ] 6.14 — Performans profili — **ATLANDI**: Fiziksel cihaz gerekli

---

## CLAUDE.md Guncelleme Gereklilikleri

> Bu maddeler dokumantasyon tutarsizliklaridir, kod degisikligi gerektirmez.

- [x] `firebase_options.dart` icin "tum degerler PLACEHOLDER" ifadesi guncellendi — gercek degerler (`gloo-f7905`) yansitildi
- [x] Supabase tablo sayisi CLAUDE.md'de zaten "7 tablo" olarak dogru referanslanmis (ek duzeltme gerekmedi)

---

## Tamamlanan Fazlar (Referans)

| Faz | Aciklama |
|-----|----------|
| A | 723 birim test (37 dosya, 0 hata) |
| B | Supabase entegrasyon (7 tablo + 15 RLS + indeksler) |
| C | PvP Realtime (Presence + Broadcast + bot fallback + ELO) |
| D | Meta-game backend (meta_states + cross-device sync) |
| E | Firebase Analytics + Crashlytics (gloo-f7905) |
| F | 36 ses dosyasi (32 SFX .ogg + 4 muzik .mp3) + 32 iOS .m4a |
| G | Viral pipeline (screen_recorder + FFmpeg + share) |
| J | CI/CD (4 GitHub Actions workflow) |
| K | Kod kalitesi (refactoring, rename, README, GDD) |
| L | Bundle ID, GDPR/ATT, memory leak fix, dosya refactoring |
| M | Performans optimizasyonu: 33/33 (4 CRITICAL + 8 HIGH + 15 MEDIUM + 4 LOW) |
| N | Sprint 1: Guvenlik hardening 7/7 (IAP receipt, redeem RLS, PvP RPC, skor RPC, GDPR DELETE, ELO auth, debugPrint) |
| O | Sprint 2: Backend kalite 4/4 (race condition RPC, matchmaking simetri, streak key, createdAt fix) |
| P | Sprint 3: Gorsel & branding 2/2 (programatik jel damlasi ikon + native splash #010C14) |
| Q | Sprint 6: Post-launch 9/9 — home_screen parcalama, AppSettings rename, glow_orb tasima, 181 yeni test (904 toplam), web CI, singleton→provider, DTO siniflari |

---

## 5-Ajan Analiz Ozeti (2026-03-01)

| Ajan | Sonuc |
|------|-------|
| **QA** | 723/723 test gecti, 0 analyze issue. Oyun motoru %100 kapsam. Remote/monetizasyon %0 kapsam. |
| **Architect** | Mimari olgunluk YUKSEK. Katman ayrimi mukemmel (0 ihlal). 0 TODO/FIXME/HACK. |
| **Backend** | %84 hazirlik. Supabase + Firebase gercek key'ler. Race condition + streak tutarsizligi mevcut. |
| **Security** | Risk YUKSEK. IAP dogrulama YOK, redeem codes RLS acik, skor dogrulama YOK, anti-cheat YOK. |
| **DevOps** | iOS kosullu hazir. Android SDK bu makinede YOK. Gorsel asset'ler bos. Test ID'ler aktif. |
