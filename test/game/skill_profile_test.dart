import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/game/systems/skill_profile.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

GameStats _makeStats({
  double gridFillRatio = 0.5,
  int synthesisCount = 0,
  int movesUsed = 10,
  int maxCombo = 0,
  int comboMoveCount = 0,
  int pressureScore = 0,
  int totalScore = 1000,
  DateTime? playedAt,
}) =>
    GameStats(
      gridFillRatio: gridFillRatio,
      synthesisCount: synthesisCount,
      movesUsed: movesUsed,
      maxCombo: maxCombo,
      comboMoveCount: comboMoveCount,
      pressureScore: pressureScore,
      totalScore: totalScore,
      playedAt: playedAt ?? DateTime(2026, 3, 25),
    );

/// Builds a [SkillProfile] with [count] identical default games.
SkillProfile _profileWith(int count, {GameStats Function(int i)? builder}) {
  var profile = SkillProfile.empty();
  for (var i = 0; i < count; i++) {
    profile = profile.addGame(builder != null ? builder(i) : _makeStats());
  }
  return profile;
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // ─── GameStats ────────────────────────────────────────────────────────────

  group('GameStats', () {
    test('serialization roundtrip preserves all fields', () {
      final original = _makeStats(
        gridFillRatio: 0.72,
        synthesisCount: 5,
        movesUsed: 42,
        maxCombo: 4,
        comboMoveCount: 8,
        pressureScore: 300,
        totalScore: 1500,
        playedAt: DateTime(2026, 3, 25, 14, 30),
      );

      final roundtripped = GameStats.fromMap(original.toMap());

      expect(roundtripped.gridFillRatio, original.gridFillRatio);
      expect(roundtripped.synthesisCount, original.synthesisCount);
      expect(roundtripped.movesUsed, original.movesUsed);
      expect(roundtripped.maxCombo, original.maxCombo);
      expect(roundtripped.comboMoveCount, original.comboMoveCount);
      expect(roundtripped.pressureScore, original.pressureScore);
      expect(roundtripped.totalScore, original.totalScore);
      expect(roundtripped.playedAt, original.playedAt);
    });
  });

  // ─── SkillProfile ─────────────────────────────────────────────────────────

  group('SkillProfile', () {
    test('empty profile has 0 games', () {
      final profile = SkillProfile.empty();
      expect(profile.recentGames, isEmpty);
    });

    test('addGame appends to recentGames', () {
      var profile = SkillProfile.empty();
      profile = profile.addGame(_makeStats());
      expect(profile.recentGames.length, 1);

      profile = profile.addGame(_makeStats());
      expect(profile.recentGames.length, 2);
    });

    test('addGame ring buffer caps at 10 (FIFO)', () {
      // Add 11 games; oldest (index 0) should be evicted.
      final first = _makeStats(totalScore: 111);
      var profile = SkillProfile.empty();
      profile = profile.addGame(first);
      for (var i = 0; i < 10; i++) {
        profile = profile.addGame(_makeStats(totalScore: 999));
      }

      expect(profile.recentGames.length, 10);
      // The very first game must have been dropped.
      expect(
        profile.recentGames.any((g) => g.totalScore == 111),
        isFalse,
      );
    });

    test('isCalibrating true when < 3 games', () {
      expect(SkillProfile.empty().isCalibrating, isTrue);
      expect(_profileWith(1).isCalibrating, isTrue);
      expect(_profileWith(2).isCalibrating, isTrue);
      expect(_profileWith(3).isCalibrating, isFalse);
    });

    test('isCalibrating returns 0.5 for all axes', () {
      final profile = _profileWith(2); // still calibrating
      expect(profile.gridEfficiency, 0.5);
      expect(profile.synthesisSkill, 0.5);
      expect(profile.comboSkill, 0.5);
      expect(profile.pressureResilience, 0.5);
    });

    test('gridEfficiency averages gridFillRatio', () {
      // 3 games with fill ratios 0.2, 0.4, 0.6 → average 0.4
      final profile = _profileWith(3,
          builder: (i) => _makeStats(gridFillRatio: [0.2, 0.4, 0.6][i]));

      expect(profile.gridEfficiency, closeTo(0.4, 1e-9));
    });

    test('synthesisSkill caps at 0.5 ratio → 1.0', () {
      // 5 syntheses in 10 moves = ratio 0.5 → skill 1.0
      final profile = _profileWith(3,
          builder: (_) => _makeStats(synthesisCount: 5, movesUsed: 10));

      expect(profile.synthesisSkill, closeTo(1.0, 1e-9));

      // 1 synthesis in 10 moves = ratio 0.1 → skill 0.2
      final profile2 = _profileWith(3,
          builder: (_) => _makeStats(synthesisCount: 1, movesUsed: 10));

      expect(profile2.synthesisSkill, closeTo(0.2, 1e-9));
    });

    test('comboSkill normalizes combo*frequency product', () {
      // maxCombo=2, comboMoveCount=5, movesUsed=10 → frequency=0.5,
      // product = 2 * 0.5 = 1.0 (capped at 1.0) → comboSkill = 1.0
      final profile = _profileWith(3,
          builder: (_) =>
              _makeStats(maxCombo: 2, comboMoveCount: 5, movesUsed: 10));

      expect(profile.comboSkill, closeTo(1.0, 1e-9));

      // maxCombo=1, comboMoveCount=2, movesUsed=10 → frequency=0.2,
      // product = 1 * 0.2 = 0.2 → comboSkill = 0.2
      final profile2 = _profileWith(3,
          builder: (_) =>
              _makeStats(maxCombo: 1, comboMoveCount: 2, movesUsed: 10));

      expect(profile2.comboSkill, closeTo(0.2, 1e-9));
    });

    test('pressureResilience averages pressure/total ratio', () {
      // pressureScore=400, totalScore=1000 → ratio 0.4
      final profile = _profileWith(3,
          builder: (_) =>
              _makeStats(pressureScore: 400, totalScore: 1000));

      expect(profile.pressureResilience, closeTo(0.4, 1e-9));
    });

    test('overallSkill is mean of 4 axes', () {
      // Use known values to verify: 3 games, all axes computable.
      // gridFillRatio=0.8 → gridEfficiency=0.8
      // synthesisCount=5, movesUsed=10 → synthesisSkill=1.0
      // maxCombo=2, comboMoveCount=5, movesUsed=10 → comboSkill=1.0
      // pressureScore=800, totalScore=1000 → pressureResilience=0.8
      // overallSkill = (0.8+1.0+1.0+0.8)/4 = 0.9
      final profile = _profileWith(
        3,
        builder: (_) => _makeStats(
          gridFillRatio: 0.8,
          synthesisCount: 5,
          movesUsed: 10,
          maxCombo: 2,
          comboMoveCount: 5,
          pressureScore: 800,
          totalScore: 1000,
        ),
      );

      expect(profile.overallSkill, closeTo(0.9, 1e-9));
    });

    test('applyCooldown moves axes 20% toward 0.5 when >7 days', () {
      // gridFillRatio=1.0 → gridEfficiency=1.0 without cooldown
      // after cooldown: 1.0 + (0.5 - 1.0) * 0.2 = 0.9
      final oldDate = DateTime.now().subtract(const Duration(days: 8));
      final profile = _profileWith(3,
          builder: (_) => _makeStats(
                gridFillRatio: 1.0,
                synthesisCount: 5, // → synthesisSkill=1.0
                movesUsed: 10,
                maxCombo: 2,
                comboMoveCount: 5,
                pressureScore: 1000,
                totalScore: 1000, // → pressureResilience=1.0
                playedAt: oldDate,
              ));

      final cooled = profile.applyCooldown();

      // Each axis was 1.0; cooled = 1.0 + (0.5-1.0)*0.2 = 0.9
      expect(cooled.gridEfficiency, closeTo(0.9, 1e-9));
      expect(cooled.synthesisSkill, closeTo(0.9, 1e-9));
      expect(cooled.comboSkill, closeTo(0.9, 1e-9));
      expect(cooled.pressureResilience, closeTo(0.9, 1e-9));
    });

    test('applyCooldown does NOT apply when last game <= 7 days ago', () {
      final recentDate = DateTime.now().subtract(const Duration(days: 3));
      final profile = _profileWith(3,
          builder: (_) =>
              _makeStats(gridFillRatio: 1.0, playedAt: recentDate));

      final result = profile.applyCooldown();
      // Should be the same object (no cooldown applied).
      expect(result.gridEfficiency, closeTo(1.0, 1e-9));
    });

    test('serialization roundtrip preserves profile', () {
      final original = _profileWith(5,
          builder: (i) => _makeStats(
                gridFillRatio: 0.1 * (i + 1),
                synthesisCount: i,
                movesUsed: 20 + i,
                maxCombo: i,
                comboMoveCount: i * 2,
                pressureScore: i * 100,
                totalScore: 500 + i * 100,
              ));

      final fromMap = SkillProfile.fromMap(original.toMap());
      expect(fromMap.recentGames.length, original.recentGames.length);
      for (var i = 0; i < original.recentGames.length; i++) {
        expect(fromMap.recentGames[i].totalScore,
            original.recentGames[i].totalScore);
        expect(fromMap.recentGames[i].synthesisCount,
            original.recentGames[i].synthesisCount);
      }

      // Also test JSON convenience methods.
      final fromJson = SkillProfile.fromJson(original.toJson());
      expect(fromJson.recentGames.length, original.recentGames.length);
      expect(fromJson.recentGames.first.gridFillRatio,
          closeTo(original.recentGames.first.gridFillRatio, 1e-9));
    });
  });
}
