# P2 Kalite & Mimari Iyilestirme — Uygulama Plani

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 6 bagimsiz P2 gorevini (M.6, M.8, M.14, M.17, M.18, M.19) uygulayarak proje kalitesini ve mimari tutarliligini artirmak.

**Architecture:** Her gorev bagimsiz — paralel uygulanabilir. TDD yaklasimi: once test, sonra uygulama. Minimal degisiklik politikasi gecerli.

**Tech Stack:** Flutter 3.41+, Dart, Riverpod, mocktail, lcov, GitHub Actions

---

## Dosya Yapisi

| Gorev | Olusturulacak | Degistirilecek | Test |
|-------|---------------|----------------|------|
| M.6 | — | `.github/workflows/flutter_ci.yml` | CI pipeline |
| M.8 | — | `lib/features/pvp/pvp_lobby_screen.dart`, `lib/features/game_screen/game_duel_controller.dart`, `lib/providers/pvp_provider.dart` | Mevcut testler |
| M.14 | — | `lib/core/constants/color_constants.dart` + 21 feature dosyasi | `flutter analyze` |
| M.17 | — | `lib/game/shapes/gel_shape.dart`, `lib/game/world/game_world.dart`, `lib/features/game_screen/game_screen.dart` | Mevcut testler |
| M.18 | — | `pubspec.yaml` + yeni mock dosyalari `test/helpers/` altinda | Mevcut testler |
| M.19 | `test/game/world/evaluate_board_test.dart` | — | Yeni test dosyasi |

---

## Task 1: M.6 — CI Coverage Threshold (min %70)

**Files:**
- Modify: `.github/workflows/flutter_ci.yml`

- [ ] **Step 1: CI workflow'a coverage threshold adimi ekle**

`.github/workflows/flutter_ci.yml` dosyasinda `Run tests` adiminin altina coverage kontrol adimi ekle:

```yaml
      - name: Check coverage threshold
        run: |
          # Parse lcov.info for line coverage
          TOTAL_LINES=$(grep -c '^DA:' coverage/lcov.info || echo 0)
          HIT_LINES=$(grep '^DA:' coverage/lcov.info | grep -cv ',0$' || echo 0)
          if [ "$TOTAL_LINES" -eq 0 ]; then
            echo "No coverage data found"
            exit 1
          fi
          COVERAGE=$((HIT_LINES * 100 / TOTAL_LINES))
          echo "Coverage: $COVERAGE% ($HIT_LINES/$TOTAL_LINES lines)"
          if [ "$COVERAGE" -lt 70 ]; then
            echo "::error::Coverage $COVERAGE% is below minimum threshold of 70%"
            exit 1
          fi
          echo "Coverage $COVERAGE% meets minimum threshold of 70%"
```

- [ ] **Step 2: Yerel dogrulama**

```bash
flutter test --coverage
TOTAL_LINES=$(grep -c '^DA:' coverage/lcov.info || echo 0)
HIT_LINES=$(grep '^DA:' coverage/lcov.info | grep -cv ',0$' || echo 0)
echo "Coverage: $((HIT_LINES * 100 / TOTAL_LINES))%"
```

