import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/levels/level_data.dart';
import 'package:gloo/game/levels/level_progression.dart';
import 'package:gloo/game/world/cell_type.dart';
import 'package:gloo/game/world/grid_manager.dart';

void main() {
  // ─── LevelProgression ──────────────────────────────────────────────────────

  group('LevelProgression', () {
    test('has 50 predefined levels', () {
      expect(LevelProgression.totalPredefinedLevels, 50);
    });

    test('getLevel returns null for id < 1', () {
      expect(LevelProgression.getLevel(0), isNull);
      expect(LevelProgression.getLevel(-1), isNull);
    });

    test('getLevel returns predefined level for 1-50', () {
      for (int i = 1; i <= 50; i++) {
        final level = LevelProgression.getLevel(i);
        expect(level, isNotNull, reason: 'Level $i should exist');
        expect(level!.id, i);
      }
    });

    test('level 1 is a simple 6x6 grid', () {
      final level = LevelProgression.getLevel(1)!;
      expect(level.rows, 6);
      expect(level.cols, 6);
      expect(level.targetScore, 200);
    });

    test('levels 1-20 have no special cells (learning phase)', () {
      // Ilk 20 seviyede sadece normal hucreler (bazilari bos specialCells)
      for (int i = 1; i <= 20; i++) {
        final level = LevelProgression.getLevel(i)!;
        // Some predefined levels in 1-20 may have empty specialCells
        if (level.specialCells.isNotEmpty) {
          // Eger varsa bile ice olmamali (21+ icin)
          // Aslinda 1-20 arasinda hicbir ozel hucre yok
          fail('Level $i should not have special cells');
        }
      }
    });

    test('levels 21+ introduce ice cells', () {
      final level21 = LevelProgression.getLevel(21)!;
      expect(level21.specialCells, isNotEmpty);
      final hasIce =
          level21.specialCells.values.any((c) => c.type == CellType.ice);
      expect(hasIce, isTrue, reason: 'Level 21 should have ice cells');
    });

    test('breathing room every 10 levels', () {
      expect(LevelProgression.isBreathingRoom(10), isTrue);
      expect(LevelProgression.isBreathingRoom(20), isTrue);
      expect(LevelProgression.isBreathingRoom(30), isTrue);
      expect(LevelProgression.isBreathingRoom(40), isTrue);
      expect(LevelProgression.isBreathingRoom(50), isTrue);
    });

    test('non-multiples-of-10 are not breathing room', () {
      expect(LevelProgression.isBreathingRoom(1), isFalse);
      expect(LevelProgression.isBreathingRoom(15), isFalse);
      expect(LevelProgression.isBreathingRoom(25), isFalse);
      expect(LevelProgression.isBreathingRoom(49), isFalse);
    });

    test('breathing room levels are simpler', () {
      final br10 = LevelProgression.getLevel(10)!;
      final level9 = LevelProgression.getLevel(9)!;
      // Breathing room genellikle daha kucuk grid veya daha dusuk skor
      expect(br10.targetScore, lessThan(level9.targetScore));
    });

    test('target scores increase within sections (breathing rooms excluded)',
        () {
      // Her 10'lu bolum icinde (breathing room haric) skor artar
      // Ama bir bolumden digerine gecerken breathing room sonrasi
      // skor dusebilir (yeni bolumun baslangici)
      for (final range in [(1, 9), (11, 19), (21, 29), (31, 39), (41, 49)]) {
        int prevScore = 0;
        for (int i = range.$1; i <= range.$2; i++) {
          final level = LevelProgression.getLevel(i)!;
          expect(level.targetScore, greaterThanOrEqualTo(prevScore),
              reason: 'Level $i score should be >= previous in section');
          prevScore = level.targetScore;
        }
      }
    });

    test('procedural level generation for 51+', () {
      final level = LevelProgression.getLevel(51);
      expect(level, isNotNull);
      expect(level!.id, 51);
      // Prosedurel seviye icin beklenen ozellikler
      expect(level.rows, greaterThanOrEqualTo(6));
      expect(level.cols, greaterThanOrEqualTo(6));
      expect(level.targetScore, greaterThan(0));
    });

    test('procedural level 100 has reasonable properties', () {
      final level = LevelProgression.getLevel(100)!;
      expect(level.id, 100);
      // Breathing room
      expect(LevelProgression.isBreathingRoom(100), isTrue);
      expect(level.rows, 8);
      expect(level.cols, 6);
    });

    test('procedural level 51+ has ice cells (2 layer)', () {
      // Non-breathing room level
      final level = LevelProgression.getLevel(55)!;
      final hasIce = level.specialCells.values
          .any((c) => c.type == CellType.ice && c.iceLayer == 2);
      expect(hasIce, isTrue);
    });

    test('procedural level 101+ has maxMoves', () {
      final level = LevelProgression.getLevel(105)!;
      expect(level.maxMoves, isNotNull);
    });

    test('procedural level 200+ has gravity cells', () {
      final level = LevelProgression.getLevel(205)!;
      final hasGravity =
          level.specialCells.values.any((c) => c.type == CellType.gravity);
      expect(hasGravity, isTrue);
    });

    test('procedural breathing room level is simpler', () {
      final brLevel = LevelProgression.getLevel(60)!;
      expect(brLevel.rows, 8);
      expect(brLevel.cols, 6);
      // Breathing room → no special cells
      expect(brLevel.specialCells, isEmpty);
    });

    test('same level id always produces same procedural level', () {
      final a = LevelProgression.getLevel(75)!;
      final b = LevelProgression.getLevel(75)!;
      expect(a.id, b.id);
      expect(a.rows, b.rows);
      expect(a.cols, b.cols);
      expect(a.targetScore, b.targetScore);
      expect(a.specialCells.length, b.specialCells.length);
    });
  });

  // ─── LevelData ─────────────────────────────────────────────────────────────

  group('LevelData', () {
    test('default values', () {
      const level = LevelData(id: 1, targetScore: 100);
      expect(level.rows, 10);
      expect(level.cols, 8);
      expect(level.maxMoves, isNull);
      expect(level.shape, MapShape.rectangle);
      expect(level.description, isNull);
      expect(level.specialCells, isEmpty);
    });

    test('computeShapeCells rectangle returns empty', () {
      const level = LevelData(
        id: 1,
        targetScore: 100,
        shape: MapShape.rectangle,
      );
      expect(level.computeShapeCells(), isEmpty);
    });

    test('computeShapeCells diamond adds stone corners', () {
      const level = LevelData(
        id: 1,
        rows: 8,
        cols: 8,
        targetScore: 100,
        shape: MapShape.diamond,
      );
      final stones = level.computeShapeCells();
      expect(stones, isNotEmpty);
      // Tum stone'lar CellType.stone olmali
      for (final config in stones.values) {
        expect(config.type, CellType.stone);
      }
    });

    test('computeShapeCells cross adds corner stones', () {
      const level = LevelData(
        id: 1,
        rows: 10,
        cols: 8,
        targetScore: 100,
        shape: MapShape.cross,
      );
      final stones = level.computeShapeCells();
      expect(stones, isNotEmpty);
    });

    test('computeShapeCells lShape adds top-right stones', () {
      const level = LevelData(
        id: 1,
        rows: 10,
        cols: 8,
        targetScore: 100,
        shape: MapShape.lShape,
      );
      final stones = level.computeShapeCells();
      expect(stones, isNotEmpty);
      // Sag ust kosede stone olmali
      expect(stones.containsKey((0, 7)), isTrue);
    });

    test('computeShapeCells corridor adds side stones', () {
      const level = LevelData(
        id: 1,
        rows: 10,
        cols: 8,
        targetScore: 100,
        shape: MapShape.corridor,
      );
      final stones = level.computeShapeCells();
      expect(stones, isNotEmpty);
      // Sol ve sag kenarlarda stone olmali
      expect(stones.containsKey((0, 0)), isTrue);
      expect(stones.containsKey((0, 7)), isTrue);
    });

    test('allSpecialCells merges shape and level cells', () {
      const level = LevelData(
        id: 1,
        rows: 10,
        cols: 8,
        targetScore: 100,
        shape: MapShape.corridor,
        specialCells: {
          (5, 4): CellConfig(type: CellType.ice, iceLayer: 1),
        },
      );
      final all = level.allSpecialCells();
      // Hem corridor stone'lari hem de ice hucresi olmali
      expect(all.containsKey((0, 0)), isTrue); // corridor stone
      expect(all.containsKey((5, 4)), isTrue); // ice cell
      expect(all[(5, 4)]!.type, CellType.ice);
    });

    test('level specialCells override shape cells', () {
      const level = LevelData(
        id: 1,
        rows: 10,
        cols: 8,
        targetScore: 100,
        shape: MapShape.corridor,
        specialCells: {
          (0, 0): CellConfig(type: CellType.ice, iceLayer: 1),
        },
      );
      final all = level.allSpecialCells();
      // (0,0) corridor'da stone ama level'da ice → ice kazanir
      expect(all[(0, 0)]!.type, CellType.ice);
    });
  });
}
