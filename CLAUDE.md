# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**GitHub:** `https://github.com/hsnbilici/Gloo-V1.0.git` (branch: `main`)

## Komutlar

```bash
flutter pub get                                # bagimliliklari indir
flutter analyze                                # lint (0 error/warning olmali)
flutter test                                   # tum testler (1295 test)
flutter test test/game/grid_manager_test.dart   # tek test dosyasi
flutter test --name "ComboDetector"             # isimle filtrele
flutter build web --release --dart-define-from-file=.env  # web build
flutter build apk --debug --dart-define-from-file=.env   # android debug
flutter build ios --simulator --dart-define-from-file=.env # iOS simulator
flutter run -d chrome                          # web'de calistir (secret'siz)
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
- **Secrets**: `.env` dosyasi (gitignore'd) `--dart-define-from-file=.env` ile inject edilir. CI'da GitHub Secrets kullanilir.

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
- `features/` — Flutter widget'lari (14 ekran). `game_screen/` 3 part mixin ile bolunmus: `game_callbacks.dart`, `game_interactions.dart`, `game_grid_builder.dart`. Ek: `tutorial_overlay.dart` (ilk oyun 3 adimli rehber), `share_prompt_dialog.dart` (epic combo sonrasi paylasim), `effects/confetti_effect.dart` (high score kutlama).
- `data/` — `local/` (SharedPreferences), `remote/` (Supabase). Tum remote metodlarda `isConfigured` guard zorunlu.
- `services/` — AnalyticsService (Firebase), AdManager, PurchaseService.
- `providers/` — Riverpod: game, audio, user, locale, pvp, service providers.

Bilinen katman ihlalleri tamamiyla duzeltildi (Sprint 20-21).

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

UI palet sabitleri `color_constants.dart`'ta (75+ sabit): `kBgDark`, `kCyan`, `kMuted`, `kOrange`, `kModeColors`, `kSurfaceDark`, `kIceBlue`, `kAmber`, `kPowerUp*` vb. Ekranlarda `Color(0x...)` literal kullanma — `color_constants.dart`'a sabit ekle ve import et.

### Routing

GoRouter. **ONEMLI:** Spesifik rotalar genel `/game/:mode`'dan ONCE tanimlanmali:
1. `/game/level/:levelId`
2. `/game/duel`
3. `/game/:mode` (generic)

`GameMode.fromString()` gecersiz degerleri `classic`'e dusurur.

### Dialog Gecisleri

`fadeScaleTransition` (`ui_constants.dart`): Tum `showGeneralDialog` transition builder'lari icin paylasilmis FadeTransition + ScaleTransition helper. Yeni dialog eklerken bunu kullan, inline transition builder yazma.

### ShapeGenerator

`ShapeGenerator` instance-based (M.17). `GlooGame` constructor'inda opsiyonel: `GlooGame({..., ShapeGenerator? shapeGenerator})`. Stateful metodlar (generateSmartHand, recordLoss/Win/Clear) instance uzerinden. Stateless metodlar (getDifficulty, generateSeededHand, todaySeed) static kalir. Testlerde izole state icin `ShapeGenerator(rng: Random(42))` kullanilabilir.

`availableColors` (L.15): `generateSmartHand`, `generateSeededHand` ve tum ic renk secim metodlari opsiyonel `List<GelColor>? availableColors` parametresi alir. `null` → `kPrimaryColors` (4 birincil renk). `GlooGame.generateNextHand()` bu degeri `levelData?.availableColors`'dan alir. Level modunda per-level renk kisitlamasi mumkun.

### DuelState.copyWith Sentinel Deseni

`DuelState.copyWith` nullable alanlari (`matchId`, `seed`, `opponentElo`) icin `_Absent` sentinel sinifi kullanir. Bu, `copyWith(matchId: null)` ile "alanı null yap" ve `copyWith()` ile "alani degistirme" arasindaki farki korur.

## Onemli Kisitlamalar

### Flutter API (3.41+)
- `withOpacity()` → `withValues(alpha:)` kullan
- `Color.red`/`.green`/`.blue` → `(color.r * 255).round()` kullan
- `color.value` → `color.toARGB32()` kullan
- Platform kontrolu: `Platform.isIOS` → `defaultTargetPlatform == TargetPlatform.iOS` kullan (`dart:io` import'u gerektirmez)

### Certificate Pinning
- Android: `android/app/src/main/res/xml/network_security_config.xml` — Supabase + Google/Firebase domain'leri icin SHA-256 SPKI pin'leri. `AndroidManifest.xml`'de `networkSecurityConfig` referansi.
- Dart katmani: `core/network/certificate_pinner.dart` + `pinned_http_overrides.dart`. `main.dart`'ta `HttpOverrides.global` ile aktif (`kIsWeb` guard'li). `badCertificateCallback` pinned domain'lerde kotu sertifikalari reddeder.
- iOS: ATS (App Transport Security) varsayilan — native pinning eklenmedi (bilinen sinirlilik).
- Pin sabitleri `kCertificatePins` — Supabase leaf+CA, Google leaf+CA. Sertifika yenilendiginde guncellenmelidir.

### Erisilebilirlik (a11y)
- `core/ui/accessible_tap_target.dart`: WCAG 2.1 uyumlu 44x44dp minimum tap target + Semantics wrapper. Yeni interaktif eleman eklerken bunu kullan.
- 8 ekranda Semantics widget'lari mevcut. Yeni ekran eklerken her interaktif elemana `Semantics(label:, button: true)` ekle.
- `MediaQuery.textScalerOf(context).scale(fontSize)` ile dinamik font boyutlama — 5 ekranda aktif. Oyun grid cell'leri muaf.

### Platform Guard'lar
- `main.dart`: Certificate pinning (`HttpOverrides.global`), Firebase init try-catch sarili. Supabase init try-catch. AdManager + PurchaseService `kIsWeb` guard. iOS `edgeToEdge`, diger `immersiveSticky`.
- `AndroidManifest.xml`: AdMob App ID zorunlu — olmadan FATAL EXCEPTION. Simdi test ID aktif.
- Web uyumsuz paketler: `google_mobile_ads`. `just_audio` web-uyumlu. `ffmpeg_kit_flutter` ve `screen_recorder` kaldirildi.

### Veri Katmani
- `LocalRepository`: SharedPreferences + `flutter_secure_storage`. Hassas veriler (elo, gel_ozu, gel_energy, pvp_wins/losses, unlocked_products, pending_verification, redeemed_codes) SecureStorage'da sifreleniyor. Migration fallback: SecureStorage'da yoksa SharedPreferences'tan okur. Constructor opsiyonel `SecureStorageInterface` alir — testlerde `FakeSecureStorage` kullanilir. `SecureStorageImpl.write(null)` anahtari siler (`delete`), bos string yazmaz. **Test notu:** Secure-storage metodlarina (getElo vb.) dokunan testler `localRepositoryProvider`'i `FakeSecureStorage` ile override etmeli — aksi halde `MissingPluginException`.
- `RemoteRepository`: Supabase. Tum metodlarda `isConfigured` guard ve try-catch zorunlu. `kDebugMode` guard'li debugPrint. `submitScore`/`submitPvpResult` icin `_retry()` ile exponential backoff (3 deneme).
- `PvpRealtimeService`: Supabase Realtime (Presence + Broadcast). Duplicate match onlemi: leksikografik ID karsilastirmasi.
- `AnalyticsService`: Lazy/null-safe Firebase wrapper — yoksa sessizce no-op.
- `firebase_options.dart` ve `supabase_client.dart`: `String.fromEnvironment` ile `--dart-define` uzerinden inject edilir. `defaultValue: ''` — key yoksa `isConfigured` guard init'i atlar. Firebase projesi: `gloo-d3dd8`.
- `ad_manager.dart`: Ad unit ID'leri `--dart-define` ile inject edilir. Bos ise Google test ID'lere fallback yapar.

### Android Signing
- Debug: debug.keystore (otomatik)
- Release: `android/gloo-release.jks` (alias: `gloo`). `android/app/key.properties` ile yapilandirilmis.
- `key.properties` ve `*.jks` gitignore'da — CI'da GitHub Secrets uzerinden inject edilir.

### iOS Signing
- Debug: Automatic signing (Xcode manages)
- Release/Profile: Manual signing — `CODE_SIGN_IDENTITY = "Apple Distribution"`, `PROVISIONING_PROFILE_SPECIFIER = "Gloo AppStore Distribution"`, Team ID: `6XM2F48V3V`
- `ExportOptions.plist`: `ios/ExportOptions.plist` — app-store-connect method, manual signing
- CI: Certificate (.p12) ve provisioning profile base64 encoded GitHub Secrets'ta. Keychain'e import edilir, profile UUID ile kopyalanir.
- FlutterFire Crashlytics symbol upload build phase: `flutterfire` yoksa sessizce atlar (CI uyumlu)

### Ses ve Haptik
- `AudioManager`: `assets/audio/sfx/` ve `assets/audio/music/`. Dosya bulunamazsa sessizce atlar.
- `HapticManager`: 14 haptic profil, tam implementasyon.
- `.ogg` iOS'ta native desteklenmez — `.ogg` + `.m4a` ikili format kullanilmali.
- `SoundBank`: Tam pipeline (L.9). Mevcut event'ler: `onGelPlaced` (SFX+haptic), `onGelMerge` (SFX tier-based+haptic), `onLineClear` (SFX+haptic), `onCombo` (SFX all tiers — small@0.5 vol, medium, large+haptic, epic+haptic), `onGameOver` (SFX only), `onLevelComplete` (SFX+haptic). Yeni event'ler: `onSynthesis`, `onIceBreak`, `onPowerUpActivate`, `onGravityDrop`, `onButtonTap`, `onGelOzuEarn`, `onNearMiss(survived:)`.

## l10n

12 dil: `en` (fallback), `tr`, `de`, `zh`, `ja`, `ko`, `ru`, `es`, `ar`, `fr`, `hi`, `pt`

```dart
final l = ref.watch(stringsProvider);
Text(l.scoreLabel)
```

Yeni string eklemek: (1) `app_strings.dart`'a abstract getter, (2) tum 12 `strings_*.dart`'a override, (3) cevirileri dogrula. Renk adlari icin `AppStrings.colorName(GelColor)` helper metodu mevcut. ELO lig isimleri icin `EloLeague.leagueName(AppStrings l)` metodu kullanilir (L.18) — `displayName` getter'i kaldirildi.

## Linting

`flutter_lints` temel. Ek kurallar: `prefer_single_quotes`, `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_fields`, `sort_child_properties_last`, `use_super_parameters`, `avoid_print`, `always_declare_return_types`.

15 info-seviyesi sorun mevcut (14x `curly_braces_in_flow_control_structures` + 1x `prefer_const_constructors`). 0 error, 0 warning.

## Monetizasyon

- **Zen modu**: Gloo+ abonelik ile kilitli
- **AdManager**: Interstitial (4 oyunda 1), rewarded (ikinci sans), banner. Anti-frustration: 5dk'da 2 kayip → reklam yok. Test ID'ler aktif.
- **PurchaseService**: 7 IAP urunu. Sunucu tarafinda receipt dogrulama (Supabase Edge Function). `_pendingVerification` SharedPreferences'a persist ediliyor; app restart'ta otomatik retry. Abonelik expiry kontrolu `restorePurchases()` + `syncLocalProducts()` ile yapilir.
- **Redeem Code**: `ShopScreen` → `RemoteRepository.redeemCode()` → Supabase Edge Function → `PurchaseService.unlockProducts()`
- **Ekonomi inflasyonu** (L.16): `CurrencyManager.inflatedCost(baseCost)` — birikimli kazanima dayali 1x→3x maliyet olcekleme (500 birim basina +1x). `lifetimeEarnings` persist ve UI wiring henuz yapilmadi.

### Test Uyarilari
- `flutter_animate` kullanan widget'lar `pumpAndSettle()` timeout'a neden olur — `pump(Duration)` kullan. Scroll'da yeni inflate olan widget'lar icin birden fazla `pump(Duration(milliseconds: 500))` gerekebilir.
- Secure-storage metodlarina dokunan testler `localRepositoryProvider`'i `FakeSecureStorage` ile override etmeli.
- Integration testler `integration_test/` altinda — cihaz/emulator gerektirir, `flutter test` ile calismaz.
- `mocktail` mock framework: `test/helpers/mocks.dart`'ta `MockRemoteRepository`, `MockAnalyticsService`, `MockAdManager` hazir. Yeni mock icin buraya ekle.
- CI'da coverage threshold: %70 minimum zorunlu (`flutter_ci.yml`). `flutter test --coverage` ile yerel kontrol.
- CI versioning (L.21): `main`'e push'ta `scripts/version_bump.sh` build number'i git commit count'a esitler. `[skip ci]` ile sonsuz dongu onlenir.
- Dependabot (L.11): `.github/dependabot.yml` — haftalik pub + GitHub Actions taramasi.

### Streak ve Tutorial Sistemi

- `GameConstants.streakRewards`: Milestone map (3→10, 7→50, 14→100, 30→200 Jel Ozu). `HomeScreen.initState` icinde kontrol edilir.
- `LocalRepository.getTutorialDone()/setTutorialDone()`: Ilk oyun tutorial persistence. Tutorial yalnizca `GameMode.classic`'te gosterilir.
- `TutorialOverlay`: 3 adim (sekil sec → onizleme → yerlestir). Hem tap hem drag-and-drop path'lerde ilerler. `game_interactions.dart`'ta `tutorialActive`/`tutorialStep` mixin interface'leri.

### Viral Pipeline

- `ShareManager.shareComboResult()`: Epic combo sonrasi text share (share_plus). Not: share metinleri su anda Turkce hardcoded, l10n yapilmadi.
- `ConfettiEffect`: High score asildiginda 40 particle CustomPaint patlamasi. Oyun basina bir kez tetiklenir (`confettiKey == 0` guard).
- `BombExplosionEffect`: 100ms freeze-frame delay (`Future.delayed`) animasyon oncesi dramatik etki.
- Video export: FFmpeg discontinued, `ClipRecorder` frame yakaliyor ama video uretmiyor.

## Proje Durumu (2026-03-19)

**Scorecard:** 87/100 (P0 + P2 + P3 bagimsiz gorevler + Tier 1 Growth tamamlandi)

| Alan | Puan | En Kritik Sorun |
|------|:----:|-----------------|
| Mimari | 85 | Katman ihlalleri duzeltildi |
| Gameplay | 82 | availableColors + inflasyon eklendi |
| UI/UX | 78 | Tutorial eklendi, Responsive 45/100 |
| QA | 90 | 1295 test, coverage threshold %70, pipeline testleri |
| DevOps | 78 | CI versioning + Dependabot eklendi |
| Backend | 77 | GDPR uyumlulugu (68) |
| Guvenlik | 80 | iOS native pinning eksik |

Detayli gorev listesi ve alt alan puanlari: `_dev/tasks/todo.md`

## Detayli Dokumantasyon

| Dokuman | Amac |
|---|---|
| `_dev/docs/GDD.md` | Game Design Document — mekanikler, monetizasyon, ASO |
| `_dev/docs/TECHNICAL_ARCHITECTURE.md` | Sistem diyagrami, algoritma ornekleri |
| `_dev/tasks/todo.md` | Yol haritasi, scorecard, kalan gorevler (P0-P3 oncelikli) |
| `_dev/tasks/lessons.md` | Sprint bazli dersler ve kurallar |
| `_dev/docs/GROWTH_REPORT.md` | Organik buyume analizi — viral, retention, monetizasyon firsatlari |
