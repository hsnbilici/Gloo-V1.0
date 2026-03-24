import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/systems/adaptive_difficulty.dart';
import 'package:gloo/game/systems/skill_profile.dart';

final _playedAt = DateTime(2024);

/// Builds a [SkillProfile] from [count] identical [GameStats] entries.
SkillProfile _profileFrom(GameStats stats, {required int count}) {
  var profile = SkillProfile.empty();
  for (var i = 0; i < count; i++) {
    profile = profile.addGame(stats);
  }
  return profile;
}

/// Returns a [GameStats] with the specified fields; remaining axes stay neutral.
///
/// Neutral defaults:
/// - gridFillRatio 0.5 → gridEfficiency 0.5
/// - synthesisCount 5 / movesUsed 20 → synthesisSkill 0.5
/// - maxCombo 0, comboMoveCount 0 → comboSkill 0.0 (low — override if needed)
/// - pressureFraction 0.5 → pressureResilience 0.5
GameStats _stats({
  double gridFillRatio = 0.5,
  int synthesisCount = 5,
  int movesUsed = 20,
  int maxCombo = 0,
  int comboMoveCount = 0,
  double pressureFraction = 0.5,
  int totalScore = 1000,
}) {
  return GameStats(
    gridFillRatio: gridFillRatio,
    synthesisCount: synthesisCount,
    movesUsed: movesUsed,
    maxCombo: maxCombo,
    comboMoveCount: comboMoveCount,
    pressureScore: (pressureFraction * totalScore).round(),
    totalScore: totalScore,
    playedAt: _playedAt,
  );
}

void main() {
  group('AdaptiveDifficulty', () {
    test('low gridEfficiency (0.2) → smallShapeBonus > 0', () {
      // gridFillRatio 0.2 → gridEfficiency 0.2 (low band, < 0.3)
      final profile = _profileFrom(_stats(gridFillRatio: 0.2), count: 5);
      final mods = AdaptiveDifficulty.calculate(profile);

      expect(mods.smallShapeBonus, greaterThan(0.0));
      expect(mods.largeShapeBonus, equals(0.0));
    });

    test('high gridEfficiency (0.8) → largeShapeBonus > 0', () {
      // gridFillRatio 0.8 → gridEfficiency 0.8 (high band, > 0.7)
      final profile = _profileFrom(_stats(gridFillRatio: 0.8), count: 5);
      final mods = AdaptiveDifficulty.calculate(profile);

      expect(mods.largeShapeBonus, greaterThan(0.0));
      expect(mods.smallShapeBonus, equals(0.0));
    });

    test('neutral gridEfficiency (0.5) → both bonuses 0', () {
      final profile = _profileFrom(_stats(gridFillRatio: 0.5), count: 5);
      final mods = AdaptiveDifficulty.calculate(profile);

      expect(mods.smallShapeBonus, equals(0.0));
      expect(mods.largeShapeBonus, equals(0.0));
    });

    test('low synthesisSkill (0.1) → synthesisFriendly true', () {
      // 0 syntheses per move → synthesisSkill = 0.0 (low band)
      final profile = _profileFrom(
        _stats(synthesisCount: 0, movesUsed: 20),
        count: 5,
      );
      final mods = AdaptiveDifficulty.calculate(profile);

      expect(mods.synthesisFriendly, isTrue);
    });

    test('high synthesisSkill (0.9) → synthesisFriendly false', () {
      // 9 syntheses / 20 moves = 0.45/move → 0.45/0.5 = 0.9 synthesisSkill (high band)
      final profile = _profileFrom(
        _stats(synthesisCount: 9, movesUsed: 20),
        count: 5,
      );
      final mods = AdaptiveDifficulty.calculate(profile);

      expect(mods.synthesisFriendly, isFalse);
    });

    test('low comboSkill → comboSetup true', () {
      // maxCombo=0, comboMoveCount=0 → comboSkill = 0.0 (low band)
      final profile = _profileFrom(
        _stats(maxCombo: 0, comboMoveCount: 0),
        count: 5,
      );
      final mods = AdaptiveDifficulty.calculate(profile);

      expect(mods.comboSetup, isTrue);
    });

    test('low pressureResilience → pressureMercy true', () {
      // pressureScore = 0 → pressureResilience = 0.0 (low band)
      final profile = _profileFrom(
        _stats(pressureFraction: 0.0),
        count: 5,
      );
      final mods = AdaptiveDifficulty.calculate(profile);

      expect(mods.pressureMercy, isTrue);
    });

    test('calibrating profile (< 3 games) → neutral modifiers', () {
      // Only 2 games → isCalibrating is true
      final profile = _profileFrom(_stats(gridFillRatio: 0.1), count: 2);
      final mods = AdaptiveDifficulty.calculate(profile);

      expect(mods.smallShapeBonus, equals(0.0));
      expect(mods.largeShapeBonus, equals(0.0));
      expect(mods.synthesisFriendly, isFalse);
      expect(mods.comboSetup, isFalse);
      expect(mods.pressureMercy, isFalse);
    });

    test('boundary interpolation: gridEfficiency 0.3 → intensity 0.0 (no modifier)', () {
      // At exactly the low threshold: intensity = (0.3 - 0.3) / 0.3 = 0.0
      // → smallShapeBonus = 0.15 * 0.0 = 0.0
      final profile = _profileFrom(_stats(gridFillRatio: 0.3), count: 5);
      final mods = AdaptiveDifficulty.calculate(profile);

      expect(mods.smallShapeBonus, equals(0.0));
      expect(mods.largeShapeBonus, equals(0.0));
    });
  });
}
