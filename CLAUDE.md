# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**GitHub:** `https://github.com/hsnbilici/Gloo.git` (branch: `main`)

## Hizli Baslangic

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Gereksinimler

- **Flutter SDK** 3.19+ (mevcut: 3.41.2). Dart SDK: `>=3.3.0 <4.0.0`
- **Android**: `ANDROID_HOME` tanimli, AVD `Gloo_Pixel8` (1080x2400)
- **iOS**: macOS + Xcode.app. Flutter 3.41+ iOS'ta Swift Package Manager kullanir (CocoaPods gereksiz)

## Komutlar

```bash
flutter pub get                                # bagimliliklari indir
flutter analyze                                # lint (0 issue olmali)
flutter test                                   # tum testler (1204 test)
flutter test test/game/grid_manager_test.dart   # tek test dosyasi
flutter build web --release                    # web build
flutter build apk --debug                      # android debug
flutter run -d chrome                          # web'de calistir
flutter run -d "iPhone 16 Pro"                 # iOS simulator'de calistir
```

### Build Workaround (Non-ASCII yol)

Flutter `impellerc` shader compiler, proje yolunda non-ASCII karakter varsa cokuyor. Projeyi ASCII-safe bir yola kopyalayip build edin. Web build'lar etkilenmez.

### Android / ADB

