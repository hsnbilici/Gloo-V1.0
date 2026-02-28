# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**GitHub:** `https://github.com/hsnbilici/Gloo.git` (branch: `main`)

## Hizli Baslangic

```bash
git clone https://github.com/hsnbilici/Gloo.git
cd Gloo
flutter pub get
flutter run -d chrome
```

## Gereksinimler

- **Flutter SDK** (3.19+): `flutter` PATH'te olmalidir. [Puro](https://puro.dev) veya resmi kurulum kullanilabilir.
- **Android SDK**: `ANDROID_HOME` ortam degiskeni tanimli olmali
- **ADB**: `$ANDROID_HOME/platform-tools/adb`
- **Emulator AVD**: `Gloo_Pixel8` (1080x2400) olusturulmali
- **iOS build**: macOS + Xcode.app (App Store'dan ~12GB), Apple Developer hesabi ($99/yil). Flutter 3.41+ iOS'ta Swift Package Manager kullanir (CocoaPods/Podfile yok)

## Flutter Ortami

Flutter 3.19+ gereklidir. Mevcut kurulu versiyon: **Flutter 3.41.2** (Homebrew). Dart SDK kisiti: `>=3.3.0 <4.0.0`. Kurulum yontemi gelistiriciye birakilir (resmi SDK, [Puro](https://puro.dev), FVM vb.). Flutter 3.41+ iOS'ta Swift Package Manager kullanir (CocoaPods gereksiz).

## Yaygin Komutlar

```bash
flutter pub get
flutter analyze
flutter build web --release
flutter run -d chrome
flutter build apk --debug
flutter devices
python -m http.server 8081 --directory build/web   # web ciktisini sun

# iOS (Xcode.app gerekli)
flutter build ios --simulator
flutter build ios --no-codesign
flutter run -d "iPhone 16 Pro"
flutter build ipa --release          # App Store / TestFlight
```

### Build Workaround (Non-ASCII yol sorunu)

Flutter `impellerc` shader compiler, proje yolunda non-ASCII karakter varsa cokuyor.
Bu durumda projeyi ASCII-safe bir yola kopyalayip oradan build edin:

```bash
# 1. Projeyi ASCII-safe yola kopyala (Windows ornegi)
robocopy "<PROJE_YOLU>" "<ASCII_SAFE_YOL>" /MIR

# 2. ASCII-safe yoldan build et
cd <ASCII_SAFE_YOL>
flutter build apk --debug

# 3. APK'yi kur
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Web build'lar (`flutter build web`) bu sorundan etkilenmez. iOS build'lar da ayni sorundan etkilenir (`impellerc` shader compiler).

### Android / ADB

```bash
# Emulator baslat (AVD adi: Gloo_Pixel8, 1080x2400)
emulator -avd Gloo_Pixel8 -no-snapshot-load

# APK kur
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Ekran goruntusu al
adb exec-out screencap -p > screenshot.png
```

## Mimari Genel Bakis

### Katman Yapisi

```
lib/
├── core/          ← Saf Dart; UI bagimliligi yok
│   ├── constants/ ← game_constants.dart, color_constants.dart, audio_constants.dart, ui_constants.dart
│   ├── utils/     ← color_mixer.dart, near_miss_detector.dart
│   ├── l10n/      ← app_strings.dart (abstract) + 12 dil dosyasi
│   └── widgets/   ← glow_orb.dart
├── game/          ← Saf Dart oyun motoru (Flutter'dan bagimsiz)
│   ├── shapes/    ← gel_shape.dart (GelShape, kAllShapes, ShapeGenerator + Smart RNG)
│   ├── systems/   ← ScoreSystem, ComboDetector, ColorSynthesisSystem, PowerUpSystem
│   ├── world/     ← GlooGame (orkestrator), GridManager, Cell/CellType
│   ├── levels/    ← LevelData, LevelProgression (50 seviye + prosedurel)
│   ├── economy/   ← CurrencyManager (Jel Ozu soft currency)
│   ├── meta/      ← ResourceManager (ada binalari, karakter, sezon pasi, gorevler)
│   ├── pvp/       ← Matchmaking (ELO, eslestirme, engel uretici, asenkron duello)
│   └── physics/   ← gel_deformer.dart, spring_physics.dart (stub)
├── audio/         ← AudioManager (just_audio), HapticManager (stub)
├── viral/         ← ClipRecorder, VideoProcessor (FFmpeg stub), ShareManager
├── services/      ← AnalyticsService, AdManager (google_mobile_ads), PurchaseService (in_app_purchase)
├── data/
│   ├── local/     ← LocalRepository (SharedPreferences), isar_schema.dart (Isar yok — sadece data modelleri)
│   └── remote/    ← RemoteRepository (supabase_flutter), supabase_client.dart
├── providers/     ← Riverpod: gameProvider, audioSettingsProvider, userProvider, locale_provider
├── features/      ← Flutter widget'lari
│   ├── game_screen/  ← game_screen.dart (~1779 satir), game_overlay.dart, game_over_overlay.dart, game_effects.dart (~1185 satir), gel_cell_painter.dart, chef_level_overlay.dart
│   ├── home_screen/  ← home_screen.dart (7 mod karti: Classic, ColorChef, TimeTrial, Zen, Daily, Level, Duel)
│   ├── onboarding/   ← onboarding_screen.dart (3 adimli ilk acilis)
│   ├── daily_puzzle/ ← daily_puzzle_screen.dart
│   ├── settings/     ← settings_screen.dart
│   ├── leaderboard/  ← leaderboard_screen.dart
│   ├── shop/         ← shop_screen.dart (IAP urunleri, Gloo+ abonelik, redeem code)
│   └── collection/   ← collection_screen.dart (kesfedilen nadir renk koleksiyonu)
│   ├── level_select/ ← level_select_screen.dart (seviye secim ekrani, 381 satir)
│   ├── pvp/          ← pvp_lobby_screen.dart (537), duel_result_overlay.dart (274)
│   ├── island/       ← island_screen.dart (ada yonetimi, 433 satir)
│   ├── character/    ← character_screen.dart (karakter/kostum, 459 satir)
│   ├── season_pass/  ← season_pass_screen.dart (sezon pasi, 467 satir)
│   └── quests/       ← quest_overlay.dart (gorev sistemi, 475 satir)
├── app/           ← app.dart (MaterialApp), router.dart (GoRouter)
scripts/           ← ios_setup.sh (flutter create sonrasi iOS konfigurasyon)
```

### Gercek Bagimliliklar (pubspec.yaml)

```
flutter_animate, flutter_riverpod, go_router,
equatable, collection,
shared_preferences, path_provider, share_plus,
just_audio, audio_session,
google_mobile_ads, in_app_purchase,   # Faz 3 — Monetizasyon
supabase_flutter                       # Faz 3 — Backend
```

GDD ve TECHNICAL_ARCHITECTURE.md'de planlanan stack (Flame, flutter_soloud, Firebase, Isar) **henuz eklenmemistir**.

### Oyun Mantigi Akisi

`GlooGame` saf Dart sinifidir (Flame kullanmaz). Her hamle su pipeline'i tetikler:

```
GameScreen._onCellTap()
  → GlooGame.placePiece(cells, color)
      → GridManager.place()
      → _evaluateBoard():
          → ColorSynthesisSystem.findSyntheses()
          → GridManager.setCell() (sentez sonucu)
          → Color Chef: hedef renk sayimi → seviye tamamlaninca izgara sifirlanir
          → GridManager.detectAndClear() (tam satir/sutunlari temizler + buz kirma)
          → GridManager.applyGravity() (gravity hucreler icin)
          → ComboDetector.registerClear() (1500ms pencerede zincir)
          → ScoreSystem.addLineClear()
          → CurrencyManager.earnFromLineClear() (Jel Ozu kazanimi)
          → PowerUpSystem.onMoveCompleted() (cooldown azalt)
          → NearMissDetector.evaluate() (Classic/Chef/Zen)
          → onJelEnergyEarned?.call(clearResult.totalLines)  // meta-game kaynak
      → Level modu: hedef skor veya hamle siniri kontrolu → onLevelComplete
  → GlooGame.checkGameOver(handShapes)
```

`GlooGame` UI'ya callback'ler uzerinden bildirir (`onScoreGained`, `onNearMiss`, `onCombo`, `onGameOver`, `onCurrencyEarned`, `onPowerUpUsed`, `onLevelComplete`, `onIceCracked`, `onGravityApplied`, `onJelEnergyEarned`); Riverpod provider'larini dogrudan cagirmaz.

### GameMode Enum

```dart
enum GameMode {
  classic,     // Izgara dolana kadar oyna
  colorChef,   // Hedef rengi sentezle
  timeTrial,   // 90sn sureli
  zen,         // Stres-free (Gloo+ gerektirir)
  daily,       // Gunluk bulmaca (seeded RNG)
  level,       // Seviye modu (LevelData bazli, dinamik izgara boyutu)
  duel,        // PvP duello (120sn, ELO bazli, seeded)
}
```

### State Mulkiyeti

`GameScreen` bir `GlooGame` ornegini `State` icinde dogrudan tutar (Riverpod ile degil). Riverpod yalnizca UI gosterimi icin kullanilir:

| Riverpod Provider | Icerik |
|---|---|
| `gameProvider(GameMode)` | `score`, `status`, `filledCells`, `remainingSeconds`, `chefProgress`, `chefRequired` |
| `audioSettingsProvider` | `sfxEnabled`, `musicEnabled`, `hapticsEnabled`, `colorBlindMode`, `analyticsEnabled`, `glooPlus`, `adsRemoved` |
| `sharedPreferencesProvider` | `FutureProvider<SharedPreferences>` |
| `stringsProvider` | Aktif dildeki l10n string'leri |
| `streakProvider` | Gunluk giris serisi |
| `localRepositoryProvider` | `FutureProvider<LocalRepository>` SharedPreferences wrapper |
| `eloProvider` | Oyuncu ELO puani (PvP eslestirme) |

### Hucre ve Izgara Sistemi

Izgara `List<List<Cell>>` yapisindadir. Varsayilan boyut 8x10 (`GameConstants`) ama Level modunda `LevelData.rows/cols` ile dinamik olabilir (6x6 → 10x12).

**CellType enum:** `normal`, `ice` (1-2 katman, temizlemede kirilir), `locked` (belirli renk gerektirir), `stone` (yerlestirilemiyor, harita engeli), `gravity` (ustundeki bloklar duser), `rainbow` (joker)

**Cell sinifi:** `color`, `type`, `iceLayer`, `lockedColor` alanlari. `canAccept(GelColor)` yerlesim kontrolu yapar. `crackIce()` buz katmanini azaltir.

### Seviye Sistemi

- `LevelData`: `rows`, `cols`, `specialCells`, `targetScore`, `maxMoves`, `shape` (MapShape enum: rectangle/diamond/cross/lShape/corridor)
- `LevelProgression`: 50 onceden tanimli seviye + 51+ prosedurel uretim
- Her 10 seviyede 1 "breathing room" (kolay seviye) — Retention icin
- `LevelData.allSpecialCells()`: Harita formu + seviye tanimlari birlestirir

### Power-Up ve Ekonomi Sistemi

**6 Power-up:** `rotate` (3 ozu), `bomb` (8 ozu, 3x3 temizleme), `peek` (2 ozu), `undo` (5 ozu, 1/oyun), `rainbow` (10 ozu), `freeze` (6 ozu, sadece TimeTrial)

**Jel Ozu Kazanimi:** Satir temizleme=1, kombo bonus=2-5, sentez=1, gunluk giris=3, reklam=5. Gloo+ aboneler +%50 bonus.

`PowerUpSystem` cooldown, limit ve maliyet kontrolu yapar. `CurrencyManager` bakiye yonetir, `SharedPreferences`'ta persist eder.

### Smart RNG

`ShapeGenerator` agirlikli rastgele secim yapar:
- Zorluk bazli sekil agirliklari (kolay=%60 kucuk, zor=%60 buyuk)
- Izgaradaki renk dagilimine gore renk agirliklari (az bulunan birincil renkler yuksek)
- Merhamet mekanizmasi: 3 ardisik kayip → zorluk ×0.7, 5 hamle temizleme yok → kurtarici el
- Zorluk egrisi: `min(score/5000, 0.8) + min(gamesPlayed/50, 0.2)`, asla 0.95'i asmaz
- Seeded modlar (Daily/Duel): `generateSeededHand()` ve `generateNextSeededHand()`

### Renk Sistemi

`GelColor` enum 12 renk icerir. Elden yalnizca 4 birincil renk (`kPrimaryColors`) cikar: `red`, `yellow`, `blue`, `white`. Sentezlenmis 8 renk yalnizca birlesimle olusur.

`kColorMixingTable` (`color_constants.dart`): 8 giris, sira bagimsiz arama. Yeni kombinasyon eklemek icin yalnizca bu tabloya giris eklenmesi yeterlidir.

`GelColor.shortLabel`: Renk koru modu icin Ingilizce kisaltma (R/Y/B/O/G/P/Pk/Lb/Li/Mn/Br/W) — dil bagimsiz, degistirilmemeli.

UI palet sabitleri `color_constants.dart`'ta: `kBgDark`, `kCyan`, `kMuted`, `kColorClassic/Chef/TimeTrial/Zen`. Ekranlarda bu sabitler yerel olarak tekrar tanimlanmamalidir.

### Skor ve Kombo

```
singleLineClear = 100
multiLineClear  = 300 x (satir_sayisi - 1)
colorSynthesisBonus = 50
```

Kombo zincirleri 1500ms pencerede toplanir: small(1-2, x1.2), medium(3-4, x1.5), large(5-7, x2.0), epic(8+, x3.0)

### Routing

GoRouter. **ONEMLI:** Spesifik rotalar genel `/game/:mode` rotasindan ONCE tanimlanmalidir:
1. `/game/level/:levelId` → `GameScreen(mode: GameMode.level, levelData: ...)`
2. `/game/duel` → `GameScreen(mode: GameMode.duel)`
3. `/game/:mode` → `GameScreen(mode: GameMode.fromString(mode))`

Diger rotalar: `/`, `/onboarding`, `/daily`, `/settings`, `/shop`, `/leaderboard`, `/collection`
Faz 4 rotalari: `/levels`, `/pvp-lobby`, `/island`, `/character`, `/season-pass`

`GameMode.fromString()` gecersiz degerleri `classic`'e dusurur.

**Ilk acilis akisi:** `HomeScreen.initState()` → `onboarding_done` false ise `/onboarding` → bitince `/` → `colorblind_prompt_shown` false ise dialog gosterilir.

### Game Screen Widget Yapisi

`game_screen.dart` icindeki `_GameScreenState`:
- `GlooGame _game` — oyun motoru
- `_hand` — `List<(GelShape, GelColor)?>` (3 slot)
- Power-up toolbar: `_buildPowerUpToolbar()` (Jel Ozu sayaci + 3-4 power-up butonu, moda gore)
- Buz/yer cekimi/gokkusagi hucreleri `_buildCellWidget()` icinde ozel render

**Mod bazli HUD (`game_overlay.dart`):**
- Classic: `_FillBar` (doluluk %)
- TimeTrial: `_CountdownBar` (geri sayim cubugu)
- ColorChef: `_ChefTargetBar` (hedef renk ilerlemesi)
- Zen: `_ZenAmbienceBar`
- Level: `_FillBar` + seviye bilgisi
- Duel: `_CountdownBar` + ELO bilgisi

### VFX Sistemi (game_effects.dart + gel_cell_painter.dart)

7 VFX protokolu tanimli, hepsi kodlandi (emulator testi bekliyor):

| # | Protokol | Sinif/Widget | Durum |
|---|---|---|---|
| 1 | Breathing Gel | `GelCellPainter` (6 katman CustomPainter) | Kod yazildi |
| 2 | Squash & Stretch | `_SquashStretchCell`, `_WaveRipple` | Kod yazildi |
| 3 | The Cascade | `CellBurstEffect` (16 parcacik, Bezier trajectory) | Kod yazildi |
| 4 | Chain Lightning | `ComboEffect` + `ScreenShake` (epic=4px) | Kod yazildi |
| 5 | Danger Pulse | `NearMissEffect` + `_VignettePainter` (radyal vignette) | Kod yazildi |
| 6 | Color Bloom | `ColorSynthesisBloomEffect` (flas + 2 halka + 10 parcacik) | Kod yazildi |
| 7 | Ambient Atmosphere | `AmbientGelDroplets` (10 yuzucu damlacik, mod bazli renk) | Kod yazildi |

`AmbientGelDroplets` mod bazli renk kullanir (`_modeColor` getter: classic=cyan, zen=yesil, duel=kirmizi vb.)

### Ikinci Sans (Loss Aversion)

`game_over_overlay.dart`: "Reklam Izle → 3 Ekstra Hamle" butonu. `game_world.dart`'ta `continueWithExtraMoves(int)` metodu ile oyun devam eder. HUD badge'leri: NearMiss critical ise "Kurtarilabilir!", skor > highScore*0.9 ise "Rekoruna yakinsin!".

### Meta-Game (UI yazildi — backend entegrasyonu bekliyor)

`ResourceManager`: Jel Enerjisi (satir basina 1), ada binalari (gelFactory, asmrTower, colorLab, arena, harbor), karakter kostum/yetenek sistemi, sezon pasi (8 hafta, 50 tier), gunluk/haftalik gorevler. UI ekranlari: `island_screen.dart` (433), `character_screen.dart` (459), `season_pass_screen.dart` (467), `quest_overlay.dart` (475).

### PvP (UI yazildi — Supabase Realtime entegrasyonu bekliyor)

`Matchmaking`: ELO sistemi (K=32, 5 lig), eslestirme (ELO farki ≤200, 30sn timeout → bot), `ObstacleGenerator` (satir temizleme → rakibe buz/tas/kilitli hucre gonderer), `AsyncDuelState` (120sn, seed bazli). UI ekranlari: `pvp_lobby_screen.dart` (537), `duel_result_overlay.dart` (274). Henuz Supabase Realtime entegrasyonu yok.

## Linting Kurallari

`flutter_lints` temel alinir, ek kurallar: `prefer_single_quotes`, `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_fields`, `sort_child_properties_last`, `use_super_parameters`, `avoid_print`, `always_declare_return_types`

## Mevcut Platform Durumu

| Platform | Durum |
|---|---|
| Web (Chrome/Edge) | Calisir — `build\web` port 8081'de sunulur |
| Android | Calisir — `ANDROID_HOME` tanimli olmali, AVD `Gloo_Pixel8` (1080x2400) |
| Windows Desktop | VS C++ build tools eksik |
| iOS | Calisir — Xcode 26.3, iOS Simulator 26.2 (iPhone 17 Pro). Deployment target: 16.0. CocoaPods + SPM |

## Onemli Kisitlamalar

### Flutter API Degisiklikleri
- `withOpacity()` yerine `withValues(alpha:)` kullanilmali (Flutter 3.41+ deprecation)
- `SwitchListTile.activeColor` yerine `activeThumbColor` kullanilmali (Flutter 3.31+)

### Platform Guard'lar
- `main.dart`: Supabase init try-catch ile sarili (sahte anahtarlar hata verir). `AdManager` ve `PurchaseService` init `kIsWeb` guard ile korunur. iOS icin `SystemUiMode.edgeToEdge` (immersiveSticky iOS'ta tam desteklenmez).
- `android/app/src/main/AndroidManifest.xml`: AdMob test App ID (`ca-app-pub-3940256099942544~3347511713`) meta-data zorunlu. Bu olmadan `MobileAdsInitProvider` Java seviyesinde FATAL EXCEPTION atar. Uretime geciste gercek ID ile degistirilmeli.
- `ad_manager.dart`: Platform bazli ad unit ID'leri (`_isIOS` getter ile iOS/Android ayirimi). Test ID'leri her iki platformda da tanimli.
- `audio_manager.dart`: iOS audio session `AVAudioSessionCategory.ambient` konfigurasyonu (`audio_session` paketi).
- `ios/Runner/Info.plist`: `GADApplicationIdentifier` (test), `ITSAppUsesNonExemptEncryption` (false), `NSUserTrackingUsageDescription` (ATT). Uretime geciste gercek AdMob App ID ile degistirilmeli.
- Web uyumsuz paketler: `ffmpeg_kit_flutter`, `isar`, `flutter_soloud`, `google_mobile_ads`. `just_audio` web-uyumlu.

### Veri Katmani
- `LocalRepository` SharedPreferences anahtarlari:
  - Profil/ayar: `username`, `sfx`, `music`, `haptics`, `onboarding_done`, `colorblind_prompt_shown`, `analytics_enabled`
  - Skor: `highscore_{mode}` (classic/colorChef/timeTrial/zen/daily)
  - Seviye: `completed_levels` (JSON array), `level_highscore_{levelId}`, `current_level`, `max_completed_level`
  - Istatistik: `total_games_played`, `average_score`, `consecutive_losses`
  - Streak: `streak_count`, `streak_last_date`
  - Gunluk: `daily_date`, `daily_score`, `daily_quest_progress` (JSON), `daily_quest_date`
  - Koleksiyon: `discovered_colors` (StringList)
  - Ekonomi: `gel_ozu`, `gel_energy`, `total_earned_energy`
  - Meta-game: `island_state`, `character_state`, `season_pass_state` (JSON)
  - PvP: `elo` (default: 1000), `pvp_wins`, `pvp_losses`
  - Monetizasyon: `redeemed_codes` (StringList), `unlocked_products` (StringList)
- `RemoteRepository` metodlari:
  - `submitScore(mode, value)` → scores tablosuna insert
  - `getGlobalLeaderboard(mode, limit, weekly)` → skor siralamasi
  - `getUserRank(mode, weekly)` → oyuncu sirasi
  - `ensureProfile(username)` → profiles tablosuna upsert
  - `getDailyPuzzle()` → daily_tasks sorgulama
  - `submitDailyResult(score, completed)` → daily_tasks upsert
  - `redeemCode(code)` → redeem_codes dogrulama + `current_uses` artirimi
- `isar_schema.dart` adi yaniltici — Isar yok, sadece `Score` ve `UserProfile` veri siniflari
- `supabase_client.dart`: Sahte URL/key ile placeholder. Uretime geciste doldurulmali
- `AnalyticsService`: No-op stub, Firebase eklenince aktiflesecek

### Ses ve Haptik
- `AudioManager` ses dosyalarini `assets/audio/sfx/` ve `assets/audio/music/` altindan yukler. Dosya bulunamazsa sessizce atlar.
- `audio_constants.dart`: 30+ ses yolu tanimli (jel yerlestirme, birlesim, patlama, kombo 4 tier, renk sentezi, PvP, power-up, buz kirma, seviye tamamlama). OGG dosyalari henuz uretilmedi — Audacity/FL Studio ile uretilmeli.
- `pubspec.yaml`'da `assets/audio/sfx/` ve `assets/audio/music/` asset dizinleri aktif.
- `audio_session` paketi iOS'ta ses kategorisini `ambient` olarak ayarlar (diger uygulamalarla karisir, sessiz modda sessiz).
- `.ogg` formati iOS'ta native desteklenmez; `just_audio` codec cevirici kullanir. Ses dosyalari uretildiginde `.ogg` + `.m4a` ikili format onerilir.
- `ClipRecorder` ve `VideoProcessor` stub — `screen_recorder` ve `ffmpeg_kit_flutter` paketleri eklenmeli

## Coklu Dil (l10n)

12 dil destegi: `en` (varsayilan fallback), `tr`, `de`, `zh`, `ja`, `ko`, `ru`, `es`, `ar`, `fr`, `hi`, `pt`

```dart
// Herhangi bir ConsumerWidget icinde:
final l = ref.watch(stringsProvider);
Text(l.scoreLabel)
```

`AppStrings.forLocale()` factory metodu desteklenmeyen dilleri Ingilizce'ye dusurur. Yeni dil eklemek icin: `strings_xx.dart` olustur, `AppStrings.forLocale()` switch'ine ekle, `app.dart` `supportedLocales` listesine ekle.

### Yeni String Ekleme

1. `app_strings.dart`'a abstract getter ekle
2. Tum 12 dil dosyasina (`strings_{en,tr,de,zh,ja,ko,ru,es,ar,fr,hi,pt}.dart`) override ekle
3. Her dildeki cevirilerin dogru oldugunu kontrol et

## Monetizasyon Yapisi

- **Zen modu** Gloo+ abonelik ile kilitli. `audioSettingsProvider.glooPlus` false iken home_screen'de kilit ikonu gorunur.
- **AdManager**: Interstitial (4 oyunda 1), rewarded (ikinci sans), banner (home). Anti-frustration: 5dk'da 2 kayip → reklam yok. Test reklam ID'leri aktif.
- **PurchaseService**: 7 IAP urunu (kRemoveAds, kSoundCrystal, kSoundForest, kTexturePack, kStarterPack, kGlooPlusMonthly, kGlooPlusYearly). Store'da tanimlanmali.
- **Redeem Code**: `ShopScreen` icinde kod girisi, `RemoteRepository.redeemCode()` ile Supabase `redeem_codes` tablosunda dogrulama, `PurchaseService.unlockProducts()` ile aktivasyon, `LocalRepository` ile `redeemed_codes` + `unlocked_products` persist. `_redeeming` flag'i IAP `_purchasing` flag'inden bagimsizdir.

## Entry Point (main.dart)

`main()` sirasi: `WidgetsFlutterBinding.ensureInitialized()` → Supabase init (try-catch) → `!kIsWeb` ise AdManager + PurchaseService init → portraitUp kilit → iOS ise `edgeToEdge`, diger platformlarda `immersiveSticky` → `runApp(ProviderScope(child: GlooApp()))`. Firebase henuz eklenmedi (yorum satirinda).

## Test Durumu

Tek test dosyasi: `test/widget_test.dart` (placeholder). Birim testler henuz yazilmamis. Planlanan test hedefleri:
- `test/game/grid_manager_test.dart`
- `test/game/color_synthesis_test.dart`
- `test/core/near_miss_detector_test.dart`
- `test/core/color_mixer_test.dart`

```bash
flutter test                                   # tum testler
flutter test test/game/grid_manager_test.dart   # tek test dosyasi
```

## Detayli Dokumantasyon

| Dokuman | Amac |
|---|---|
| `GDD.md` | Game Design Document — mekanikler, monetizasyon, ASO stratejisi |
| `TECHNICAL_ARCHITECTURE.md` | Sistem diyagrami, klasor yapisi, algoritma ornekleri |
| `README.md` | Proje ozeti, ozellik listesi, teknoloji yigini, faz durumu |
