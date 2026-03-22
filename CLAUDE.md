# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**GitHub:** `https://github.com/hsnbilici/Gloo-V1.0.git` (branch: `main`)

## Komutlar

```bash
flutter pub get                                # bagimliliklari indir
flutter analyze                                # lint (0 error/warning olmali)
flutter test                                   # tum testler (2151 test)
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
- `features/` — Flutter widget'lari (14 ekran). `game_screen/` 3 part mixin ile bolunmus: `game_callbacks.dart`, `game_interactions.dart`, `game_grid_builder.dart`. `shop/` 1 part mixin: `shop_logic.dart`. Ek: `tutorial_overlay.dart`, `share_prompt_dialog.dart`, `effects/confetti_effect.dart`. `GameCellWidget` bir `ConsumerWidget` — `gridStateProvider.select((s) => s[(row, col)])` ile per-cell rebuild izolasyonu saglar. `CellRenderData` immutable value class (`cell_render_data.dart`) diff icin `==`/`hashCode` override eder.
- `data/` — `local/` (SharedPreferences), `remote/` (Supabase). Tum remote metodlarda `isConfigured` guard zorunlu.
- `services/` — AnalyticsService (Firebase), AdManager, PurchaseService, NotificationService (`FirebaseNotificationService` + `StubNotificationService`). `AudioPackage` enum ile ses paketi swap mekanizmasi.
- `providers/` — Riverpod: game, audio, user, locale, pvp, quest, service, notification providers. `gridStateProvider` (`grid_state_provider.dart`) — `GridStateNotifier` ile per-cell `CellRenderData` map'i tutar; `syncGridState()` ile `game_grid_builder.dart`'tan push edilir. `CellRenderData.copyWith()` ile reconstruction bloklari sadelesti. `questProvider` — gunluk 3 + haftalik 5 gorev ilerlemesi (ISO week bazli reset, `quest.id` bazli progress key). `maxCompletedLevelProvider` — level ilerleme durumu. `notificationServiceProvider` — `kIsWeb` guard ile stub/firebase secimi.

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

`providers/theme_provider.dart`: `themeModeProvider` — `ThemeMode.dark` varsayilan. `main.dart`'ta `SharedPreferences`'tan yuklenir (`overrideWith`), ilk frame'den itibaren dogru tema aktif (flash yok). System tema secenegi Settings'te gizli ama fonksiyonel.

`app.dart`'ta `theme:` (light) + `darkTheme:` (dark) + `themeMode:` yapisi. Settings ekraninda `ThemeSelectorTile` + `ThemeSheet` ile secim yapilir, `LocalRepository.setThemeMode()` ile persist edilir.

### Routing

GoRouter (`lib/app/router.dart`). **ONEMLI:** Spesifik rotalar genel `/game/:mode`'dan ONCE tanimlanmali:
1. `/game/level/:levelId`
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

`game_effect_manager.dart`: Merkezi `AnimationController` yonetimi. `breathCtrl` (nefes animasyonu) sahiplenir, gecici efektler icin `createTransient()` factory. `GameScreen.initState`'te `effectManager = GameEffectManager(this)` ile olusturulur. SquashStretchCell/WaveRipple/SynthesisPulseCell lazy controller pattern kullanir: nullable `_ctrl?` + `_ensureController()` factory — controller yalnizca animasyon gerektiginde allocate edilir. `SynthesisPulseCell`: sentez aninda 300ms scale pulse (1.0→1.08→1.0, `easeOutBack`). `GelCellPainter.isGlowing`: sentez hucresinde specular 0.90, glow blur 12, cache invalidation `_cachedGlowState` ile.

### ShapeGenerator

`ShapeGenerator` instance-based (M.17). `GlooGame` constructor'inda opsiyonel: `GlooGame({..., ShapeGenerator? shapeGenerator})`. Stateful metodlar (generateSmartHand, recordLoss/Win/Clear) instance uzerinden. Stateless metodlar (getDifficulty, generateSeededHand, todaySeed) static kalir. Testlerde izole state icin `ShapeGenerator(rng: Random(42))` kullanilabilir.

`availableColors` (L.15): `generateSmartHand`, `generateSeededHand` ve tum ic renk secim metodlari opsiyonel `List<GelColor>? availableColors` parametresi alir. `null` → `kPrimaryColors` (4 birincil renk). `GlooGame.generateNextHand()` bu degeri `levelData?.availableColors`'dan alir. Level modunda per-level renk kisitlamasi mumkun.

`betterHandBonus` (double): `ShapeGenerator` constructor parametresi. Talent sisteminden gelir. `_weightedRandomShape`'te kucuk sekil olasiligini artirip buyuk sekli azaltir. Seeded modlarda (Daily/Duel) gecerli degil.

**Yeni oyuncu korumasi:** `gamesPlayed < 5` ise kademeli ramp: oyun 0-2 → %80/%15/%5, oyun 3 → %70/%20/%10, oyun 4 → %55/%30/%15, oyun 5+ → normal. Level, Daily, Duel modlari muaf (kendi zorluk egrisi/seed'i var). ColorChef modunda ayri agirliklar: %35 kucuk / %50 orta / %15 buyuk (sentez firsati icin, zorluktan bagimsiz).

**Ilk oyun kesfi:** `gamesPlayed == 0 && classic && grid bos` ise ilk el red+yellow+red zorlanir → dogal sentez kesfi (orange).

**Siradaki sekil silueti:** `GlooGame.nextShapeSilhouette` — her `generateNextHand()` sonrasi bir sonraki el icin sekil silueti on-uretilir. `gamesPlayed < 5` ise null (bilissel yuk azaltma). Peek power-up aktifken gizli. `ShapeHand` widget'inda 36x36 muted preview olarak gosterilir.

### Level 41-50 Dengesi

Seviye 41-50 hedef skorlari %25-30 dusuruldu ve hamle sinirlari genisletildi (orn: Seviye 49: 1700→1250, 28→38 hamle). Yeni puanlama sistemiyle bu hedefler kolaylastirildi — playtest'te tekrar kalibrasyon gerekebilir.

### PvP Engel Sistemi

Epic kombo engeli 4-5 rastgele buz gonderir. Bot engelleri difficulty'ye bagli: count `(1+difficulty*3).clamp(1,4)`, interval `(20-difficulty*8).clamp(12,20)` saniye. `areaSize` parametresi artik kullanilmiyor — tum engeller `applyRandomObstacle` path'ine dusur. Stone hucreler kirilabilir: komsu satir/sutun temizlenince `GridManager.breakAdjacentStones()` ile kirilanir + `onStoneBroken` callback.

### Cascade Pacing

`onCascadeStep(int step, int linesCleared)` callback — her cascade adiminda fire eder. UI katmaninda `step * 180ms` delay ile staggered SFX. Reduce Motion aktifken delay 0. `SoundBank.onLineClear(lines:, pitch:)` ile artan pitch: `1.0 + (step-1) * 0.08`, cap 1.3x. `AudioManager.playSfx(speed:)` opsiyonel speed parametresi.

### Dinamik K-Factor ELO

`EloSystem.getKFactor(playerElo)`: <800→K=40, 800-1199→K=32, 1200-1599→K=28, 1600+→K=24. Client (`matchmaking.dart`) ve server (`calculate-elo/index.ts`) senkron — her iki dosyanin basinda SYNC uyarisi var. Bot maclarinda ELO kazanimi %50 azaltilir (kayip tam).

### Preview-time Line Completion Hint

`syncGridState()`'te preview hucreleri aktifken, her satir icin preview + mevcut hucrelerin satiri tamamlayip tamamlamadigi kontrol edilir. Tamamlayacaksa `isCompletionPreview: true` ile yesil border + tint gosterilir.

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
- 33+ dosyada Semantics widget'lari mevcut. Yeni ekran eklerken her interaktif elemana `Semantics(label:, button: true)` ekle.
- `SemanticsService.sendAnnouncement(View.of(context), msg, dir)` ile kritik geri bildirimler (toast, combo medium+, near-miss, game over, level complete) ekran okuyucuya duyurulur. `showToast(msg, {a11yAnnouncement})` opsiyonel ayri a11y metni destekler.
- Dekoratif elemanlar (GlowOrb, gradient overlay, efektler) `ExcludeSemantics` ile sarilir. `GlowOrb` widget'i kaynaginda sarili — tum kullanim noktalari otomatik kapsanir.
- Grid hucre semantics label'lari lokalize: `l.semanticsCellEmpty`, `l.semanticsCellIce` (+ layer sayisi), `l.semanticsCellStone` vb. Dolu hucreler `l.colorName(color)` ile lokalize renk adi kullanir. Power-up label'lari: `l.semanticsPowerUpRotate` vb.
- 44dp minimum tap target testi `semantics_coverage_test.dart`'ta dogrulanir.
- `MediaQuery.textScalerOf(context).scale(fontSize)` ile dinamik font boyutlama — 9 lokasyonda aktif. Oyun grid cell'leri muaf.

### Platform Guard'lar
- `main.dart`: Certificate pinning (`HttpOverrides.global`), Firebase init try-catch sarili. Supabase init try-catch. AdManager + PurchaseService `kIsWeb` guard. iOS `edgeToEdge`, diger `immersiveSticky`.
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
- `HapticManager`: 14 haptic profil, tam implementasyon.
- **SoundBank** (`lib/audio/sound_bank.dart`): 19 metod, %100 tetikleniyor. Tum game callback'leri `game_callbacks.dart`'ta, power-up'lar `game_interactions.dart`'ta, PvP `game_duel_controller.dart`'ta baglanmis.
  - Oyun: `onGelPlaced`, `onGelMerge(mergeCount:)`, `onLineClear(lines:, pitch:)`, `onCombo(combo)`, `onSynthesis`, `onNearMiss(survived:)`, `onGameOver`, `onLevelComplete`, `onGelOzuEarn`
  - Power-up: `onPowerUpActivate`, `onBombExplosion`, `onRotate`, `onUndo`, `onFreeze`
  - PvP: `onPvpVictory`, `onPvpDefeat`, `onPvpObstacleSent`, `onPvpObstacleReceived`
  - Ozel: `onIceBreak`, `onGravityDrop`, `onStoneBroken`, `onButtonTap`
- **Muzik**: Mod bazli — HomeScreen: `menu_lofi`, Zen: `zen_ambient`, TimeTrial/Duel: `game_tension`, diger: `game_relax`. Game Over'da `fadeOutMusic(800ms)`. Replay'de `resumeMusic()`.
- **Adaptif muzik**: (1) Grid %70+ doluyken `crossfadeMusic()` ile relax→tension gecisi (hysteresis %60 geri), (2) Duel son 30sn / TimeTrial son 15sn muzik tempo 1.15x, (3) Epic/large kombo muzik volume swell (0.4→0.6, 800ms), (4) Epic/large kombo + bomba ducking (%50 volume, 500ms).
- **Debounce/Guard**: GelOzu SFX (300ms Timer), ice/gravity (50ms timestamp), combo swell (iptal edilebilir Timer), fade (`_isFading` flag + `finally`).
- **UI sesleri**: HomeScreen (6 ModeCard), Settings (6 toggle), Shop (buy), LevelSelect (level cell). Ekran gecislerinde GoRouter `_SoundNavigatorObserver` ile `undo_whoosh` (%40 vol).

## l10n

12 dil: `en` (fallback), `tr`, `de`, `zh`, `ja`, `ko`, `ru`, `es`, `ar`, `fr`, `hi`, `pt`

```dart
final l = ref.watch(stringsProvider);
Text(l.scoreLabel)
```

Yeni string eklemek: (1) `app_strings.dart`'a abstract getter, (2) tum 12 `strings_*.dart`'a override, (3) cevirileri dogrula. Renk adlari icin `AppStrings.colorName(GelColor)` helper metodu mevcut. ELO lig isimleri icin `EloLeague.leagueName(AppStrings l)` metodu kullanilir (L.18) — `displayName` getter'i kaldirildi.

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

Onboarding (4 sayfa: 3 tanitim + 1 tercihler) → HomeScreen. Sayfa 1'de `_InteractivePlaceDemo`: 5x5 mini grid, L-shape ghost cell'ler pulse animasyonuyla davet eder, tap → yerlesme → satir glow → "Harika!" + replay. `FractionallySizedBox(0.45)` + `AspectRatio(1.0)` ile responsive. Reduce motion'da pulse durur, sabit alpha. GDPR uyumlu: analytics consent + renk koru modu toggle yalnizca kullanici 4. sayfaya ulasirsa kaydedilir (`_kTotalPages = 4`). Skip edilirse HomeScreen'deki dialog akisi: (1) ConsentDialog, (2) ATT (iOS). Colorblind prompt Game Over'da oyun 2-5 arasinda gosterilir (inline, tek seferlik). `_continueStartupFlow()` `repo.getConsentShown()` kontrol eder.

### Viral Pipeline

- `ShareManager.shareScore()/shareDailyResult()`: Tum share metodlari `AppStrings l` parametresi alir, 12 dile lokalize. `_modeName(AppStrings, String)` ile mod isimleri l10n uzerinden cevriliyor.
- `ConfettiEffect`: High score asildiginda 40 particle CustomPaint patlamasi. Oyun basina bir kez tetiklenir (`confettiKey == 0` guard).
- `BombExplosionEffect`: 100ms freeze-frame delay (`Future.delayed`) animasyon oncesi dramatik etki.

### HomeScreen Score Chip

Classic ModeCard altinda `_ClassicScoreChip` — son skor ve rekor gosterir ("Last: X | Best: Y"). Skor 0 ise gizli. "So close" state: lastScore >= highScore * 0.8 ise amber renk + "Beat it?" etiketi. Yeni rekor ise "New best!" gold text. `LocalRepository.getLastScore(mode)` / `saveLastScore()` ile persist.

### Per-Mode Progress Chips

Level ModeCard altinda `_LevelProgressChip` ("Level X/50"), Duel altinda `_DuelEloChip` ("X ELO"). Deger 0 ise gizli.

### Quick Play

`_QuickPlayBanner`: HomeScreen'de QuestBar altinda, son oynanan modu hatirlayip hizli erisim saglar. `LocalRepository.getLastPlayedMode()`/`saveLastPlayedMode()` ile persist. `gamesPlayed < 3` ise gizli. Kilitli modlar filtrelenir. Level → `/levels`, Duel → `/pvp-lobby`, diger → `/game/:mode`. Mod accent rengi + `directionalChevronIcon` (RTL-safe).

### Progressive Mod Acilimi

ColorChef 3 oyun sonra, TimeTrial 5 oyun sonra acilir. `getTotalGamesPlayed()` ile kontrol. Kilitli ModeCard'da "X oyun daha oyna" etiketi gosterilir.

### Gorev Sistemi

`quest_provider.dart`: Gunluk 3 gorev (12 havuzdan seed-bazli secim, `kDailyQuestPool`) + haftalik 5 gorev (`kWeeklyQuestPool`, ISO week bazli). 6 gorev tipi: `clearLines`, `reachScore`, `playGames`, `makeSyntheses`, `reachCombo`, `completeDailyPuzzle`. Her Quest'in unique `id` alani var — progress key olarak kullanilir (`quest.id` bazli, eski `type_name_d` formati migration ile donusturuldu). Haftalik progress ayri persist edilir (`weekly_quest_progress`), hafta degisiminde sifirlanir. `QuestBar` widget HomeScreen'de gunluk (kGold) + haftalik (kOrange) progress bar gosterir. `game_callbacks.dart`'ta 6 callback'e entegre. Tamamlanan gorev Jel Ozu odulu verir.

### MetaGameBar

`meta_game_bar.dart`: HomeScreen'de QuestBar altinda, Ada/Karakter/SeasonPass navigasyonu. 3 `MetaItem` (terrain/person/military_tech ikonu) ile `/island`, `/character`, `/season-pass` route'larina yonlendirir. Tema-aware renkler (`kGreen`, `kLavender`, `kGold`). `GelPersonality` sistemi: 8 sentez rengine kisilik arketipleri (Maceracı, Bilge, Gizemli vb.), CharacterScreen'de personality chip'ler olarak gosterilir. Ada core loop: Game over'da `IslandState.tickPassiveProduction()` ile pasif Jel uretimi. `Building.costForLevel` exponential formul (`baseCost * pow(costMultiplier, level)`).

### Hover/Focus/Press Destegi (Web/Desktop)

Tum interaktif widget'lar `MouseRegion` + `_hovered` state ile hover destekler: ModeCard, BottomItem, ActionButton, PowerUpButton, DialogBtn, ProductTile, SettingsTile, PauseBtn, ShareButton, BackButton vb. Hover state `AnimatedContainer` kullanMAZ — performans icin plain `Container` + `AnimatedScale` (sadece press) kullanilir.

**Press standardı:** Tüm butonlar `AnimatedScale(scale: _pressed ? 0.96 : 1.0, duration: 80ms)` kullanır.

**Keyboard focus:** ModeCard, BottomItem, ActionButton `FocusableActionDetector` ile keyboard/tab navigasyonu destekler. Focus ring: `kCyan.withValues(alpha: 0.6)`, 2px border. ThemeData `focusColor: kCyan.withValues(alpha: 0.3)`.

**Portrait kilitleme:** `main.dart`'ta `SystemChrome.setPreferredOrientations([portraitUp, portraitDown])` — `kIsWeb` guard ile (web'de serbest).

### Reduce Motion

`core/utils/motion_utils.dart`: `shouldReduceMotion(BuildContext)` — `MediaQuery.disableAnimations` kontrol eder. `animateOrSkip()` extension `flutter_animate` uzerinde — `reduceMotion: true` ise animasyonlari atlar. Tum ekranlarda `final rm = shouldReduceMotion(context)` ile kullanilir.

### Nearly-Full Row Highlight

`syncGridState()`'te `(playable - filled) <= 2` ise `isNearlyFullRow: true`. `GameCellWidget`'ta bos hucreler amber tint (0.08 alpha) + border (0.25 alpha) ile vurgulanir.

### Grid Fill Metrigi

Game Over overlay'de ham yuzde yerine baglamli metin: <20% "Room to Grow", <55% "Well Managed", <80% "Getting Crowded", >=80% "Very Full". 12 dilde lokalize.

### Level Progression

Level 1-10'da `microTask` alani ile ogretim gorevi. Level 51+ prosedural: 4-temali kisitlama dongusu (kisitli renkler, dar grid, buz hucreleri, yuksek hedef). `_themeIndex()` ile secilir, level 200'e kadar uygulanir.

### Ascension/Prestige

Level 50 sonrasi Ascension tier'lari. `getLevel(id, ascension:)` ile hedef skor +%25/tier, hamle siniri -%10/tier (cap -%50). `getAscensionLevel()`/`saveAscensionLevel()` ile persist.

### Collection Odulleri

8 sentez rengi tamamlandiginda +50 Jel Ozu odul (tek seferlik). `isCollectionRewardClaimed()`/`setCollectionRewardClaimed()` ile persist. Collection ekraninda altin banner.

### Leaderboard Sistemi

LeaderboardScreen 3 tab: Classic, TimeTrial, PvP ELO. Classic/TimeTrial `leaderboard_view` (SECURITY DEFINER) uzerinden — `DISTINCT ON (user_id, mode)` ile kullanici basina en iyi skor. PvP `elo_leaderboard_view` (SECURITY DEFINER) uzerinden — `profiles` RLS (`auth.uid() = id`) bypass eder. `get_user_rank` RPC unique kullanici bazli rank hesaplar, weekly filtre hem kendi skora hem rank'e uygulanir. `_currentMode` `GameMode.classic.name` / `GameMode.timeTrial.name` kullanir (enum case-sensitive). Kullanici satiri cyan vurgu + "YOU" badge ile ayirt edilir. `UserRankBanner` skor gosterir. PvP skorlari "X ELO" formatinda.

**Username sync:** Settings'te isim degisikliginde `ensureProfile(username:)` ile Supabase `profiles` tablosuna senkronize edilir. Aksi halde leaderboard eski ismi gosterir.

### Notification Service

`lib/services/notification_service.dart`: `NotificationService` abstract interface + `StubNotificationService` (web) + `FirebaseNotificationService` (native). `firebase_messaging` + `flutter_local_notifications` + `timezone` paketleri. 3 senaryo: `streakReminder` (20:00 her gun), `dailyPuzzle` (10:00 her gun), `comeback` (3 gun inaktif). `initialize()` → timezone init + local notification kanal + FCM permission + token fetch. `onTokenChanged` callback ile Supabase `device_tokens` tablosuna token sync. `onTokenRefresh` listener dispose'da cancel edilir. HomeScreen'de `WidgetsBindingObserver` ile lifecycle yonetimi: resumed → comeback iptal, paused → comeback zamanla. Settings'te notification toggle (`cancelAll()` / reschedule). Android: `POST_NOTIFICATIONS` + `RECEIVE_BOOT_COMPLETED` + `WAKE_LOCK`. iOS: `UIBackgroundModes: remote-notification` + `Runner.entitlements` (aps-environment: development, release icin production'a cevirilmeli). **Harici gereksinimler:** APNs sertifikasi (p8 key) Firebase'e yuklenmeli, Firebase Console'da Cloud Messaging aktif edilmeli.

### Ses Paketi Sistemi

`AudioPackage` enum (`audio_constants.dart`): `standard`, `crystalAsmr`, `deepForest`. `AudioPaths.resolveSfxPath(baseName, package)` ile paket-bazli asset path. `AudioManager.setAudioPackage(package)` ile runtime degistirme — SFX cache temizlenir, sonraki play yeni path'ten yukler. Fallback: paket dosyasi yoksa standard path'e doner. `LocalRepository.getAudioPackage()`/`saveAudioPackage()` ile persist. `main.dart`'ta startup'ta yuklenir.

### Viral Pipeline

- `ShareManager.shareScore()/shareDailyResult()/shareComboResult()/shareCollection()`: Tum share metodlari `AppStrings l` parametresi alir, 12 dile lokalize. `_modeName(AppStrings, String)` ile mod isimleri l10n uzerinden cevriliyor.
- `buildDailyEmojiGrid(grid, score)`: Wordle formatinda emoji grid — GelColor→emoji mapping (🟥🟨🟦⬜🟧🟩🟪💗), yildiz derecesi (1-3 ⭐), max 5 satir + overflow label.
- `shareCollection(l:, discoveredColors:)`: Kesfedilen sentez renklerini emoji formatinda paylasir (`kAppName Collection: N/8`).
- `ConfettiEffect`: High score asildiginda 40 particle CustomPaint patlamasi. Oyun basina bir kez tetiklenir (`confettiKey == 0` guard).
- `BombExplosionEffect`: 100ms freeze-frame delay (`Future.delayed`) animasyon oncesi dramatik etki.