Beklenen: %70 ustu coverage degeri.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/flutter_ci.yml
git commit -m "ci: add coverage threshold check (min 70%)"
```

---

## Task 2: M.8 — features→data/remote Bypass Duzeltmesi

**Files:**
- Modify: `lib/features/pvp/pvp_lobby_screen.dart`
- Modify: `lib/features/game_screen/game_duel_controller.dart`
- Modify: `lib/providers/pvp_provider.dart` (gerekirse)

**Sorun:** 2 feature dosyasi `PvpRealtimeService`'i dogrudan `data/remote/` katmanindan import ediyor. Bu katman bypass'i. Feature katmani yalnizca provider uzerinden erisebilmeli.

- [ ] **Step 1: Mevcut provider yapisini incele**

`lib/providers/pvp_provider.dart` dosyasinda `pvpRealtimeServiceProvider` var mi kontrol et. Bu provider'in tip olarak `PvpRealtimeService` dondurdugunu dogrula.

- [ ] **Step 2: pvp_lobby_screen.dart import'unu duzelt**

`lib/features/pvp/pvp_lobby_screen.dart:11`:

Eski:
```dart
import '../../data/remote/pvp_realtime_service.dart';
```

Bu import `PvpRealtimeService` tipi icin kullaniliyor (satir 34, 48). Provider zaten `pvpRealtimeServiceProvider` uzerinden erisim sagliyor. Import'u kaldir ve gerekli tipleri (`MatchRequest`, `MatchResult`) provider dosyasindan veya `matchmaking.dart`'tan al.

Eger `PvpRealtimeService` tipi yalnizca `ref.read(pvpRealtimeServiceProvider)` donus tipi olarak kullaniliyorsa, import'u kaldirmak yeterli. Eger acik tip annotasyonu varsa (orn. `late final PvpRealtimeService _realtimeService`), provider dosyasindan re-export yap.

Yeni `lib/providers/pvp_provider.dart`'a ekle (eger yoksa):
```dart
export '../data/remote/pvp_realtime_service.dart' show PvpRealtimeService;
```

`pvp_lobby_screen.dart`'ta import'u degistir:
```dart
import '../../providers/pvp_provider.dart';
```
(Zaten import ediliyor — ek import'u kaldir.)

- [ ] **Step 3: game_duel_controller.dart import'unu duzelt**

`lib/features/game_screen/game_duel_controller.dart:8`:

Eski:
```dart
import '../../data/remote/pvp_realtime_service.dart';
```

Ayni yaklasim: bu import'u kaldir ve `pvp_provider.dart` re-export'unu kullan. Controller'daki `PvpRealtimeService` tip referanslarini kontrol et.

```dart
import '../../providers/pvp_provider.dart';
```

- [ ] **Step 4: Dogrulama**

```bash
flutter analyze --no-fatal-infos
flutter test
```

Beklenen: 0 error, 0 warning. Tum testler gecmeli.

- [ ] **Step 5: Commit**

```bash
git add lib/features/pvp/pvp_lobby_screen.dart lib/features/game_screen/game_duel_controller.dart lib/providers/pvp_provider.dart
git commit -m "refactor: route PvpRealtimeService imports through provider layer (M.8)"
```

---

## Task 3: M.14 — Hardcoded Color(0x...) → color_constants.dart

**Files:**
- Modify: `lib/core/constants/color_constants.dart` (yeni sabitler ekle)
- Modify: 21 feature dosyasi (import + sabit kullanimina gecis)

**Hedef dosyalar (22 dosya, `color_constants.dart` haric 21):**
```
lib/features/settings/settings_screen.dart
lib/features/level_select/level_select_screen.dart
lib/features/game_screen/power_up_toolbar.dart
lib/features/season_pass/season_pass_widgets.dart
lib/features/character/character_widgets.dart
lib/features/island/island_widgets.dart
lib/features/game_screen/game_overlay.dart
lib/features/game_screen/game_screen.dart
lib/features/game_screen/game_cell_widget.dart
lib/features/leaderboard/leaderboard_widgets.dart
lib/features/season_pass/season_pass_background.dart
lib/features/game_screen/effects/power_up_effects.dart
lib/features/pvp/duel_result_overlay.dart
lib/features/game_screen/effects/feedback_effects.dart
lib/features/pvp/pvp_lobby_widgets.dart
lib/features/settings/settings_privacy.dart
lib/features/settings/settings_language.dart
lib/features/home_screen/widgets/daily_banner.dart
lib/features/game_screen/effects/cell_effects.dart
lib/app/app.dart
lib/features/game_screen/game_background.dart
```

- [ ] **Step 1: Tum Color(0x...) kullanımlarini tara ve benzersiz renkleri cikar**

Her dosyadaki `Color(0x...)` degerlerini listele. Tekrarlananları (2+ kullanimli) ve tekil olanlari ayir.
`GelColor.displayColor`'daki renkler zaten enum icinde — bunlari color_constants'a tasima.

- [ ] **Step 2: color_constants.dart'a yeni sabitler ekle**

Ornegin:
```dart
// ─── UI opacity/overlay sabitleri ────────────────────────────────────────────
const Color kOverlayDark = Color(0x80000000);   // %50 siyah overlay
const Color kSurface = Color(0xFF1A2A3A);        // kart/panel arkaplan
const Color kSurfaceLight = Color(0xFF2A3A4A);   // acik panel arkaplan
// ... (tarama sonucuna gore ek sabitler)
```

Isimlendirme kurallari:
- `k` prefix + semantik isim (renk degil, kullanim amaci)
- Benzer hex degerlerini birlestir (±10 hex farki varsa tek sabit)
- `Colors.white.withValues(alpha: ...)` gibi Flutter API kullanimlarini degistirme — yalnizca `Color(0x...)` literal'leri

- [ ] **Step 3: Feature dosyalarindaki hardcoded renkleri sabitlere degistir**

Her dosyada:
1. `color_constants.dart` import'u ekle (yoksa)
2. `Color(0x...)` → `kSabitAdi` ile degistir

- [ ] **Step 4: Dogrulama**

```bash
flutter analyze --no-fatal-infos
flutter test
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/constants/color_constants.dart lib/features/ lib/app/
git commit -m "refactor: extract 60+ hardcoded colors to color_constants.dart (M.14)"
```

---

## Task 4: M.17 — ShapeGenerator static → Instance-Based

**Files:**
- Modify: `lib/game/shapes/gel_shape.dart` (ShapeGenerator sinifi)
- Modify: `lib/game/world/game_world.dart` (ShapeGenerator kullanimi)
- Modify: `lib/features/game_screen/game_screen.dart` (ShapeGenerator kullanimi)
- Test: Mevcut shape testleri

**Sorun:** `ShapeGenerator` tamamiyla static. `_rng`, `_consecutiveLosses`, `_movesSinceLastClear` static — testler arasi state sizintisi olusturuyor.

- [ ] **Step 1: ShapeGenerator'i instance-based'e cevir**

`lib/game/shapes/gel_shape.dart`:

**Instance'a cevirilecek metodlar** (state veya `_rng` kullananlar):
- `_rng` → instance field (`Random`)
- `_consecutiveLosses`, `_movesSinceLastClear` → instance fields
- `recordLoss()`, `recordWin()`, `recordClear()`, `recordMoveWithoutClear()` → instance
- `_randomPiece()` → instance (`_rng` kullaniyor)
- `generateHand()` → instance (`_randomPiece` kullaniyor)
- `generateSmartHand()` → instance (`_rng`, mercy state kullaniyor)
- `_weightedRandomShape()` → instance (`_rng` kullaniyor)
- `_weightedRandomColor()` → instance (`_rng` kullaniyor)
- `_canAnyBePlaced()` → instance (pure, ama tutarlilik icin)
- `_findPlaceableShape()` → instance (`_rng` kullaniyor)

**Static kalacak metodlar** (stateless, kendi RNG'lerini yaratiyorlar):
- `getDifficulty()` → STATIC kalir (pure fonksiyon, state yok)
- `generateSeededHand(int seed)` → STATIC kalir (kendi `Random(seed)` olusturuyor)
- `generateNextSeededHand()` → STATIC kalir (`generateSeededHand` cagiriyor)
- `todaySeed()` → STATIC kalir (pure fonksiyon)

```dart
class ShapeGenerator {
  ShapeGenerator({Random? rng}) : _rng = rng ?? Random();

