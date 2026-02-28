import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/game/systems/color_chef_levels.dart';

void main() {
  group('kColorChefLevels', () {
    test('has exactly 20 levels', () {
      expect(kColorChefLevels.length, 20);
    });

    test('all levels have positive requiredCount', () {
      for (final level in kColorChefLevels) {
        expect(level.requiredCount, greaterThan(0),
            reason: 'Level ${kColorChefLevels.indexOf(level) + 1} should have positive count');
      }
    });

    test('no level uses primary colors as target', () {
      const primaryColors = {
        GelColor.red,
        GelColor.yellow,
        GelColor.blue,
        GelColor.white,
      };
      for (final level in kColorChefLevels) {
        expect(primaryColors.contains(level.targetColor), isFalse,
            reason: '${level.targetColor} is a primary color and should not be a target');
      }
    });

    test('difficulty increases — later levels have higher requiredCount average', () {
      // Average of first 5 vs last 5
      final first5 = kColorChefLevels.take(5).map((l) => l.requiredCount);
      final last5 = kColorChefLevels.skip(15).map((l) => l.requiredCount);
      final avgFirst = first5.reduce((a, b) => a + b) / 5;
      final avgLast = last5.reduce((a, b) => a + b) / 5;
      expect(avgLast, greaterThan(avgFirst));
    });

    test('first 5 levels are easy (requiredCount == 3)', () {
      for (int i = 0; i < 5; i++) {
        expect(kColorChefLevels[i].requiredCount, 3,
            reason: 'Level ${i + 1} should have requiredCount 3');
      }
    });
  });

  group('ColorChefLevel', () {
    test('constructor stores targetColor and requiredCount', () {
      const level = ColorChefLevel(
        targetColor: GelColor.orange,
        requiredCount: 5,
      );
      expect(level.targetColor, GelColor.orange);
      expect(level.requiredCount, 5);
    });
  });
}