```bash
emulator -avd Gloo_Pixel8 -no-snapshot-load
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Mimari Genel Bakis

### Katman Yapisi

```
lib/
├── core/          ← Saf Dart; UI bagimliligi yok
│   ├── constants/ ← game_constants, color_constants, audio_constants, ui_constants
│   ├── utils/     ← color_mixer, near_miss_detector
│   ├── l10n/      ← app_strings (abstract) + 12 dil dosyasi
│   └── extensions/← color_extensions
├── game/          ← Saf Dart oyun motoru (Flutter'dan bagimsiz)
│   ├── shapes/    ← GelShape, ShapeGenerator (Smart RNG + merhamet)
│   ├── systems/   ← ScoreSystem, ComboDetector, ColorSynthesisSystem, PowerUpSystem
│   ├── world/     ← GlooGame (orkestrator), GridManager, Cell/CellType
│   ├── levels/    ← LevelData, LevelProgression (50 seviye + prosedurel)
│   ├── economy/   ← CurrencyManager (Jel Ozu)
│   ├── meta/      ← ResourceManager (ada, karakter, sezon pasi, gorevler)
│   ├── pvp/       ← Matchmaking (ELO), ObstacleGenerator, AsyncDuelState
│   └── physics/   ← gel_deformer, spring_physics
├── audio/         ← AudioManager (just_audio), HapticManager, SoundBank
├── viral/         ← ClipRecorder, VideoProcessor (FFmpeg), ShareManager
├── services/      ← AnalyticsService (Firebase), AdManager, PurchaseService
├── data/
│   ├── local/     ← LocalRepository (SharedPreferences), data_models
│   └── remote/    ← RemoteRepository (Supabase), supabase_client, pvp_realtime_service
├── providers/     ← Riverpod: game, audio, user, locale, pvp providers
├── features/      ← Flutter widget'lari (14 ekran)
└── app/           ← app.dart (MaterialApp), router.dart (GoRouter)
```

### Oyun Mantigi Akisi

`GlooGame` saf Dart sinifidir (Flame kullanmaz). Her hamle su pipeline'i tetikler:

```
GameScreen._onCellTap()
  → GlooGame.placePiece(cells, color)
      → GridManager.place()
      → _evaluateBoard():
          → ColorSynthesisSystem.findSyntheses()
          → GridManager.setCell() (sentez sonucu)
          → Color Chef: hedef renk sayimi
          → GridManager.detectAndClear() (tam satir/sutun + buz kirma)
          → GridManager.applyGravity()
          → ComboDetector.registerClear() (1500ms pencere)
          → ScoreSystem.addLineClear()
          → CurrencyManager.earnFromLineClear()
          → PowerUpSystem.onMoveCompleted()
          → NearMissDetector.evaluate()
      → Level modu: hedef skor / hamle siniri → onLevelComplete
  → GlooGame.checkGameOver(handShapes)
```

`GlooGame` UI'ya callback'ler uzerinden bildirir (`onScoreGained`, `onCombo`, `onGameOver`, `onCurrencyEarned`, `onLevelComplete` vb.); Riverpod provider'larini dogrudan cagirmaz.

### GameMode Enum (7 mod)

`classic`, `colorChef`, `timeTrial`, `zen` (Gloo+ gerekli), `daily` (seeded), `level` (50+prosedurel), `duel` (120sn, ELO, seeded)

### State Mulkiyeti

`GameScreen` bir `GlooGame` ornegini `State` icinde dogrudan tutar (Riverpod ile degil). Riverpod yalnizca UI gosterimi icin kullanilir:

| Provider | Icerik |
|---|---|
| `gameProvider(GameMode)` | score, status, filledCells, remainingSeconds, chefProgress |
| `audioSettingsProvider` | sfx/music/haptics/colorBlind/analytics/glooPlus/adsRemoved |
| `localRepositoryProvider` | `FutureProvider<LocalRepository>` SharedPreferences wrapper |
| `stringsProvider` | Aktif dildeki l10n string'leri |
| `streakProvider` | Gunluk giris serisi |
| `eloProvider` | PvP ELO puani |
| `duelProvider` | DuelState (matchId, seed, opponentScore, isBot) |

### Hucre ve Izgara Sistemi

Izgara `List<List<Cell>>` — varsayilan 8x10, Level modunda dinamik (6x6 → 10x12).

**CellType:** `normal`, `ice` (1-2 katman), `locked` (belirli renk), `stone` (engel), `gravity` (duser), `rainbow` (joker)

### Renk Sistemi

`GelColor` enum 12 renk. Elden yalnizca 4 birincil renk cikar: `red`, `yellow`, `blue`, `white`. 8 sentez rengi yalnizca birlesimle olusur.

`kColorMixingTable` (`color_constants.dart`): sira bagimsiz arama. Yeni kombinasyon icin yalnizca bu tabloya giris eklenmesi yeterli.

`GelColor.shortLabel`: Renk koru modu icin dil bagimsiz kisaltma — degistirilmemeli.

UI palet sabitleri `color_constants.dart`'ta: `kBgDark`, `kCyan`, `kMuted`, `kColorClassic/Chef/TimeTrial/Zen`. Ekranlarda yerel olarak tekrar tanimlanmamali.

### Routing

GoRouter. **ONEMLI:** Spesifik rotalar genel `/game/:mode`'dan ONCE tanimlanmali:
1. `/game/level/:levelId`
2. `/game/duel`
3. `/game/:mode` (generic)

`GameMode.fromString()` gecersiz degerleri `classic`'e dusurur.

Diger rotalar: `/`, `/onboarding`, `/daily`, `/settings`, `/shop`, `/leaderboard`, `/collection`, `/levels`, `/pvp-lobby`, `/island`, `/character`, `/season-pass`

## Onemli Kisitlamalar

### Flutter API Degisiklikleri
- `withOpacity()` yerine `withValues(alpha:)` kullanilmali (Flutter 3.41+ deprecation)
- `Color.red`/`.green`/`.blue` yerine `(color.r * 255).round()` kullanilmali
- `color.value` yerine `color.toARGB32()` kullanilmali

### Platform Guard'lar
- `main.dart`: Firebase init try-catch ile sarili (placeholder anahtarlarla sessizce atlar). Supabase init try-catch. AdManager + PurchaseService `kIsWeb` guard ile korunur. iOS `edgeToEdge`, diger `immersiveSticky`.
- `AndroidManifest.xml`: AdMob test App ID zorunlu — olmadan FATAL EXCEPTION. Uretime geciste gercek ID gerekir.
- `ios/Runner/Info.plist`: `GADApplicationIdentifier` (test), `NSUserTrackingUsageDescription` (ATT) mevcut.
- Web uyumsuz paketler: `ffmpeg_kit_flutter`, `google_mobile_ads`, `screen_recorder`. `just_audio` web-uyumlu.

### Veri Katmani
- `LocalRepository`: SharedPreferences wrapper, 40+ anahtar (skor, profil, ayar, seviye, ekonomi, meta-game, PvP). Tum anahtarlar `local_repository.dart`'ta.
- `RemoteRepository`: Supabase ile leaderboard, daily puzzle, redeem code, PvP, meta-game sync. Tum metodlarda `isConfigured` guard var.
- `supabase_client.dart`: Gercek Supabase anahtarlari girilmis. `SupabaseConfig.isConfigured` ile kontrol.
- `AnalyticsService`: Lazy/null-safe Firebase wrapper — Firebase yoksa sessizce no-op.
- `PvpRealtimeService`: Supabase Realtime (Presence + Broadcast) ile eslestirme ve duello senkronizasyonu.
- `data_models.dart`: `Score` ve `UserProfile` veri siniflari (Isar yok).
- `firebase_options.dart`: Gercek Firebase degerleri girilmis (`gloo-f7905` projesi). Uretime geciste `flutterfire configure` ile dogrulanmali.

### Ses ve Haptik
- `AudioManager` ses dosyalarini `assets/audio/sfx/` ve `assets/audio/music/` altindan yukler. Dosya bulunamazsa sessizce atlar.
- `audio_constants.dart`: 30+ ses yolu tanimli. OGG dosyalari henuz uretilmedi.
- `HapticManager`: 13 haptic profil, tam implementasyon.
- `.ogg` formati iOS'ta native desteklenmez — ses uretildiginde `.ogg` + `.m4a` ikili format onerilir.

## Coklu Dil (l10n)

12 dil: `en` (fallback), `tr`, `de`, `zh`, `ja`, `ko`, `ru`, `es`, `ar`, `fr`, `hi`, `pt`

```dart
final l = ref.watch(stringsProvider);
Text(l.scoreLabel)
```

Yeni string eklemek: (1) `app_strings.dart`'a abstract getter, (2) tum 12 `strings_*.dart`'a override, (3) cevirileri dogrula.

## Linting Kurallari

`flutter_lints` temel, ek kurallar: `prefer_single_quotes`, `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_fields`, `sort_child_properties_last`, `use_super_parameters`, `avoid_print`, `always_declare_return_types`

## Test

1204 test, 60+ dosya, 0 hata. Test alanlari: game engine (grid, synthesis, score, combo, shapes, levels, powerups, matchmaking, resource manager, spring physics, gel deformer, color chef levels), core (constants, color mixer, near miss, cell types, l10n, color extensions), data (local repository, data models, DTOs, remote repository), providers (game, audio, locale, pvp, user, service), services (analytics, ad manager, purchase), features (home, onboarding, game overlay, settings, collection, level select, effects, viral, quests, dialogs), audio (audio manager, haptic manager, sound bank), app (router).

```bash
flutter test                                   # tum testler
flutter test test/game/grid_manager_test.dart   # tek dosya
flutter test --name "ComboDetector"             # isimle filtrele
```

## Monetizasyon

- **Zen modu**: Gloo+ abonelik ile kilitli
- **AdManager**: Interstitial (4 oyunda 1), rewarded (ikinci sans), banner. Anti-frustration: 5dk'da 2 kayip → reklam yok. Test ID'ler aktif.
- **PurchaseService**: 7 IAP urunu. Store'da tanimlanmali.
- **Redeem Code**: `ShopScreen` → `RemoteRepository.redeemCode()` → Supabase dogrulama → `PurchaseService.unlockProducts()`

## Entry Point (main.dart)

`main()` sirasi: `WidgetsFlutterBinding` → Firebase init (try-catch) → Supabase init → `!kIsWeb` ise AdManager + PurchaseService → portraitUp kilit → iOS `edgeToEdge` / diger `immersiveSticky` → `runApp(ProviderScope(child: GlooApp()))`

## Mevcut Platform Durumu

| Platform | Durum |
|---|---|
| Web (Chrome/Edge) | Calisir |
| Android | Calisir — AVD `Gloo_Pixel8` |
| iOS | Calisir — Xcode 26.3, iOS Simulator 26.2, deployment target 16.0 |

## Detayli Dokumantasyon

| Dokuman | Amac |
|---|---|
| `GDD.md` | Game Design Document — mekanikler, monetizasyon, ASO |
| `TECHNICAL_ARCHITECTURE.md` | Sistem diyagrami, algoritma ornekleri |
| `tasks/todo.md` | Kalan isler ve yol haritasi (7 madde — tumu harici bagimlilk) |
