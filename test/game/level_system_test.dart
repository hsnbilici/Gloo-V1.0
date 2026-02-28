import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/game/levels/level_data.dart';
import 'package:gloo/game/levels/level_progression.dart';
import 'package:gloo/game/world/cell_type.dart';
import 'package:gloo/game/world/grid_manager.dart';

void main() {
  // ─── LevelData ──────────────────────────────────────────────────────────

  group('LevelData', () {
    test('default values', () {
      const level = LevelData(id: 1, targetScore: 200);
      expect(level.rows, 10);
      expect(level.cols, 8);
      expect(level.shape, MapShape.rectangle);
      expect(level.maxMoves, isNull);
      expect(level.specialCells, isEmpty);
      expect(level.availableColors, isNull);
    });

    test('custom dimensions', () {
      const level = LevelData(id: 5, rows: 6, cols: 6, targetScore: 400);
      expect(level.rows, 6);
      expect(level.cols, 6);
    });

    test('computeShapeCells returns empty for rectangle', () {
      const level = LevelData(id: 1, targetScore: 200, shape: MapShape.rectangle);
      expect(level.computeShapeCells(), isEmpty);
    });

    test('computeShapeCells returns stones for diamond', () {
      const level = LevelData(
        id: 1, rows: 8, cols: 8, targetScore: 200,
        shape: MapShape.diamond,
      );
      final stones = level.computeShapeCells();
      expect(stones, isNotEmpty);
      for (final config in stones.values) {
        expect(config.type, CellType.stone);
      }
    });

    test('computeShapeCells returns stones for cross', () {
      const level = LevelData(
        id: 1, rows: 10, cols: 8, targetScore: 200,
        shape: MapShape.cross,
      );
      final stones = level.computeShapeCells();
      expect(stones, isNotEmpty);
    });

    test('computeShapeCells returns stones for lShape', () {
      const level = LevelData(
        id: 1, rows: 10, cols: 8, targetScore: 200,
        shape: MapShape.lShape,
      );
      final stones = level.computeShapeCells();
      expect(stones, isNotEmpty);
    });

    test('computeShapeCells returns stones for corridor', () {
      const level = LevelData(
        id: 1, rows: 10, cols: 8, targetScore: 200,
        shape: MapShape.corridor,
      );
      final stones = level.computeShapeCells();
      expect(stones, isNotEmpty);
    });

    test('allSpecialCells merges shape and level cells', () {
      const level = LevelData(
        id: 1, rows: 8, cols: 8, targetScore: 200,
        shape: MapShape.diamond,
        specialCells: {
          (3, 3): CellConfig(type: CellType.ice, iceLayer: 1),
        },
      );
      final merged = level.allSpecialCells();
      expect(merged.containsKey((3, 3)), isTrue);
      expect(merged[(3, 3)]!.type, CellType.ice); // level def overrides
    });
  });

  // ─── MapShape ───────────────────────────────────────────────────────────

  group('MapShape', () {
    test('has 5 values', () {
      expect(MapShape.values.length, 5);
    });
  });

  // ─── LevelProgression ──────────────────────────────────────────────────

  group('LevelProgression', () {
    test('getLevel returns null for level 0', () {
      expect(LevelProgression.getLevel(0), isNull);
    });

    test('getLevel returns null for negative id', () {
      expect(LevelProgression.getLevel(-1), isNull);
    });

    test('getLevel returns level 1', () {
      final level = LevelProgression.getLevel(1);
      expect(level, isNotNull);
      expect(level!.id, 1);
      expect(level.rows, 6);
      expect(level.cols, 6);
      expect(level.targetScore, 200);
    });

    test('getLevel returns all 50 predefined levels', () {
      for (int i = 1; i <= 50; i++) {
        final level = LevelProgression.getLevel(i);
        expect(level, isNotNull, reason: 'Level $i should exist');
        expect(level!.id, i);
        expect(level.targetScore, greaterThan(0));
      }
    });

    test('totalPredefinedLevels is 50', () {
      expect(LevelProgression.totalPredefinedLevels, 50);
    });

    test('breathing room levels are easier', () {
      // Level 10 is breathing room
      final l10 = LevelProgression.getLevel(10)!;
      final l9 = LevelProgression.getLevel(9)!;
      expect(l10.targetScore, lessThan(l9.targetScore));
    });

    test('isBreathingRoom for multiples of 10', () {
      expect(LevelProgression.isBreathingRoom(10), isTrue);
      expect(LevelProgression.isBreathingRoom(20), isTrue);
      expect(LevelProgression.isBreathingRoom(30), isTrue);
      expect(LevelProgression.isBreathingRoom(50), isTrue);
      expect(LevelProgression.isBreathingRoom(15), isFalse);
      expect(LevelProgression.isBreathingRoom(1), isFalse);
    });

    test('procedural levels (51+) are generated', () {
      final level = LevelProgression.getLevel(51);
      expect(level, isNotNull);
      expect(level!.id, 51);
    });

    test('procedural breathing room levels are simpler', () {
      final l60 = LevelProgression.getLevel(60)!;
      expect(l60.rows, 8);
      expect(l60.cols, 6);
    });

    test('levels 21-50 may have ice cells', () {
      final l21 = LevelProgression.getLevel(21)!;
      expect(l21.specialCells, isNotEmpty);
      final iceCell = l21.specialCells.values.first;
      expect(iceCell.type, CellType.ice);
    });

    test('levels 41+ may have maxMoves', () {
      final l41 = LevelProgression.getLevel(41)!;
      expect(l41.maxMoves, isNotNull);
      expect(l41.maxMoves!, greaterThan(0));
    });

    test('procedural level 101+ gets stone obstacles', () {
      final level = LevelProgression.getLevel(101);
      expect(level, isNotNull);
      // 101+ should have stones in specialCells (procedural)
      final hasStone = level!.specialCells.values
          .any((c) => c.type == CellType.stone);
      expect(hasStone, isTrue);
    });

    test('procedural level 200+ gets gravity cells', () {
      final level = LevelProgression.getLevel(201);
      expect(level, isNotNull);
      final hasGravity = level!.specialCells.values
          .any((c) => c.type == CellType.gravity);
      expect(hasGravity, isTrue);
    });
  });

  // ─── CellConfig ─────────────────────────────────────────────────────────

  group('CellConfig', () {
    test('default values', () {
      const config = CellConfig(type: CellType.normal);
      expect(config.iceLayer, 0);
      expect(config.lockedColor, isNull);
    });
  });
}
