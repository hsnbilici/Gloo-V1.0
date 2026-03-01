import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/constants/game_constants.dart';
import 'package:gloo/core/utils/near_miss_detector.dart';

void main() {
  late NearMissDetector detector;

  setUp(() {
    detector = NearMissDetector();
  });

  // ─── evaluate ──────────────────────────────────────────────────────────────

  group('NearMissDetector.evaluate', () {
    test('returns null when score is below threshold', () {
      // Dusuk fill ratio, dusuk kombo, cok hamle, cok cesit renk
      final grid = List.generate(
        10,
        (_) => List<GelColor?>.filled(8, null),
      );
      final result = detector.evaluate(
        filledCells: 10,
        totalCells: 80,
        lastComboSize: 0,
        availableMoves: 10,
        grid: grid,
      );
      expect(result, isNull);
    });

    test('returns standard near-miss when above threshold', () {
      // Yuksek fill ratio (0.88), buyuk kombo, az hamle
      final grid = List.generate(10, (r) {
        return List.generate(8, (c) {
          if (r < 8 && c < 7) return GelColor.red;
          return null;
        });
      });

      final result = detector.evaluate(
        filledCells: 70,
        totalCells: 80,
        lastComboSize: 4,
        availableMoves: 1,
        grid: grid,
      );
      expect(result, isNotNull);
      expect(result!.score, greaterThan(GameConstants.nearMissThreshold));
    });

    test('returns critical near-miss when above critical threshold', () {
      // Cok yuksek fill ratio, epic kombo, sifir hamle, tek renk
      final grid = List.generate(10, (_) {
        return List<GelColor?>.filled(8, GelColor.red);
      });

      final result = detector.evaluate(
        filledCells: 78,
        totalCells: 80,
        lastComboSize: 5,
        availableMoves: 0,
        grid: grid,
      );
      expect(result, isNotNull);
      expect(result!.isCritical, isTrue);
      expect(result.type, NearMissType.critical);
      expect(
          result.score, greaterThan(GameConstants.criticalNearMissThreshold));
    });

    test('empty grid returns null (low fill ratio)', () {
      final grid = List.generate(
        10,
        (_) => List<GelColor?>.filled(8, null),
      );
      final result = detector.evaluate(
        filledCells: 0,
        totalCells: 80,
        lastComboSize: 0,
        availableMoves: 10,
        grid: grid,
      );
      expect(result, isNull);
    });

    test('fill ratio contributes 40% of score', () {
      // fillRatio = 1.0 → 0.4 puandan katki
      // Diger faktorler minimize edilmis
      final grid = List.generate(10, (_) {
        return List.generate(8, (c) {
          // Her sutuna farkli renk → yuksek entropy
          return GelColor.values[c % 4];
        });
      });

      final result = detector.evaluate(
        filledCells: 80,
        totalCells: 80,
        lastComboSize: 0,
        availableMoves: 10,
        grid: grid,
      );
      // fillRatio=1.0 → 0.4, combo=0→0, entropy yuksek→düsük katkı, moves=10→0
      // Score ~ 0.4 + 0 + low + 0 < 0.85
      expect(result, isNull);
    });

    test('combo size contributes 30% of score', () {
      // comboSize 5+ → normalize 1.0 → 0.3 katki
      // 5+ kombo max puan verir
      final grid = List.generate(
        3,
        (_) => List<GelColor?>.filled(3, null),
      );
      final result = detector.evaluate(
        filledCells: 0,
        totalCells: 9,
        lastComboSize: 10,
        availableMoves: 10,
        grid: grid,
      );
      // fillRatio=0 → 0, combo=1.0→0.3, entropy=empty→(1-1.0)*0.2=0, moves=10→0
      // Score = 0.3 < 0.85
      expect(result, isNull);
    });

    test('zero available moves contribute 10% of score', () {
      // availableMoves = 0 → normalize 1.0 → 0.1 katki
      final grid = List.generate(
        3,
        (_) => List<GelColor?>.filled(3, null),
      );
      final result = detector.evaluate(
        filledCells: 0,
        totalCells: 9,
        lastComboSize: 0,
        availableMoves: 0,
        grid: grid,
      );
      // fillRatio=0 → 0, combo=0→0, entropy=empty→0, moves=0→0.1
      // Score = 0.1 < 0.85
      expect(result, isNull);
    });

    test('combined high factors trigger near-miss', () {
      // Tum faktorler yuksek → esik gecilmeli
      // Tek renk = dusuk entropy → (1-low)*0.2 yuksek
      final grid = List.generate(10, (_) {
        return List<GelColor?>.filled(8, GelColor.red);
      });

      final result = detector.evaluate(
        filledCells: 76,
        totalCells: 80,
        lastComboSize: 5,
        availableMoves: 0,
        grid: grid,
      );
      expect(result, isNotNull);
    });
  });

  // ─── NearMissEvent ─────────────────────────────────────────────────────────

  group('NearMissEvent', () {
    test('isCritical returns true for critical type', () {
      const event = NearMissEvent(score: 0.96, type: NearMissType.critical);
      expect(event.isCritical, isTrue);
    });

    test('isCritical returns false for standard type', () {
      const event = NearMissEvent(score: 0.90, type: NearMissType.standard);
      expect(event.isCritical, isFalse);
    });
  });
}