  final Random _rng;

  // ─── Merhamet Mekanizmasi durumu ────────────────────────────────────────
  int _consecutiveLosses = 0;
  int _movesSinceLastClear = 0;

  void recordLoss() => _consecutiveLosses++;
  void recordWin() => _consecutiveLosses = 0;
  void recordClear() => _movesSinceLastClear = 0;
  void recordMoveWithoutClear() => _movesSinceLastClear++;

  // --- Instance metodlar (static kaldirildi) ---
  (GelShape, GelColor) _randomPiece() { /* static kaldir */ }
  List<(GelShape, GelColor)> generateHand() => /* static kaldir */;
  List<(GelShape, GelColor)> generateSmartHand({...}) { /* static kaldir */ }
  GelShape _weightedRandomShape(double difficulty) { /* static kaldir */ }
  GelColor _weightedRandomColor(Grid grid) { /* static kaldir */ }
  bool _canAnyBePlaced(GridManager gm, ...) { /* static kaldir */ }
  (GelShape, GelColor) _findPlaceableShape(GridManager gm) { /* static kaldir */ }

  // --- Static kalacak metodlar (degisiklik yok) ---
  static double getDifficulty({required int score, int gamesPlayed = 0}) { ... }
  static List<(GelShape, GelColor)> generateSeededHand(int seed) { ... }
  static List<(GelShape, GelColor)> generateNextSeededHand({...}) { ... }
  static int todaySeed() { ... }
}
```

- [ ] **Step 2: game_world.dart'i guncelle**

`lib/game/world/game_world.dart`:

`GlooGame` sinifina `ShapeGenerator` instance'i ekle:

```dart
class GlooGame {
  GlooGame({required this.mode, this.levelData, ShapeGenerator? shapeGenerator})
    : _shapeGenerator = shapeGenerator ?? ShapeGenerator();

