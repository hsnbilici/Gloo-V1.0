import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/utils/color_mixer.dart';

void main() {
  // ─── mix ────────────────────────────────────────────────────────────────────

  group('ColorMixer.mix', () {
    test('red + yellow = orange', () {
      expect(ColorMixer.mix(GelColor.red, GelColor.yellow), GelColor.orange);
    });

    test('yellow + blue = green', () {
      expect(ColorMixer.mix(GelColor.yellow, GelColor.blue), GelColor.green);
    });

    test('red + blue = purple', () {
      expect(ColorMixer.mix(GelColor.red, GelColor.blue), GelColor.purple);
    });

    test('orange + blue = brown', () {
      expect(ColorMixer.mix(GelColor.orange, GelColor.blue), GelColor.brown);
    });

    test('red + white = pink', () {
      expect(ColorMixer.mix(GelColor.red, GelColor.white), GelColor.pink);
    });

    test('blue + white = lightBlue', () {
      expect(ColorMixer.mix(GelColor.blue, GelColor.white), GelColor.lightBlue);
    });

    test('green + yellow = lime', () {
      expect(ColorMixer.mix(GelColor.green, GelColor.yellow), GelColor.lime);
    });

    test('purple + orange = maroon', () {
      expect(ColorMixer.mix(GelColor.purple, GelColor.orange), GelColor.maroon);
    });

    test('order independence - all 8 pairs', () {
      final entries = kColorMixingTable.entries.toList();
      for (final entry in entries) {
        final (a, b) = entry.key;
        final expected = entry.value;
        // Forward order
        expect(ColorMixer.mix(a, b), expected, reason: '$a + $b = $expected');
        // Reverse order
        expect(ColorMixer.mix(b, a), expected, reason: '$b + $a = $expected');
      }
    });

    test('same color returns null', () {
      expect(ColorMixer.mix(GelColor.red, GelColor.red), isNull);
    });

    test('invalid combination returns null', () {
      expect(ColorMixer.mix(GelColor.orange, GelColor.green), isNull);
      expect(ColorMixer.mix(GelColor.white, GelColor.yellow), isNull);
    });
  });

  // ─── mixChain ──────────────────────────────────────────────────────────────

  group('ColorMixer.mixChain', () {
    test('empty list returns null', () {
      expect(ColorMixer.mixChain([]), isNull);
    });

    test('single color returns itself', () {
      expect(ColorMixer.mixChain([GelColor.red]), GelColor.red);
    });

    test('two colors mix normally', () {
      expect(
        ColorMixer.mixChain([GelColor.red, GelColor.yellow]),
        GelColor.orange,
      );
    });

    test('three-color chain: red + yellow = orange, orange + blue = brown', () {
      expect(
        ColorMixer.mixChain([GelColor.red, GelColor.yellow, GelColor.blue]),
        GelColor.brown,
      );
    });

    test('invalid chain returns null at break point', () {
      // red + red = null (ayni renk)
      expect(
        ColorMixer.mixChain([GelColor.red, GelColor.red]),
        isNull,
      );
    });

    test('chain breaks mid-way returns null', () {
      // red + yellow = orange, orange + orange = null
      expect(
        ColorMixer.mixChain([GelColor.red, GelColor.yellow, GelColor.orange]),
        isNull,
      );
    });
  });

  // ─── isSecondaryColor ──────────────────────────────────────────────────────

  group('ColorMixer.isSecondaryColor', () {
    test('primary colors are not secondary', () {
      // Birincil renkler tabloda deger olarak gecmiyor
      // (white icin dikkat: red+white=pink, blue+white=lightBlue — white deger degil)
      expect(ColorMixer.isSecondaryColor(GelColor.red), isFalse);
      expect(ColorMixer.isSecondaryColor(GelColor.yellow), isFalse);
      expect(ColorMixer.isSecondaryColor(GelColor.blue), isFalse);
      expect(ColorMixer.isSecondaryColor(GelColor.white), isFalse);
    });

    test('synthesized colors are secondary', () {
      expect(ColorMixer.isSecondaryColor(GelColor.orange), isTrue);
      expect(ColorMixer.isSecondaryColor(GelColor.green), isTrue);
      expect(ColorMixer.isSecondaryColor(GelColor.purple), isTrue);
      expect(ColorMixer.isSecondaryColor(GelColor.brown), isTrue);
      expect(ColorMixer.isSecondaryColor(GelColor.pink), isTrue);
      expect(ColorMixer.isSecondaryColor(GelColor.lightBlue), isTrue);
      expect(ColorMixer.isSecondaryColor(GelColor.lime), isTrue);
      expect(ColorMixer.isSecondaryColor(GelColor.maroon), isTrue);
    });
  });

  // ─── findRecipes ───────────────────────────────────────────────────────────

  group('ColorMixer.findRecipes', () {
    test('orange has one recipe (red + yellow)', () {
      final recipes = ColorMixer.findRecipes(GelColor.orange);
      expect(recipes.length, 1);
      expect(recipes[0], (GelColor.red, GelColor.yellow));
    });

    test('brown has one recipe (orange + blue)', () {
      final recipes = ColorMixer.findRecipes(GelColor.brown);
      expect(recipes.length, 1);
      expect(recipes[0], (GelColor.orange, GelColor.blue));
    });

    test('primary color has no recipe', () {
      final recipes = ColorMixer.findRecipes(GelColor.red);
      expect(recipes, isEmpty);
    });

    test('all secondary colors have at least one recipe', () {
      final secondaries = [
        GelColor.orange, GelColor.green, GelColor.purple, GelColor.brown,
        GelColor.pink, GelColor.lightBlue, GelColor.lime, GelColor.maroon,
      ];
      for (final color in secondaries) {
        final recipes = ColorMixer.findRecipes(color);
        expect(recipes, isNotEmpty, reason: '$color should have a recipe');
      }
    });
  });
}
