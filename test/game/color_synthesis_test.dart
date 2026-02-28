import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/game/systems/color_synthesis.dart';

void main() {
  late ColorSynthesisSystem system;

  setUp(() {
    system = ColorSynthesisSystem();
  });

  // ─── findSyntheses ─────────────────────────────────────────────────────────

  group('ColorSynthesisSystem.findSyntheses', () {
    test('detects horizontal synthesis (red + yellow = orange)', () {
      final grid = [
        [GelColor.red, GelColor.yellow, null],
        [null, null, null],
      ];
      final results = system.findSyntheses(grid);
      expect(results.length, 1);
      expect(results[0].resultColor, GelColor.orange);
      expect(results[0].positions, [(0, 0), (0, 1)]);
    });

    test('detects vertical synthesis (blue + yellow = green)', () {
      final grid = [
        [GelColor.yellow, null],
        [GelColor.blue, null],
      ];
      final results = system.findSyntheses(grid);
      expect(results.length, 1);
      expect(results[0].resultColor, GelColor.green);
      expect(results[0].positions, [(0, 0), (1, 0)]);
    });

    test('returns empty when no synthesis possible', () {
      // Ayni renk yan yana → sentez yok (red+red tabloda yok)
      // Ama red+blue=purple! Dikey olarak bulunur.
      // Gercekten sentez olmayan kombinasyon: orange+orange
      final grid = [
        [GelColor.orange, GelColor.orange],
        [GelColor.orange, null],
      ];
      final results = system.findSyntheses(grid);
      expect(results, isEmpty);
    });

    test('skips null cells', () {
      final grid = [
        [GelColor.red, null, GelColor.yellow],
      ];
      final results = system.findSyntheses(grid);
      expect(results, isEmpty);
    });

    test('detects multiple syntheses', () {
      final grid = [
        [GelColor.red, GelColor.yellow, GelColor.blue],
      ];
      final results = system.findSyntheses(grid);
      // red+yellow=orange, yellow+blue=green
      expect(results.length, 2);
      final colors = results.map((r) => r.resultColor).toSet();
      expect(colors, containsAll([GelColor.orange, GelColor.green]));
    });

    test('detects both horizontal and vertical', () {
      final grid = [
        [GelColor.red, GelColor.blue],
        [GelColor.yellow, null],
      ];
      final results = system.findSyntheses(grid);
      // H: red+blue=purple, V: red+yellow=orange
      expect(results.length, 2);
    });

    test('order independence (table lookup works both ways)', () {
      final grid1 = [
        [GelColor.red, GelColor.yellow],
      ];
      final grid2 = [
        [GelColor.yellow, GelColor.red],
      ];
      final r1 = system.findSyntheses(grid1);
      final r2 = system.findSyntheses(grid2);
      expect(r1[0].resultColor, GelColor.orange);
      expect(r2[0].resultColor, GelColor.orange);
    });

    test('all 8 mixing table entries detected', () {
      // Her bir sentez ciftini yatay olarak test et
      final pairs = [
        (GelColor.red, GelColor.yellow, GelColor.orange),
        (GelColor.yellow, GelColor.blue, GelColor.green),
        (GelColor.red, GelColor.blue, GelColor.purple),
        (GelColor.orange, GelColor.blue, GelColor.brown),
        (GelColor.red, GelColor.white, GelColor.pink),
        (GelColor.blue, GelColor.white, GelColor.lightBlue),
        (GelColor.green, GelColor.yellow, GelColor.lime),
        (GelColor.purple, GelColor.orange, GelColor.maroon),
      ];

      for (final (a, b, expected) in pairs) {
        final grid = [
          [a, b],
        ];
        final results = system.findSyntheses(grid);
        expect(results.length, 1, reason: '$a + $b should produce $expected');
        expect(results[0].resultColor, expected);
      }
    });

    test('non-mixing pair produces no result', () {
      final grid = [
        [GelColor.red, GelColor.red],
      ];
      final results = system.findSyntheses(grid);
      expect(results, isEmpty);
    });
  });

  // ─── applySynthesis ────────────────────────────────────────────────────────

  group('ColorSynthesisSystem.applySynthesis', () {
    test('places result color at first position, clears others', () {
      final grid = [
        [GelColor.red, GelColor.yellow, null],
      ];
      const synthesis = SynthesisResult(
        resultColor: GelColor.orange,
        positions: [(0, 0), (0, 1)],
        isChain: false,
      );
      final newGrid = system.applySynthesis(grid, synthesis);

      expect(newGrid[0][0], GelColor.orange);
      expect(newGrid[0][1], isNull);
    });

    test('does not modify original grid', () {
      final grid = [
        [GelColor.red, GelColor.blue],
      ];
      const synthesis = SynthesisResult(
        resultColor: GelColor.purple,
        positions: [(0, 0), (0, 1)],
        isChain: false,
      );
      system.applySynthesis(grid, synthesis);

      expect(grid[0][0], GelColor.red);
      expect(grid[0][1], GelColor.blue);
    });

    test('vertical synthesis application', () {
      final grid = [
        [GelColor.yellow],
        [GelColor.blue],
      ];
      const synthesis = SynthesisResult(
        resultColor: GelColor.green,
        positions: [(0, 0), (1, 0)],
        isChain: false,
      );
      final newGrid = system.applySynthesis(grid, synthesis);
      expect(newGrid[0][0], GelColor.green);
      expect(newGrid[1][0], isNull);
    });
  });
}
