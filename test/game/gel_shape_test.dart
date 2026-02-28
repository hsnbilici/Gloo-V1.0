import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/constants/game_constants.dart';
import 'package:gloo/game/shapes/gel_shape.dart';
import 'package:gloo/game/world/grid_manager.dart';

void main() {
  // ─── GelShape ───────────────────────────────────────────────────────────

  group('GelShape', () {
    test('dot shape has 1 cell', () {
      final dot = kAllShapes.firstWhere((s) => s.name == 'dot');
      expect(dot.cellCount, 1);
      expect(dot.rowCount, 1);
      expect(dot.colCount, 1);
    });

    test('h2 shape is horizontal 2-cell', () {
      final h2 = kAllShapes.firstWhere((s) => s.name == 'h2');
      expect(h2.cellCount, 2);
      expect(h2.rowCount, 1);
      expect(h2.colCount, 2);
    });

    test('v2 shape is vertical 2-cell', () {
      final v2 = kAllShapes.firstWhere((s) => s.name == 'v2');
      expect(v2.cellCount, 2);
      expect(v2.rowCount, 2);
      expect(v2.colCount, 1);
    });

    test('sq shape is 2x2', () {
      final sq = kAllShapes.firstWhere((s) => s.name == 'sq');
      expect(sq.cellCount, 4);
      expect(sq.rowCount, 2);
      expect(sq.colCount, 2);
    });

    test('at() offsets all cells by anchor', () {
      const shape = GelShape(cells: [(0, 0), (0, 1)], name: 'h2');
      final positioned = shape.at(3, 5);
      expect(positioned, [(3, 5), (3, 6)]);
    });

    test('rotated() rotates 90 degrees clockwise', () {
      // h2: (0,0), (0,1) → rotated → should become vertical
      const h2 = GelShape(cells: [(0, 0), (0, 1)], name: 'h2');
      final rotated = h2.rotated();
      expect(rotated.cells.length, 2);
      expect(rotated.name, 'h2_r');
      // Should now be 2 rows, 1 col (vertical)
      expect(rotated.rowCount, 2);
      expect(rotated.colCount, 1);
    });

    test('double rotation gives 180 degrees', () {
      const L = GelShape(
        cells: [(0, 0), (1, 0), (2, 0), (2, 1)],
        name: 'L',
      );
      final r180 = L.rotated().rotated();
      expect(r180.cells.length, 4);
    });

    test('4 rotations return to equivalent shape', () {
      const h2 = GelShape(cells: [(0, 0), (0, 1)], name: 'h2');
      final r4 = h2.rotated().rotated().rotated().rotated();
      expect(r4.cellCount, h2.cellCount);
      expect(r4.rowCount, h2.rowCount);
      expect(r4.colCount, h2.colCount);
    });
  });

  // ─── kAllShapes ─────────────────────────────────────────────────────────

  group('kAllShapes', () {
    test('contains 17 shapes', () {
      expect(kAllShapes.length, 17);
    });

    test('all shapes have non-empty cells', () {
      for (final shape in kAllShapes) {
        expect(shape.cells, isNotEmpty);
        expect(shape.name, isNotEmpty);
      }
    });

    test('all cells have non-negative coordinates', () {
      for (final shape in kAllShapes) {
        for (final (r, c) in shape.cells) {
          expect(r, greaterThanOrEqualTo(0));
          expect(c, greaterThanOrEqualTo(0));
        }
      }
    });
  });

  // ─── Shape categories ───────────────────────────────────────────────────

  group('Shape categories', () {
    test('small shapes have 1-2 cells', () {
      for (final shape in kSmallShapes) {
        expect(shape.cellCount, lessThanOrEqualTo(2));
      }
    });

    test('medium shapes have 3 cells', () {
      for (final shape in kMediumShapes) {
        expect(shape.cellCount, 3);
      }
    });

    test('large shapes have 4+ cells', () {
      for (final shape in kLargeShapes) {
        expect(shape.cellCount, greaterThanOrEqualTo(4));
      }
    });

    test('categories cover all shapes', () {
      final total = kSmallShapes.length + kMediumShapes.length + kLargeShapes.length;
      expect(total, kAllShapes.length);
    });
  });

  // ─── ShapeGenerator ─────────────────────────────────────────────────────

  group('ShapeGenerator', () {
    test('generateHand returns shapesInHand pieces', () {
      final hand = ShapeGenerator.generateHand();
      expect(hand.length, GameConstants.shapesInHand);
    });

    test('generateHand returns valid shapes and primary colors', () {
      final hand = ShapeGenerator.generateHand();
      for (final (shape, color) in hand) {
        expect(shape.cells, isNotEmpty);
        expect(kPrimaryColors, contains(color));
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
      final hand1 = ShapeGenerator.generateSeededHand(42);
      final hand2 = ShapeGenerator.generateSeededHand(99);
      // Very unlikely to be identical (but theoretically possible)
      final names1 = hand1.map((h) => '${h.$1.name}_${h.$2.name}').toList();
      final names2 = hand2.map((h) => '${h.$1.name}_${h.$2.name}').toList();
      expect(names1, isNot(equals(names2)));
    });

    test('generateNextSeededHand is deterministic', () {
      final h1 = ShapeGenerator.generateNextSeededHand(
        baseSeed: 100, handIndex: 0, moveCount: 0,
      );
      final h2 = ShapeGenerator.generateNextSeededHand(
        baseSeed: 100, handIndex: 0, moveCount: 0,
      );
      for (int i = 0; i < h1.length; i++) {
        expect(h1[i].$1.name, h2[i].$1.name);
        expect(h1[i].$2, h2[i].$2);
      }
    });

    test('todaySeed returns positive integer in yyyymmdd format', () {
      final seed = ShapeGenerator.todaySeed();
      expect(seed, greaterThan(20000000));
      expect(seed, lessThan(30000000));
    });

    test('getDifficulty returns 0 for score=0 gamesPlayed=0', () {
      expect(ShapeGenerator.getDifficulty(score: 0, gamesPlayed: 0), 0.0);
    });

    test('getDifficulty caps at 0.95', () {
      final diff = ShapeGenerator.getDifficulty(score: 100000, gamesPlayed: 1000);
      expect(diff, 0.95);
    });

    test('getDifficulty increases with score', () {
      final low = ShapeGenerator.getDifficulty(score: 100);
      final high = ShapeGenerator.getDifficulty(score: 3000);
      expect(high, greaterThan(low));
    });

    test('generateSmartHand returns valid hand', () {
      final grid = GridManager();
      final hand = ShapeGenerator.generateSmartHand(
        gridManager: grid,
        difficulty: 0.5,
      );
      expect(hand.length, GameConstants.shapesInHand);
      for (final (shape, color) in hand) {
        expect(shape.cells, isNotEmpty);
        expect(kPrimaryColors, contains(color));
      }
    });

    test('mercy mechanism: recordLoss and recordWin work', () {
      // These are static methods — just ensure they don't throw
      ShapeGenerator.recordLoss();
      ShapeGenerator.recordLoss();
      ShapeGenerator.recordLoss();
      ShapeGenerator.recordWin();
      ShapeGenerator.recordClear();
      ShapeGenerator.recordMoveWithoutClear();
    });
  });
}
