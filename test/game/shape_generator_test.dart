import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/constants/game_constants.dart';
import 'package:gloo/game/shapes/gel_shape.dart';
import 'package:gloo/game/world/grid_manager.dart';

void main() {
  // ─── GelShape ──────────────────────────────────────────────────────────────

  group('GelShape', () {
    test('dot shape has 1 cell', () {
      const dot = GelShape(cells: [(0, 0)], name: 'dot');
      expect(dot.cellCount, 1);
      expect(dot.rowCount, 1);
      expect(dot.colCount, 1);
    });

    test('h3 shape has correct dimensions', () {
      const h3 = GelShape(cells: [(0, 0), (0, 1), (0, 2)], name: 'h3');
      expect(h3.cellCount, 3);
      expect(h3.rowCount, 1);
      expect(h3.colCount, 3);
    });

    test('L shape has correct dimensions', () {
      const lShape =
          GelShape(cells: [(0, 0), (1, 0), (2, 0), (2, 1)], name: 'L');
      expect(lShape.cellCount, 4);
      expect(lShape.rowCount, 3);
      expect(lShape.colCount, 2);
    });

    test('at() offsets all cells by anchor', () {
      const h2 = GelShape(cells: [(0, 0), (0, 1)], name: 'h2');
      final positioned = h2.at(3, 5);
      expect(positioned, [(3, 5), (3, 6)]);
    });

    test('rotated() rotates 90 degrees clockwise', () {
      // h3: (0,0),(0,1),(0,2) → rotated: (0,0),(1,0),(2,0) (normalized)
      const h3 = GelShape(cells: [(0, 0), (0, 1), (0, 2)], name: 'h3');
      final rotated = h3.rotated();
      expect(rotated.cellCount, 3);
      expect(rotated.name, 'h3_r');
      // Yatay cubuk dikleye donmeli
      expect(rotated.rowCount, 3);
      expect(rotated.colCount, 1);
    });

    test('rotated twice gives 180 degree rotation', () {
      const l3a = GelShape(cells: [(0, 0), (1, 0), (1, 1)], name: 'l3a');
      final rotated180 = l3a.rotated().rotated();
      expect(rotated180.cellCount, 3);
    });
  });

  // ─── kAllShapes ────────────────────────────────────────────────────────────

  group('kAllShapes', () {
    test('contains 17 shapes', () {
      expect(kAllShapes.length, 17);
    });

    test('shape size categories are correct', () {
      expect(kSmallShapes.every((s) => s.cellCount <= 2), isTrue);
      expect(kMediumShapes.every((s) => s.cellCount == 3), isTrue);
      expect(kLargeShapes.every((s) => s.cellCount >= 4), isTrue);
    });

    test('all shapes have non-empty cells', () {
      for (final shape in kAllShapes) {
        expect(shape.cells, isNotEmpty);
        expect(shape.name, isNotEmpty);
      }
    });
  });

  // ─── ShapeGenerator ────────────────────────────────────────────────────────

  group('ShapeGenerator', () {
    late ShapeGenerator sg;

    setUp(() {
      sg = ShapeGenerator();
    });

    test('generateHand returns 3 pieces', () {
      final hand = sg.generateHand();
      expect(hand.length, GameConstants.shapesInHand);
      expect(hand.length, 3);
    });

    test('generateHand pieces use only primary colors', () {
      // Coklu deneme — rastgele oldugundan birden fazla cagri
      for (int i = 0; i < 20; i++) {
        final hand = sg.generateHand();
        for (final (_, color) in hand) {
          expect(kPrimaryColors, contains(color),
              reason: '$color should be a primary color');
        }
      }
    });

    test('generateHand pieces use valid shapes', () {
      for (int i = 0; i < 20; i++) {
        final hand = sg.generateHand();
        for (final (shape, _) in hand) {
          expect(kAllShapes, contains(shape));
        }
      }
    });

    test('generateSeededHand is deterministic', () {
      final hand1 = ShapeGenerator.generateSeededHand(42);
      final hand2 = ShapeGenerator.generateSeededHand(42);

      expect(hand1.length, hand2.length);
      for (int i = 0; i < hand1.length; i++) {
        expect(hand1[i].$1.name, hand2[i].$1.name);
        expect(hand1[i].$2, hand2[i].$2);
      }
    });

    test('different seeds produce different hands', () {
      final hand1 = ShapeGenerator.generateSeededHand(1);
      final hand2 = ShapeGenerator.generateSeededHand(999);

      // Farkli seed → farkli el (cok dusuk olasilikla ayni olabilir ama genellikle farkli)
      bool anyDifferent = false;
      for (int i = 0; i < hand1.length; i++) {
        if (hand1[i].$1.name != hand2[i].$1.name ||
            hand1[i].$2 != hand2[i].$2) {
          anyDifferent = true;
          break;
        }
      }
      expect(anyDifferent, isTrue);
    });

    test('generateNextSeededHand uses combined seed', () {
      final hand = ShapeGenerator.generateNextSeededHand(
        baseSeed: 42,
        handIndex: 1,
        moveCount: 5,
      );
      expect(hand.length, 3);

      // Ayni parametreler → ayni sonuc
      final hand2 = ShapeGenerator.generateNextSeededHand(
        baseSeed: 42,
        handIndex: 1,
        moveCount: 5,
      );
      for (int i = 0; i < hand.length; i++) {
        expect(hand[i].$1.name, hand2[i].$1.name);
        expect(hand[i].$2, hand2[i].$2);
      }
    });

    test('generateSmartHand returns 3 pieces', () {
      final gm = GridManager(rows: 8, cols: 8);
      final hand = sg.generateSmartHand(
        gridManager: gm,
        difficulty: 0.5,
      );
      expect(hand.length, 3);
    });

    test('generateSmartHand ensures at least one placeable piece', () {
      // Izgarayi neredeyse tamamen doldur
      final gm = GridManager(rows: 4, cols: 4);
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          if (r == 3 && c == 3) continue; // 1 bos birak
          gm.place([(r, c)], GelColor.red);
        }
      }

      final hand = sg.generateSmartHand(
        gridManager: gm,
        difficulty: 0.5,
      );
      expect(hand, isNotEmpty);
      // En az 1 parca yerlestirilebilir olmali
      bool anyPlaceable = false;
      for (final (shape, color) in hand) {
        for (int r = 0; r <= gm.rows - shape.rowCount; r++) {
          for (int c = 0; c <= gm.cols - shape.colCount; c++) {
            if (gm.canPlace(shape.at(r, c), color)) {
              anyPlaceable = true;
            }
          }
        }
      }
      expect(anyPlaceable, isTrue);
    });

    test('todaySeed returns yyyymmdd format', () {
      final seed = ShapeGenerator.todaySeed();
      final now = DateTime.now();
      final expected = now.year * 10000 + now.month * 100 + now.day;
      expect(seed, expected);
    });
  });

  // ─── getDifficulty ─────────────────────────────────────────────────────────

  group('ShapeGenerator.getDifficulty', () {
    test('score 0, games 0 → difficulty 0.0', () {
      expect(ShapeGenerator.getDifficulty(score: 0, gamesPlayed: 0), 0.0);
    });

    test('score 5000 → base difficulty 0.8', () {
      final d = ShapeGenerator.getDifficulty(score: 5000);
      expect(d, closeTo(0.8, 0.01));
    });

    test('score 10000 → capped at 0.8 base', () {
      final d = ShapeGenerator.getDifficulty(score: 10000);
      expect(d, closeTo(0.8, 0.01));
    });

    test('gamesPlayed 50 adds 0.2 experience bonus', () {
      final d = ShapeGenerator.getDifficulty(score: 0, gamesPlayed: 50);
      expect(d, closeTo(0.2, 0.01));
    });

    test('max difficulty is 0.95', () {
      final d = ShapeGenerator.getDifficulty(score: 10000, gamesPlayed: 100);
      expect(d, 0.95);
    });

    test('difficulty never exceeds 0.95', () {
      final d = ShapeGenerator.getDifficulty(score: 99999, gamesPlayed: 9999);
      expect(d, 0.95);
    });

    test('mid-range values', () {
      // score 2500 → base = (2500/5000).clamp(0,0.8) = 0.5
      // games 25 → bonus = (25/50).clamp(0,0.2) = 0.2
      // total = 0.7
      final d = ShapeGenerator.getDifficulty(score: 2500, gamesPlayed: 25);
      expect(d, closeTo(0.7, 0.01));
    });
  });

  // ─── Merhamet mekanizmasi ──────────────────────────────────────────────────

  group('Mercy mechanism', () {
    late ShapeGenerator sg;

    setUp(() {
      sg = ShapeGenerator();
    });

    test('recordLoss and recordWin track state', () {
      sg.recordLoss();
      sg.recordLoss();
      sg.recordLoss();
      // 3 ardisik kayip → generateSmartHand zorlugu dusurur
      sg.recordWin();
      // Win sonrasi sifirlandi
    });

    test('recordClear and recordMoveWithoutClear track state', () {
      sg.recordMoveWithoutClear();
      sg.recordMoveWithoutClear();
      sg.recordClear();
      // Clear sonrasi sifirlandi
    });
  });
}
