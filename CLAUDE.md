# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**GitHub:** `https://github.com/hsnbilici/Gloo-V1.0.git` (branch: `main`)

## Proje Dokumantasyonu

- `_dev/tasks/todo.md` — Kalan gorevler ve ilerleme takibi
- `_dev/tasks/creative_director_report.md` — Yaratici yonetmen raporu (v0.4, skor 4.1/5.0)
- `_dev/briefs/` — Sanatci/tasarimci brief'leri (karakter, ada, ses, season pass)
- `_dev/docs/GDD.md` — Game Design Document
- `_dev/docs/TECHNICAL_ARCHITECTURE.md` — Teknik mimari dokumani

## Komutlar

```bash
flutter pub get                                # bagimliliklari indir
flutter analyze                                # lint (0 error/warning olmali)
flutter test                                   # tum testler (2155 test)
flutter test --exclude-tags=golden             # CI'da (golden platform-bagimli)
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

- **Flutter SDK** 3.19+ (mevcut: 3.41.5). Dart SDK: `>=3.3.0 <4.0.0`
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
- `features/` — Flutter widget'lari (14 ekran). `game_screen/` 3 part mixin: `game_callbacks.dart`, `game_interactions.dart`, `game_grid_builder.dart`. `GameCellWidget` `ConsumerWidget` — `gridStateProvider.select((s) => s[(row, col)])` ile per-cell rebuild izolasyonu. `CellRenderData` immutable value class, `==`/`hashCode` override.
- `data/` — `local/` (SharedPreferences), `remote/` (Supabase). Tum remote metodlarda `isConfigured` guard zorunlu.
- `services/` — AnalyticsService (Firebase), AdManager, PurchaseService, NotificationService (`FirebaseNotificationService` + `StubNotificationService`). `AudioPackage` enum ile ses paketi swap mekanizmasi.
- `providers/` — Riverpod: game, audio, user, locale, pvp, quest, service, notification providers. `gridStateProvider` — per-cell `CellRenderData` map, `syncGridState()` ile push edilir. `notificationServiceProvider` — `kIsWeb` guard ile stub/firebase secimi.

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

`GlooGame` UI'ya 15+ callback ile bildirir (`onScoreGained`, `onCombo`, `onGameOver`, `onLevelComplete` vb.); Riverpod provider'larini dogrudan cagirmaz.

**Puanlama sabitleri** (`game_constants.dart`): `singleLineClear = 150`, `colorSynthesisBonus = 150`, `mercyLossThreshold = 2`. Coklu satir: 2→400, 3→1000, 4→2000, 5+→2000+(N-4)*1000. Yerlestirme puani: hucre basina 10 (`ScoreSystem.addPlacementScore`).

**Kombo sistemi** (`combo_detector.dart`): Hamle bazli (zaman bazli degil). Ardisik hamlede temizleme → zincir devam eder. Temizleme olmayan hamle → `recordMoveWithoutClear()` ile sifirlanir. Tier'lar: 1-2=small(x1.2), 3-4=medium(x1.5), 5-7=large(x2.0), 8+=epic(x3.0).

**Talent entegrasyonu:** `GlooGame` constructor'i 4 opsiyonel bonus parametresi alir: `betterHandBonus` (double→ShapeGenerator), `colorMasterBonus` (double→ScoreSystem sentez carpani), `fastHandsBonus` (int→TimeTrial ek sure), `zenGuruBonus` (int→Zen modda ek Jel Ozu/satir). `GameScreen.initState`'te `CharacterState`'ten okunup gecilir.

**Game Over ozeti:** `GlooGame` 3 istatistik sayaci tutar: `totalLinesCleared`, `totalSynthesisCount`, `maxComboSize`. Game Over overlay'inde gosterilir + akilli ipucu (sentez/kombo yoksa ogretici tip, max 2 gosterim/tip, toplam 6 gosterim sonrasi durur). Per-stat rekor takibi (`getStatRecord`/`updateStatRecord`) ile "New Record!" altin badge. Colorblind inline prompt (oyun 2-5 arasinda, tek seferlik). Rewarded ad "Free Bomb" butonu (reklam yukluyse).

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
| `themeModeProvider` | `ThemeMode` (system/light/dark) — startup'ta persist'ten yuklenir |
| `questProvider` | Gunluk 3 gorev ilerlemesi (seed-bazli secim, SharedPreferences persist) |
| `lastScoreProvider` | Son skor (sync, family — mod bazli) |
| `maxCompletedLevelProvider` | En yuksek tamamlanan level ID |

### GameMode Enum (7 mod)

`core/models/game_mode.dart`'ta tanimli (saf Dart, Flutter bagimliligi yok). `game_world.dart` re-export eder.

`classic`, `colorChef`, `timeTrial`, `zen` (Gloo+ gerekli), `daily` (seeded), `level` (50+prosedurel), `duel` (120sn, ELO, seeded)

### Hucre ve Izgara

Izgara `List<List<Cell>>` — varsayilan 8x10, Level modunda dinamik (6x6 → 10x12).

**CellType:** `normal`, `ice` (1-2 katman), `locked` (belirli renk), `stone` (engel — komsusundaki satir temizlenince kirilanir), `gravity` (duser), `rainbow` (joker)

### Renk Sistemi

`GelColor` enum 12 renk. Elden yalnizca 4 birincil renk cikar: `red`, `yellow`, `blue`, `white`. 8 sentez rengi birlesimle olusur.

`kColorMixingTable` (`color_constants.dart`): sira bagimsiz arama. Yeni kombinasyon icin yalnizca bu tabloya giris ekle.

`GelColor.shortLabel`: Renk koru modu icin dil bagimsiz kisaltma — degistirilmemeli.

Renk adlari l10n uzerinden: `AppStrings.colorName(GelColor)`. `GelColor` uzerinde `displayName` getter'i yoktur.

UI palet sabitleri `color_constants.dart`'ta (75+ sabit): `kBgDark`, `kCyan`, `kMuted`, `kOrange`, `kModeColors`, `kSurfaceDark`, `kIceBlue`, `kAmber`, `kPowerUp*`, `kGreen`, `kGold`, `kPink`, `kColorDuel` vb. Ekranlarda `Color(0x...)` literal kullanma — `color_constants.dart`'a sabit ekle ve import et. Dosya basinda WCAG AA kontrast matrisi mevcut (53+ renk cifti audit); yeni renk eklerken matrisi guncelle.

Aydinlik tema sabitleri `color_constants_light.dart`'ta: `kBgLight`, `kSurfaceLight`, `kTextPrimaryLight`, `kTextSecondaryLight`, `kCardBgLight`, `kCardBorderLight`, `kMutedLight`, mod renkleri (`kColorClassicLight` vb.). **Tum accent renkler WCAG AA PASS (4.5:1+)** — kGoldLight, kYellowLight, kColorChefLight, kCyanLight, kMutedLight, kOrangeLight koyulastirilerek duzeltildi.

**Theme-aware renk kullanimi:** `resolveColor(brightness, dark: kBgDark, light: kBgLight)` helper'i ile. `brightness = Theme.of(context).brightness` ile alinir. Oyun ekrani her zaman karanlik tema kullanir.

### Responsive Layout

`core/layout/responsive.dart`: Breakpoint sistemi (`phone` <600, `tablet` 600-1023, `desktop` >=1024).

- `responsiveHPadding(width)` → 24/40/64
- `responsiveMaxWidth(width)` → infinity/720/960
- `responsiveColumns(width, phone:, tablet:, desktop:)` → grid sutun sayisi
- `ResponsiveScaffold` widget — tablet/desktop'ta icerik genisligini kisitlar

Tum ekranlar responsive padding ve `Center` + `ConstrainedBox` kullaniyor. GameScreen breakpoint-bazli: phone → mevcut, tablet → 720px, desktop → 960px. HomeScreen ModeCard'lar tablet'te 2-sutun grid (`responsiveColumns(phone: 1, tablet: 2, desktop: 2)` + `IntrinsicHeight` + `Row` + `Expanded`).

### RTL (Sag-Sola) Destegi

`core/layout/rtl_helpers.dart`: Yon bazli yardimcilar.

- `directionalBackIcon(TextDirection)` → LTR'da `arrow_back`, RTL'de `arrow_forward`
- `directionalChevronIcon(TextDirection)` → LTR'da `chevron_right`, RTL'de `chevron_left`
- `directionalGradientAlignment(TextDirection)` → gradient yonu
- Padding icin Flutter'in built-in `EdgeInsetsDirectional.only(start:, end:)` kullanilir

Tum 13 ekran + 2 widget dosyasi RTL-safe. Dekoratif arkaplan elementleri (`Positioned`) RTL cevirisi gerektirmez.

### Theme (Karanlik/Aydinlik Tema)

`providers/theme_provider.dart`: `themeModeProvider` — `ThemeMode.dark` varsayilan. `LoadingScreen._runInit()` icinde `SharedPreferences`'tan yuklenir. System tema secenegi Settings'te gizli ama fonksiyonel.

`app.dart`'ta `theme:` (light) + `darkTheme:` (dark) + `themeMode:` yapisi. Settings ekraninda `ThemeSelectorTile` + `ThemeSheet` ile secim yapilir, `LocalRepository.setThemeMode()` ile persist edilir.

### Loading Screen

`lib/features/loading/loading_screen.dart`: Animasyonlu in-app loading — native splash sonrasi, HomeScreen oncesi. 4 jel harf (G=kCyan, L=kGold, O=kPink, O=kCyan) staggered drop-in + nefes animasyonu. `_runInit()` ile servis baslatma (Supabase, Audio, AdManager, PurchaseService, tema/ses paketi yukleme) — `main.dart`'tan tasinmis. Sahte progress: 0→0.8 (2sn) + init bitince 0.8→1.0 (300ms). Min 2sn gosterim. Reduce motion: statik harfler, animasyonsuz. Cikis: `context.go('/')` veya `/onboarding`.

### Routing

GoRouter (`lib/app/router.dart`). `initialLocation: '/loading'`. **ONEMLI:** Spesifik rotalar genel `/game/:mode`'dan ONCE tanimlanmali:
1. `/loading` (loading screen)
2. `/game/level/:levelId`
2. `/game/duel`
3. `/game/:mode` (generic)

`GameMode.fromString()` gecersiz degerleri `classic`'e dusurur. `_SoundNavigatorObserver` ile ekran gecislerinde ses caliniyor.

### Dialog Gecisleri

`fadeScaleTransition` (`ui_constants.dart`): Tum `showGeneralDialog` transition builder'lari icin paylasilmis FadeTransition + ScaleTransition helper. Yeni dialog eklerken bunu kullan, inline transition builder yazma.

### UI Sabitleri (`ui_constants.dart`)

- `AnimationDurations` abstract final class — 17 named duration sabiti (80ms→2500ms). Magic number yerine bunu kullan: `AnimationDurations.quick`, `.dialog`, `.waveClear`, `.toast`, `.breathCycle`, `.synthesisPulse` vb.
- `Spacing` abstract final class — 8 dikey bosluk sabiti (xxs=2 → xxxl=32). `SizedBox(height: 16)` yerine `SizedBox(height: Spacing.lg)` kullan.
- `AppTextStyles` abstract final class — 8 semantik text style (displayLarge 32px → micro 9px). Display/heading tier (displayLarge, heading, subheading) `fontFamily: 'Syne'` (marka fontu). Body/label tier (body, bodySecondary, label, caption, micro) platform default font (CJK/Kiril/Arapca uyumu). Inline `TextStyle(fontSize: 18, fontWeight: FontWeight.w800)` yerine `AppTextStyles.heading` kullan.
- `kAppName` (`app_constants.dart`) — Marka adi sabiti. Hardcoded `'GLOO'` yerine bunu kullan.

### GameEffectManager

`game_effect_manager.dart`: Merkezi `AnimationController` yonetimi. `GameScreen.initState`'te olusturulur. Lazy controller pattern: nullable `_ctrl?` + `_ensureController()` — controller yalnizca animasyon gerektiginde allocate edilir. `CellRenderData.copyWith()` ile reconstruction — yeni boolean flag eklerken flag kaybi riski onlendi.

### ShapeGenerator

`ShapeGenerator` instance-based. Stateful metodlar instance uzerinden, stateless (getDifficulty, generateSeededHand, todaySeed) static. Testlerde `ShapeGenerator(rng: Random(42))` ile izole state. `availableColors` opsiyonel — `null` → `kPrimaryColors`. `betterHandBonus` talent sisteminden gelir, seeded modlarda (Daily/Duel) gecerli degil.

**Yeni oyuncu korumasi:** `gamesPlayed < 5` ise kademeli zorluk rampi. Level/Daily/Duel muaf. ColorChef ayri agirliklar (sentez firsati icin). **Ilk oyun:** `gamesPlayed == 0 && classic` ise ilk el red+yellow+red → dogal sentez kesfi. **Siradaki sekil silueti:** `gamesPlayed < 5` ise null (bilissel yuk azaltma), peek power-up aktifken gizli.

### Level 41-50 Dengesi

Seviye 41-50 hedef skorlari %25-30 dusuruldu ve hamle sinirlari genisletildi (orn: Seviye 49: 1700→1250, 28→38 hamle). Yeni puanlama sistemiyle bu hedefler kolaylastirildi — playtest'te tekrar kalibrasyon gerekebilir.

### PvP Engel Sistemi

Epic kombo engeli 4-5 rastgele buz gonderir. Bot engelleri difficulty'ye bagli: count `(1+difficulty*3).clamp(1,4)`, interval `(20-difficulty*8).clamp(12,20)` saniye. `areaSize` parametresi artik kullanilmiyor — tum engeller `applyRandomObstacle` path'ine dusur. Stone hucreler kirilabilir: komsu satir/sutun temizlenince `GridManager.breakAdjacentStones()` ile kirilanir + `onStoneBroken` callback.

### Adaptif Zorluk (CD.28)

`lib/game/systems/skill_profile.dart`: Cok boyutlu beceri profili — 4 eksen (gridEfficiency, synthesisSkill, comboSkill, pressureResilience), son 10 oyun ring buffer, 0.0-1.0 normalize. Ilk 3 oyunda kalibrasyon (0.5 nötr). 7+ gün inaktivitede %20 merkeze soguma.

`lib/game/systems/adaptive_difficulty.dart`: `DifficultyModifiers` — profil → 4 kaldıraç (smallShapeBonus, largeShapeBonus, synthesisFriendly, comboSetup, pressureMercy). 0.3-0.7 nötr bant, uçlarda yumuşak interpolasyon.

`ShapeGenerator.adaptiveModifiers`: Serbest modlarda (Classic, ColorChef, TimeTrial, Zen) aktif. Level/Daily/Duel muaf (seeded/kendi eğrisi). Profil tüm modlardan beslenir. Mevcut merhamet (3 kayıp, 5 hamle) korunur — adaptif üstüne eklenir.

`SkillRadarChart` (`lib/features/shared/`): 4 köşeli radar chart, CharacterScreen'de. kCyan dolgu, 3 halka grid. Semantics + reduce motion uyumlu.

### Cascade Pacing

`onCascadeStep(int step, int linesCleared)` callback — staggered SFX + artan pitch. Reduce Motion aktifken delay 0.

### Dinamik K-Factor ELO

`EloSystem.getKFactor(playerElo)`: <800→K=40, 800-1199→K=32, 1200-1599→K=28, 1600+→K=24. Client (`matchmaking.dart`) ve server (`calculate-elo/index.ts`) senkron — her iki dosyanin basinda SYNC uyarisi var. Bot maclarinda ELO kazanimi %50 azaltilir (kayip tam).

### Preview-time Line Completion Hint

`syncGridState()`'te preview + mevcut hucreler satiri tamamlayacaksa `isCompletionPreview: true` → yesil border + tint.

### Drag-and-Drop Projeksiyon

`shape_hand.dart` + `game_grid_builder.dart` + `clampAnchor()` (`game_interactions.dart`). Sekil nereden tutulursa tutulsun iz dusum dogru olusur. Feedback widget grid hucre boyutuna oranli scale (`gridCellSize / ShapePreview.cellSize`, clamp 1.2-3.0x). Drag lifecycle haptic'leri: `dragStart` (selectionClick), `dragSnap` (lightImpact — anchor degisiminde), `dragInvalid` (double mediumImpact + nearMissTension SFX — gecersiz birakma/iptal). `_PlacementFadeIn`: preview alpha'dan (0.50) tam opakliga 180ms fade-in gecisi (`game_cell_widget.dart`).

### DuelState.copyWith Sentinel Deseni

Nullable alanlar icin `_Absent` sentinel — `copyWith(matchId: null)` (null yap) vs `copyWith()` (degistirme) ayrimi.

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
- 33+ dosyada Semantics widget'lari mevcut. Yeni ekran eklerken her interaktif elemana `Semantics(label:, button: true)` ekle.
- `SemanticsService.sendAnnouncement(View.of(context), msg, dir)` ile kritik geri bildirimler (toast, combo medium+, near-miss, game over, level complete) ekran okuyucuya duyurulur. `showToast(msg, {a11yAnnouncement})` opsiyonel ayri a11y metni destekler.
- Dekoratif elemanlar (GlowOrb, gradient overlay, efektler) `ExcludeSemantics` ile sarilir. `GlowOrb` widget'i kaynaginda sarili — tum kullanim noktalari otomatik kapsanir.
- Grid hucre semantics label'lari lokalize: `l.semanticsCellEmpty`, `l.semanticsCellIce` (+ layer sayisi), `l.semanticsCellStone` vb. Dolu hucreler `l.colorName(color)` ile lokalize renk adi kullanir. Power-up label'lari: `l.semanticsPowerUpRotate` vb.
- 44dp minimum tap target testi `semantics_coverage_test.dart`'ta dogrulanir.
- `MediaQuery.textScalerOf(context).scale(fontSize)` ile dinamik font boyutlama — 9 lokasyonda aktif. Oyun grid cell'leri muaf.

### Platform Guard'lar
- `main.dart`: Certificate pinning, Firebase init, orientation, splash remove. Agir init'ler (Supabase, Audio, AdManager, PurchaseService, tema) `LoadingScreen._runInit()` icine tasindi.
- `LoadingScreen`: Servis baslatma orchestration — ConsentService, Future.wait paralel init, IAP pending verification, tema/ses paketi yukleme. `kIsWeb` guard'lar mevcut.
- `AndroidManifest.xml`: AdMob App ID zorunlu — olmadan FATAL EXCEPTION. Simdi test ID aktif.
- Web uyumsuz paketler: `google_mobile_ads`. `just_audio` web-uyumlu. `ffmpeg_kit_flutter` ve `screen_recorder` kaldirildi.

### Veri Katmani
- `LocalRepository`: SharedPreferences + `flutter_secure_storage`. Hassas veriler (elo, gel_ozu, gel_energy, pvp_wins/losses, unlocked_products, pending_verification, redeemed_codes) SecureStorage'da sifreleniyor. Migration fallback: SecureStorage'da yoksa SharedPreferences'tan okur. Constructor opsiyonel `SecureStorageInterface` alir — testlerde `FakeSecureStorage` kullanilir. `SecureStorageImpl.write(null)` anahtari siler (`delete`), bos string yazmaz. **Test notu:** Secure-storage metodlarina (getElo vb.) dokunan testler `localRepositoryProvider`'i `FakeSecureStorage` ile override etmeli — aksi halde `MissingPluginException`.
- `RemoteRepository`: Supabase. Tum metodlarda `isConfigured` guard ve try-catch zorunlu. `kDebugMode` guard'li debugPrint. `submitScore`/`submitPvpResult` icin `_retry()` ile exponential backoff (3 deneme).
- `PvpRealtimeService`: Supabase Realtime (Presence + Broadcast). Duplicate match onlemi: leksikografik ID karsilastirmasi. Otomatik reconnection: exponential backoff (1s * 2^attempts, max 5 deneme). `leaveDuelRoom()` ve `dispose()` reconnection state'ini temizler.
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
- `AudioManager` (`lib/audio/audio_manager.dart`): Singleton. `assets/audio/sfx/` (32 dosya) ve `assets/audio/music/` (4 dosya). 8 kanal SFX havuzu (round-robin), pitch varyasyonu (0.92-1.08x). `main.dart`'ta `Future.wait` icinde `initialize()` cagriliyor (iOS audio session). Dosya bulunamazsa sessizce atlar.
- `.ogg` iOS'ta native desteklenmez — `.ogg` + `.m4a` ikili format. Web'de `kIsWeb` guard ile `.m4a` fallback (Safari .ogg desteklemez).
- `HapticManager`: 17 haptic profil (14 temel + 3 drag: `dragStart`, `dragSnap`, `dragInvalid`).
- **SoundBank** (`lib/audio/sound_bank.dart`): 22 metod (19 temel + 3 drag: `onDragStart`, `onDragSnap`, `onDragInvalid`). Game callback'leri `game_callbacks.dart`'ta, power-up'lar `game_interactions.dart`'ta, PvP `game_duel_controller.dart`'ta baglanmis.
- **Muzik**: `AudioPaths.musicForMode(GameMode)` ile mod-bazli secim. HomeScreen gece (21:00-06:00) `menu_chill`, gunduz `menu_lofi`. Grid %70+→`tension_escalation` crossfade (hysteresis %60 geri). Game Over'da `fadeOutMusic`. Replay'de `resumeMusic()`.
- **Sessizlik gap'leri**: Dramatik etki icin SFX oncesi `Future.delayed` (game_over, combo_epic, level_complete).
- **Adaptif muzik**: Grid doluluk crossfade, son saniye tempo artisi, kombo volume swell, bomba ducking.
- **Debounce/Guard**: GelOzu SFX, ice/gravity, combo swell, fade icin guard'lar mevcut.
- **UI sesleri**: Ekran gecislerinde `_SoundNavigatorObserver` ile ses.

## l10n

12 dil: `en` (fallback), `tr`, `de`, `zh`, `ja`, `ko`, `ru`, `es`, `ar`, `fr`, `hi`, `pt`

```dart
final l = ref.watch(stringsProvider);
Text(l.scoreLabel)
```

Yeni string eklemek: (1) `app_strings.dart`'a abstract getter, (2) tum 12 `strings_*.dart`'a override, (3) cevirileri dogrula. Renk adlari icin `AppStrings.colorName(GelColor)` helper metodu mevcut. ELO lig isimleri icin `EloLeague.leagueName(AppStrings l)` metodu kullanilir — `displayName` getter'i kaldirildi. `eloDisplay(int elo)` interpolated metod ile her dil kendi kelime sirasini koruyor. Mod flavor text'leri `modeClassicFlavor` vb. ile mod isimlerine dunya dili alt basligi. Kisilik isimleri `personalityOrange` vb. ile 8 arketip 12 dilde. `kColorChefLevels`: 40 bolum (20→40 genisletildi, 4 zorluk bandinda kademeli artis).

## Linting

`flutter_lints` temel. Ek kurallar: `prefer_single_quotes`, `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_fields`, `sort_child_properties_last`, `use_super_parameters`, `avoid_print`, `always_declare_return_types`.

0 error, 0 warning. `dart format lib/ test/` ile format kontrol edilir.

## Monetizasyon

- **Zen modu**: Gloo+ abonelik ile kilitli
- **AdManager**: Interstitial (4 oyunda 1), rewarded (ikinci sans), banner. Anti-frustration: 5dk'da 2 kayip → reklam yok. Test ID'ler aktif.
- **PurchaseService**: 10 IAP urunu (5 non-consumable + 3 subscription + 2 consumable: `jel_ozu_100`, `jel_ozu_500`). Sunucu tarafinda receipt dogrulama (Supabase Edge Function). `_pendingVerification` `Map<String, String>` (productId → receipt) olarak JSON formatinda SharedPreferences'a persist ediliyor; app restart'ta gercek receipt ile otomatik retry. Abonelik expiry kontrolu `restorePurchases()` + `syncLocalProducts()` ile yapilir.
- **Redeem Code**: `ShopScreen` → `RemoteRepository.redeemCode()` → Supabase Edge Function → `PurchaseService.unlockProducts()`
- **Shop mimarisi**: 4-tab `TabBar` + `TabBarView`: Gloo+ (kGold), Jel Ozu (kCyan), Premium (kColorZen), Promo Kodu (kGreen). `_ColoredUnderlineIndicator` ile tab-bazli accent renk + swipe'ta `Color.lerp` interpolasyonu. Restore Purchases persistent footer (tab-bagimsiz).
- **Ekonomi inflasyonu:** `CurrencyManager.inflatedCost(baseCost)` — `(1 + lifetimeEarnings / 1000).clamp(1.0, cap)`. Normal oyuncular 2.0x cap, Gloo+ aboneleri 1.5x cap. `PowerUpSystem.getEffectiveCost(type)` ve `canUse()`/`_activate()` inflated cost kullanir. Toolbar'da baz maliyet ustu cizgili + amber enflasyonlu maliyet gosterilir.
- **Gloo+ bonus:** `CurrencyManager.isGlooPlus` flag'i `true` ise tum `_earn()` cagrilarinda %50 bonus uygulanir + Season Pass XP 2x. `GameScreen.initState`'te `appSettingsProvider.glooPlus`'tan okunur.
- **Level odulleri:** Level tamamlamada `min(levelId * 2, 30)` Jel Ozu (Gloo+ bonus otomatik).
- **Season Pass XP:** Game Over'da `max(10, score ~/ 100)` XP. Gloo+'ta 2x. `SeasonPassState.addXp()` ile.
- **Streak Freeze:** `CurrencyCosts.streakFreeze = 100`. `hasStreakFreeze()`/`setStreakFreeze()` SharedPreferences. Seri kirilacakken otomatik tuketilir. HomeScreen'de satin alma butonu.

### Test Uyarilari
- `flutter_animate` kullanan widget'lar `pumpAndSettle()` timeout'a neden olur — `pump(Duration)` kullan. Scroll'da yeni inflate olan widget'lar icin birden fazla `pump(Duration(milliseconds: 500))` gerekebilir.
- Secure-storage metodlarina dokunan testler `localRepositoryProvider`'i `FakeSecureStorage` ile override etmeli.
- Integration testler `integration_test/` altinda — cihaz/emulator gerektirir, `flutter test` ile calismaz.
- `mocktail` mock framework: `test/helpers/mocks.dart`'ta `MockRemoteRepository`, `MockAnalyticsService`, `MockAdManager` hazir. Yeni mock icin buraya ekle.
- CI'da coverage threshold: %60 minimum zorunlu (`flutter_ci.yml`). `flutter test --coverage` ile yerel kontrol.
- CI versioning (L.21): `main`'e push'ta `scripts/version_bump.sh` build number'i git commit count'a esitler. `[skip ci]` ile sonsuz dongu onlenir.
- Dependabot (L.11): `.github/dependabot.yml` — haftalik pub + GitHub Actions taramasi.
- CI iOS build (`ios_build.yml`): `macos-15` runner + explicit `xcode-select` + `fetch-depth: 0` (version_bump icin). Tum CI workflow'larinda Slack notification curl-based (shell `if [ -z "$SLACK_WEBHOOK_URL" ]` guard ile graceful skip).
- Web deploy (`web_build.yml`): GitHub Pages deploy job — `actions/deploy-pages@v4`.
- SBOM (`sbom.yml`): Syft ile SPDX + CycloneDX JSON, pubspec degisikliklerinde tetiklenir.

### Supabase Edge Functions

- **`update-elo`**: Server-side ELO hesaplama (dinamik K-Factor: <800→40, 800-1199→32, 1200-1599→28, 1600+→24). `pvp_matches` tablosundan opponent resolve, rate limiting (3/dk/user), `elo_updates` audit tablosu. Bot maclarinda fallback: dogrudan profile guncelle.
- **`verify-purchase`**: IAP receipt dogrulama. Android: Google Play Developer API v3 (purchaseToken). iOS: App Store Server API v2 (transactionId). Credentials yoksa graceful fallback. `purchase_verifications` audit tablosu.
- **`redeem-code`**: Promosyon kodu dogrulama ve urun kilit acma.
- **`get_user_rank` (SQL RPC)**: `supabase/migrations/20260322_fix_leaderboard.sql` — PL/pgSQL function, unique kullanici bazli rank hesaplar. Weekly filtre hem kendi skora hem rank'e uygulanir. `RemoteRepository.getUserRank()` bunu kullanir.
- **`leaderboard_view`** (SQL View): SECURITY DEFINER, `DISTINCT ON (user_id, mode)` — kullanici basina en iyi skor. `profiles` RLS'i bypass eder.
- **`elo_leaderboard_view`** (SQL View): SECURITY DEFINER — PvP ELO siralamasi icin `profiles` RLS bypass. `RemoteRepository.getEloLeaderboard()` bunu kullanir.

### GDPR Veri Export

`LocalRepository.exportAllData()` → `Future<Map<String, dynamic>>` (scores, stats, currency, progress, pvp, streak, collections, daily_puzzle). Settings'te `ExportDataTile` → JSON dosyasi `Share.shareXFiles` ile paylasilir.

### Streak ve Tutorial Sistemi

- `GameConstants.streakRewards`: Milestone map (3→10, 7→50, 14→100, 30→200 Jel Ozu). `HomeScreen.initState` icinde kontrol edilir.
- `LocalRepository.getTutorialDone()/setTutorialDone()`: Ilk oyun tutorial persistence. Tutorial yalnizca `GameMode.classic`'te gosterilir.
- `TutorialOverlay`: 3 adim (sekil sec → onizleme → yerlestir). Hem tap hem drag-and-drop path'lerde ilerler. `game_interactions.dart`'ta `tutorialActive`/`tutorialStep` mixin interface'leri. Skip butonu tum adimlarda mevcut.

### Ilk Acilis Akisi

Onboarding 5 sayfa (3 tanitim + 1 lore + 1 tercihler) → HomeScreen. GDPR: consent yalnizca 5. sayfaya ulasirsa kaydedilir. Skip → HomeScreen dialog akisi: (1) ConsentDialog, (2) ATT (iOS). `_continueStartupFlow()` `repo.getConsentShown()` kontrol eder. Colorblind prompt Game Over'da oyun 2-5 arasinda (inline, tek seferlik).

### Viral Pipeline

- `ShareManager`: Tum share metodlari `AppStrings l` parametresi alir, 12 dile lokalize.
- `ConfettiEffect`: High score'da tek seferlik (`confettiKey == 0` guard).
- `BombExplosionEffect`: Freeze-frame delay sonra animasyon.

### HomeScreen Ozellikleri

- `_ClassicScoreChip`: Son skor + rekor. "So close" state (lastScore >= highScore * 0.8). `LocalRepository.getLastScore/saveLastScore`.
- `_LevelProgressChip` / `_DuelEloChip`: Per-mode progress, deger 0 ise gizli.
- `_QuickPlayBanner`: Son oynanan mod, `gamesPlayed < 3` ise gizli, kilitli modlar filtrelenir.
- **Progressive Mod Acilimi:** ColorChef 3, TimeTrial 5 oyun sonra acilir.

### Gorev Sistemi

`quest_provider.dart`: Gunluk 3 + haftalik 5 gorev (`quest.id` bazli progress key, ISO week reset). 6 tip: `clearLines`, `reachScore`, `playGames`, `makeSyntheses`, `reachCombo`, `completeDailyPuzzle`. `QuestBar` HomeScreen'de progress bar gosterir, Daily puzzle kisayolu QuestBar'a gomulu. `game_callbacks.dart`'ta 6 callback'e entegre. Tamamlanan gorev Jel Ozu odulu verir.

### MetaGameBar

`meta_game_bar.dart`: Ada/Karakter/SeasonPass navigasyonu → `/island`, `/character`, `/season-pass`. `GelPersonality`: 8 sentez rengine kisilik arketipleri. Ada core loop: Game over'da pasif Jel uretimi. `Building.costForLevel` exponential formul.

### Hover/Focus/Press Destegi (Web/Desktop)

- Hover: `MouseRegion` + `_hovered` state. `AnimatedContainer` kullanMAZ — plain `Container` + `AnimatedScale`.
- **Press:** `AnimatedScale(scale: _pressed ? 0.96 : 1.0, duration: 80ms)` standardi.
- **Keyboard focus:** `FocusableActionDetector`, focus ring: `kCyan`, 2px border.
- **Portrait kilitleme:** `kIsWeb` guard ile (web'de serbest).

### Reduce Motion

`shouldReduceMotion(BuildContext)` (`motion_utils.dart`). `animateOrSkip()` extension `flutter_animate` uzerinde. Tum ekranlarda kullanilir.

### Level Sistemi

- Level 1-10: `microTask` ile ogretim. Level 51+: prosedural (4 temali kisitlama dongusu, 200'e kadar).
- **Ascension:** Level 50 sonrasi tier'lar. Hedef skor +%25/tier, hamle -%10/tier (cap -%50).
- **Collection Odulleri:** 8 sentez rengi tamamlandiginda +50 Jel Ozu (tek seferlik).

### Leaderboard Sistemi

3 tab: Classic, TimeTrial, PvP ELO. SQL view'lar (SECURITY DEFINER) `profiles` RLS'i bypass eder. `_currentMode` enum case-sensitive. PvP skorlari `l.eloDisplay(elo)` ile lokalize. **Username sync:** Settings'te isim degisikligi `ensureProfile(username:)` ile Supabase'e senkronize edilmeli — aksi halde leaderboard eski ismi gosterir.

### Notification Service

`NotificationService` abstract + `StubNotificationService` (web) + `FirebaseNotificationService` (native). 3 senaryo: `streakReminder` (20:00), `dailyPuzzle` (10:00), `comeback` (3 gun inaktif). FCM token Supabase `device_tokens`'a sync edilir. **iOS:** `aps-environment: development` — release icin `production`'a cevirilmeli. **Harici:** APNs p8 key Firebase'e yuklenmeli.

### Ses Paketi Sistemi

`AudioPackage` enum (`audio_constants.dart`): `standard`, `crystalAsmr`, `deepForest`. `AudioPaths.resolveSfxPath(baseName, package)` ile paket-bazli asset path. `AudioManager.setAudioPackage(package)` ile runtime degistirme — SFX cache temizlenir, sonraki play yeni path'ten yukler. Fallback: paket dosyasi yoksa standard path'e doner. `LocalRepository.getAudioPackage()`/`saveAudioPackage()` ile persist. `main.dart`'ta startup'ta yuklenir.