  final ShapeGenerator _shapeGenerator;
```

Instance cagrisi gereken yerler (`game_world.dart` icinde):
- Satir 232: `ShapeGenerator.generateSmartHand(...)` → `_shapeGenerator.generateSmartHand(...)`
- Satir 253: `ShapeGenerator.recordMoveWithoutClear()` → `_shapeGenerator.recordMoveWithoutClear()`
- Satir 331: `ShapeGenerator.recordClear()` → `_shapeGenerator.recordClear()`

Static kalacak cagriler (degisiklik yok):
- Satir 214-215: `ShapeGenerator.generateNextSeededHand(baseSeed: ShapeGenerator.todaySeed(), ...)` — static kalir
- Satir 223: `ShapeGenerator.generateSeededHand(...)` — static kalir
- Satir 228: `ShapeGenerator.getDifficulty(...)` — static kalir

- [ ] **Step 3: game_screen.dart'i guncelle**

`lib/features/game_screen/game_screen.dart:190`:

```dart
// Eski:
ShapeGenerator.generateSeededHand(ShapeGenerator.todaySeed())
// Yeni (degisiklik yok — bu static metodlar):
ShapeGenerator.generateSeededHand(ShapeGenerator.todaySeed())
```

Bu cagriler zaten static kalacak metodlari kullaniyor. `game_screen.dart`'ta baska `ShapeGenerator` kullanimi yoksa degisiklik gerekmez. Ancak dosyayi kontrol et ve varsa instance metodlari `_game.shapeGenerator` uzerinden yonlendir (public getter ekle: `ShapeGenerator get shapeGenerator => _shapeGenerator;`).

- [ ] **Step 4: Dogrulama**

```bash
flutter analyze --no-fatal-infos
flutter test
```

Beklenen: Tum testler gecmeli. Static state paylasimi ortadan kalkmis olmali.

- [ ] **Step 5: Commit**

```bash
git add lib/game/shapes/gel_shape.dart lib/game/world/game_world.dart lib/features/game_screen/game_screen.dart
git commit -m "refactor: convert ShapeGenerator from static to instance-based (M.17)"
```

---

## Task 5: M.18 — Mocktail Entegrasyonu

**Files:**
- Modify: `pubspec.yaml` (mocktail bagimliligi)
- Create: `test/helpers/mocks.dart` (merkezi mock siniflar)
- Test: Mevcut testlerden 2-3 tanesini mocktail'e gecir (ornek)

- [ ] **Step 1: mocktail bagimliligini ekle**

`pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mocktail: ^1.0.4
  image: ^4.0.0
  flutter_launcher_icons: ^0.14.0
```

```bash
flutter pub get
```

- [ ] **Step 2: Merkezi mock dosyasi olustur**

`test/helpers/mocks.dart`:

```dart
import 'package:mocktail/mocktail.dart';

import 'package:gloo/data/remote/remote_repository.dart';
import 'package:gloo/services/analytics_service.dart';
import 'package:gloo/services/ad_manager.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}
class MockAnalyticsService extends Mock implements AnalyticsService {}
class MockAdManager extends Mock implements AdManager {}
```

- [ ] **Step 3: Dogrulama**

```bash
flutter analyze --no-fatal-infos
flutter test
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock test/helpers/mocks.dart
git commit -m "feat: add mocktail dependency and central mock classes (M.18)"
```

---

## Task 6: M.19 — _evaluateBoard() Pipeline Testleri

**Files:**
- Create: `test/game/world/evaluate_board_test.dart`
- Read (referans): `lib/game/world/game_world.dart:239-310`

**Hedef:** `_evaluateBoard()` pipeline'indaki 3 alt metot icin testler: `_checkTimeTrialBonus`, `_checkLevelCompletion`, `_updateColorChefProgress`. Bu metodlar private oldugundan, `GlooGame` public API'si uzerinden dolayli test edilir.

- [ ] **Step 1: Test dosyasi olustur**

`test/game/world/evaluate_board_test.dart`:

**GlooGame API referansi:**
- Constructor: `GlooGame({required GameMode mode, LevelData? levelData})`
- `game.startGame()` — oyunu baslatir, grid'i olusturur
- `game.placePiece(List<(int, int)> cells, GelColor color)` — parca yerlestir, `_evaluateBoard()` cagrilir
- `game.gridManager` — grid'e dogrudan erisim
- Callback'ler:
  - `onChefProgress: void Function(int progress, int required)?`
  - `onTimerTick: void Function(int seconds)?` — time trial bonus'ta da cagirilir
  - `onLevelComplete: void Function()?` — parametresiz
  - `onLineClear: void Function(LineClearResult result)?`
  - `onScoreGained: void Function(int points)?`

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/models/game_mode.dart';
import 'package:gloo/game/levels/level_data.dart';
import 'package:gloo/game/world/game_world.dart';

void main() {
  group('_evaluateBoard pipeline', () {
    group('_updateColorChefProgress', () {
      test('colorChef modunda hedef renk sentezi ilerleme arttirir', () {
        int chefCurrent = 0;
        int chefRequired = 0;
        final game = GlooGame(mode: GameMode.colorChef);
        game.onChefProgress = (current, required) {
          chefCurrent = current;
          chefRequired = required;
        };

        game.startGame();

        // Chef ilk seviye: orange (red + yellow), requiredCount: 3
        // Izgaraya red ve yellow yan yana yerlestir → sentez → onChefProgress
        // red parca yerlestir
        game.placePiece([(0, 0)], GelColor.red);
        // yellow parca yan hucreye yerlestir → sentez tetiklenmeli
        game.placePiece([(0, 1)], GelColor.yellow);

        // Sentez basarili olduysa chefProgress callback tetiklenir
        // Not: Sentez gerceklesmeyebilir (bitisik hucre kurali)
        // Bu durumda test'i grid'e dogrudan setCell ile hazirlayarak test et:
        if (chefCurrent == 0) {
          // Alternatif: grid'e dogrudan yerlesim
          game.gridManager.setCell(2, 0, GelColor.red);
          game.gridManager.setCell(2, 1, GelColor.yellow);
          // placePiece ile trigger
          game.placePiece([(2, 2)], GelColor.red);
        }

        expect(chefCurrent, greaterThan(0),
            reason: 'Chef progress should advance after target color synthesis');
        expect(chefRequired, equals(3));
      });
    });

    group('_checkTimeTrialBonus', () {
      test('timeTrial modunda satir temizleme bonus sure ekler', () {
        final timerValues = <int>[];
        final game = GlooGame(mode: GameMode.timeTrial);
        game.onTimerTick = (seconds) {
          timerValues.add(seconds);
        };

        game.startGame();
        final initialSeconds = game.remainingSeconds;

        // Bir satiri tamamen doldur (8 hucre, varsayilan grid 8 sutun)
        for (int col = 0; col < 8; col++) {
          game.gridManager.setCell(9, col, GelColor.red);
        }
        // Son hucreyi bos birak ve placePiece ile trigger et
        game.gridManager.setCell(9, 7, null);
        game.placePiece([(9, 7)], GelColor.red);

        // _checkTimeTrialBonus: her temizlenen satir icin
        // GameConstants.timeTrialLineClearBonus (2) saniye eklenir
        // onTimerTick callback ile guncellenen sure raporlanir
        expect(game.remainingSeconds, greaterThan(initialSeconds),
            reason: 'Time trial should add bonus seconds on line clear');
      });
    });

    group('_checkLevelCompletion', () {
      test('level modunda hedef skora ulasinca onLevelComplete tetiklenir', () {
        bool levelCompleted = false;
        final levelData = LevelData(id: 1, targetScore: 10);
        final game = GlooGame(mode: GameMode.level, levelData: levelData);
        game.onLevelComplete = () {
          levelCompleted = true;
        };

        game.startGame();

        // Hedef skor 10, bir satir temizleyerek skoru hedefin uzerine cikar
        // Satiri doldur
        for (int col = 0; col < 8; col++) {
          game.gridManager.setCell(9, col, GelColor.blue);
        }
        // Son hucreyi placePiece ile tetikle
        game.gridManager.setCell(9, 7, null);
        game.placePiece([(9, 7)], GelColor.blue);

        expect(levelCompleted, isTrue,
            reason: 'onLevelComplete should fire when score >= targetScore');
      });
    });
  });
}
```

- [ ] **Step 2: Testleri calistir**

```bash
flutter test test/game/world/evaluate_board_test.dart -v
```

Beklenen: Testler gecmeli (veya GlooGame API'sine gore duzeltme gerekli).

- [ ] **Step 3: Dogrulama**

```bash
flutter analyze --no-fatal-infos
flutter test
```

- [ ] **Step 4: Commit**

```bash
git add test/game/world/evaluate_board_test.dart
git commit -m "test: add _evaluateBoard pipeline tests for chef/timeTrial/level (M.19)"
```

---

## Uygulama Sirasi ve Bagimliliklar

**Bagimsiz (paralel uygulanabilir):** Task 1 (M.6), Task 2 (M.8), Task 3 (M.14), Task 5 (M.18)

**Siralamali bagimlilik:** Task 4 (M.17) → Task 6 (M.19)
- Task 6'daki testlerde `GlooGame` kullaniliyor. M.17 constructor'i degistirdigi icin M.19 testleri M.17'den sonra yazilmali.
- Eger paralel uygulanirsa, Task 6 agenti M.17'nin yeni constructor'ini (`ShapeGenerator? shapeGenerator` parametresi) kullanmali.

## Notlar

- **M.5 (`StateNotifierProvider` → `NotifierProvider`):** Tarama sonucu: projede `StateNotifierProvider` kullanimi bulunamadi. Gorev zaten tamamlanmis. Todo'dan isaretlenecek.
- **M.3 (Firebase App Check enforce):** Harici bagimlilik (Firebase Console). Bu plan kapsaminda degil.
- **M.20 (Sunucu tarafinda ELO):** Harici bagimlilik (Supabase Edge Function). Bu plan kapsaminda degil.
- **Task 3 (M.14)** en buyuk gorev — 21 dosyada degisiklik. Dikkatli tarama ve gruplama gerektirir.
