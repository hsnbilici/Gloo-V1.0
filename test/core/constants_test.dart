import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/audio_constants.dart';
import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/l10n/strings_en.dart';
import 'package:gloo/core/constants/game_constants.dart';
import 'package:gloo/core/constants/ui_constants.dart';
import 'package:gloo/game/economy/currency_manager.dart';

void main() {
  // ─── GameConstants ──────────────────────────────────────────────────────

  group('GameConstants', () {
    test('grid dimensions', () {
      expect(GameConstants.gridCols, 8);
      expect(GameConstants.gridRows, 10);
      expect(GameConstants.shapesInHand, 3);
    });

    test('scoring constants', () {
      expect(GameConstants.singleLineClear, 150);
      expect(GameConstants.multiLineClear, 300);
      expect(GameConstants.colorSynthesisBonus, 150);
    });

    test('time trial constants', () {
      expect(GameConstants.timeTrialDuration, 90);
      expect(GameConstants.timeTrialLineClearBonus, 2);
    });

    test('near-miss thresholds are ordered', () {
      expect(GameConstants.nearMissThreshold,
          lessThan(GameConstants.criticalNearMissThreshold));
    });

    test('duel duration is 120', () {
      expect(GameConstants.duelDuration, 120);
    });

    test('freeze duration is 10', () {
      expect(GameConstants.freezeDuration, 10);
    });

    test('mercy constants', () {
      expect(GameConstants.mercyLossThreshold, 2);
      expect(GameConstants.mercyNoClearThreshold, 5);
      expect(GameConstants.mercyDifficultyMultiplier, 0.7);
    });

    test('season pass constants', () {
      expect(GameConstants.seasonDurationWeeks, 8);
      expect(GameConstants.seasonTotalTiers, 50);
    });
  });

  // ─── GelColor ───────────────────────────────────────────────────────────

  group('GelColor', () {
    test('has 12 values', () {
      expect(GelColor.values.length, 12);
    });

    test('shortLabel is non-empty for all colors', () {
      for (final color in GelColor.values) {
        expect(color.shortLabel.isNotEmpty, isTrue);
      }
    });

    test('shortLabel returns correct values', () {
      expect(GelColor.red.shortLabel, 'R');
      expect(GelColor.yellow.shortLabel, 'Y');
      expect(GelColor.blue.shortLabel, 'B');
      expect(GelColor.white.shortLabel, 'W');
      expect(GelColor.pink.shortLabel, 'Pk');
      expect(GelColor.lightBlue.shortLabel, 'Lb');
    });

    test('displayColor returns non-zero color value', () {
      for (final color in GelColor.values) {
        expect(color.displayColor.toARGB32(), isNonZero);
      }
    });

    test('colorName returns non-empty for all colors via l10n', () {
      final l = StringsEn();
      for (final color in GelColor.values) {
        expect(l.colorName(color).isNotEmpty, isTrue);
      }
    });
  });

  // ─── kColorMixingTable ──────────────────────────────────────────────────

  group('kColorMixingTable', () {
    test('has 8 entries', () {
      expect(kColorMixingTable.length, 8);
    });

    test('red + yellow = orange', () {
      expect(
          kColorMixingTable[(GelColor.red, GelColor.yellow)], GelColor.orange);
    });

    test('yellow + blue = green', () {
      expect(
          kColorMixingTable[(GelColor.yellow, GelColor.blue)], GelColor.green);
    });

    test('red + blue = purple', () {
      expect(kColorMixingTable[(GelColor.red, GelColor.blue)], GelColor.purple);
    });

    test('orange + blue = brown', () {
      expect(
          kColorMixingTable[(GelColor.orange, GelColor.blue)], GelColor.brown);
    });

    test('red + white = pink', () {
      expect(kColorMixingTable[(GelColor.red, GelColor.white)], GelColor.pink);
    });

    test('blue + white = lightBlue', () {
      expect(kColorMixingTable[(GelColor.blue, GelColor.white)],
          GelColor.lightBlue);
    });

    test('green + yellow = lime', () {
      expect(
          kColorMixingTable[(GelColor.green, GelColor.yellow)], GelColor.lime);
    });

    test('purple + orange = maroon', () {
      expect(kColorMixingTable[(GelColor.purple, GelColor.orange)],
          GelColor.maroon);
    });

    test('all results are non-primary synthesized colors', () {
      for (final result in kColorMixingTable.values) {
        expect(kPrimaryColors.contains(result), isFalse);
      }
    });
  });

  // ─── kPrimaryColors ─────────────────────────────────────────────────────

  group('kPrimaryColors', () {
    test('has 4 colors', () {
      expect(kPrimaryColors.length, 4);
    });

    test('contains red, yellow, blue, white', () {
      expect(kPrimaryColors, contains(GelColor.red));
      expect(kPrimaryColors, contains(GelColor.yellow));
      expect(kPrimaryColors, contains(GelColor.blue));
      expect(kPrimaryColors, contains(GelColor.white));
    });

    test('does not contain synthesized colors', () {
      expect(kPrimaryColors, isNot(contains(GelColor.orange)));
      expect(kPrimaryColors, isNot(contains(GelColor.green)));
      expect(kPrimaryColors, isNot(contains(GelColor.purple)));
    });
  });

  // ─── UI Palette constants ───────────────────────────────────────────────

  group('UI palette constants', () {
    test('kBgDark is dark color', () {
      expect((kBgDark.r * 255.0).round(), lessThan(10));
      expect((kBgDark.g * 255.0).round(), lessThan(30));
    });

    test('mode accent colors are distinct', () {
      final colors = {kColorClassic, kColorChef, kColorTimeTrial, kColorZen};
      expect(colors.length, 4);
    });
  });

  // ─── CurrencyCosts ─────────────────────────────────────────────────────

  group('CurrencyCosts', () {
    test('all costs are positive', () {
      expect(CurrencyCosts.rotate, greaterThan(0));
      expect(CurrencyCosts.bomb, greaterThan(0));
      expect(CurrencyCosts.peek, greaterThan(0));
      expect(CurrencyCosts.undo, greaterThan(0));
      expect(CurrencyCosts.rainbow, greaterThan(0));
      expect(CurrencyCosts.freeze, greaterThan(0));
      expect(CurrencyCosts.shield, greaterThan(0));
      expect(CurrencyCosts.reflect, greaterThan(0));
    });

    test('specific cost values', () {
      expect(CurrencyCosts.rotate, 3);
      expect(CurrencyCosts.bomb, 8);
      expect(CurrencyCosts.peek, 2);
      expect(CurrencyCosts.undo, 5);
      expect(CurrencyCosts.rainbow, 10);
      expect(CurrencyCosts.freeze, 6);
    });
  });

  // ─── AudioPaths ─────────────────────────────────────────────────────────

  group('AudioPaths', () {
    test('SFX paths start with assets/audio/sfx/', () {
      final sfxPaths = [
        AudioPaths.gelPlace,
        AudioPaths.gelPlaceSoft,
        AudioPaths.gelMergeSmall,
        AudioPaths.gelMergeMedium,
        AudioPaths.gelMergeLarge,
        AudioPaths.lineClear,
        AudioPaths.lineClearCrystal,
        AudioPaths.comboSmall,
        AudioPaths.comboMedium,
        AudioPaths.comboLarge,
        AudioPaths.comboEpic,
        AudioPaths.buttonTap,
        AudioPaths.levelComplete,
        AudioPaths.gameOver,
        AudioPaths.nearMissTension,
        AudioPaths.nearMissRelief,
        AudioPaths.iceBreak,
        AudioPaths.iceCrack,
        AudioPaths.powerupActivate,
        AudioPaths.bombExplosion,
        AudioPaths.rotateClick,
        AudioPaths.undoWhoosh,
        AudioPaths.freezeChime,
        AudioPaths.gravityDrop,
        AudioPaths.colorSynth,
        AudioPaths.colorSynthesis,
        AudioPaths.pvpObstacleSent,
        AudioPaths.pvpObstacleReceived,
        AudioPaths.pvpVictory,
        AudioPaths.pvpDefeat,
        AudioPaths.levelCompleteNew,
        AudioPaths.gelOzuEarn,
      ];
      for (final path in sfxPaths) {
        expect(path.startsWith('assets/audio/sfx/'), isTrue,
            reason: 'SFX path should start with assets/audio/sfx/: $path');
        expect(path.isNotEmpty, isTrue);
      }
    });

    test('Music paths start with assets/audio/music/', () {
      final musicPaths = [
        AudioPaths.bgMenuLofi,
        AudioPaths.bgGameRelax,
        AudioPaths.bgGameTension,
        AudioPaths.bgZenMode,
      ];
      for (final path in musicPaths) {
        expect(path.startsWith('assets/audio/music/'), isTrue,
            reason: 'Music path should start with assets/audio/music/: $path');
        expect(path.isNotEmpty, isTrue);
      }
    });

    test('all paths have file extensions', () {
      final allPaths = [
        AudioPaths.gelPlace,
        AudioPaths.lineClear,
        AudioPaths.comboSmall,
        AudioPaths.bgMenuLofi,
      ];
      for (final path in allPaths) {
        expect(path.contains('.'), isTrue,
            reason: 'Path should have extension: $path');
      }
    });
  });

  // ─── AudioConfig ────────────────────────────────────────────────────────

  group('AudioConfig', () {
    test('volume values are in valid range', () {
      expect(AudioConfig.masterVolume, greaterThan(0));
      expect(AudioConfig.masterVolume, lessThanOrEqualTo(1.0));
      expect(AudioConfig.sfxVolume, greaterThan(0));
      expect(AudioConfig.sfxVolume, lessThanOrEqualTo(1.0));
      expect(AudioConfig.musicVolume, greaterThan(0));
      expect(AudioConfig.musicVolume, lessThanOrEqualTo(1.0));
    });

    test('maxConcurrentSfxChannels is positive', () {
      expect(AudioConfig.maxConcurrentSfxChannels, greaterThan(0));
    });

    test('pitch variance range is valid', () {
      expect(AudioConfig.pitchVarianceMin, lessThan(1.0));
      expect(AudioConfig.pitchVarianceMax, greaterThan(1.0));
      expect(AudioConfig.pitchVarianceMin, greaterThan(0));
    });
  });

  // ─── UIConstants ────────────────────────────────────────────────────────

  group('UIConstants', () {
    test('radius scale is ascending', () {
      expect(UIConstants.radiusXxs, lessThan(UIConstants.radiusXs));
      expect(UIConstants.radiusXs, lessThan(UIConstants.radiusSm));
      expect(UIConstants.radiusSm, lessThan(UIConstants.radiusMd));
      expect(UIConstants.radiusMd, lessThan(UIConstants.radiusTile));
      expect(UIConstants.radiusTile, lessThan(UIConstants.radiusLg));
      expect(UIConstants.radiusLg, lessThan(UIConstants.radiusXl));
      expect(UIConstants.radiusXl, lessThan(UIConstants.radiusXxl));
    });

    test('all radius values are non-negative', () {
      expect(UIConstants.radiusXxs, greaterThanOrEqualTo(0));
      expect(UIConstants.radiusXs, greaterThanOrEqualTo(0));
      expect(UIConstants.radiusSm, greaterThanOrEqualTo(0));
      expect(UIConstants.radiusMd, greaterThanOrEqualTo(0));
      expect(UIConstants.radiusTile, greaterThanOrEqualTo(0));
      expect(UIConstants.radiusLg, greaterThanOrEqualTo(0));
      expect(UIConstants.radiusXl, greaterThanOrEqualTo(0));
      expect(UIConstants.radiusXxl, greaterThanOrEqualTo(0));
    });

    test('padding values are positive', () {
      expect(UIConstants.hPaddingScreen, greaterThan(0));
      expect(UIConstants.hPaddingCard, greaterThan(0));
      expect(UIConstants.hPaddingGrid, greaterThan(0));
    });

    test('padding scale: grid < card < screen', () {
      expect(UIConstants.hPaddingGrid, lessThan(UIConstants.hPaddingCard));
      expect(UIConstants.hPaddingCard, lessThan(UIConstants.hPaddingScreen));
    });
  });
}
