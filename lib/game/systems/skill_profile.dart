import 'dart:convert';
import 'dart:math';

/// Immutable snapshot of statistics for a single completed game.
class GameStats {
  const GameStats({
    required this.gridFillRatio,
    required this.synthesisCount,
    required this.movesUsed,
    required this.maxCombo,
    required this.comboMoveCount,
    required this.pressureScore,
    required this.totalScore,
    required this.playedAt,
  });

  /// Grid fill ratio at game over (0.0–1.0).
  final double gridFillRatio;

  /// Total color syntheses made in the game.
  final int synthesisCount;

  /// Total moves made in the game.
  final int movesUsed;

  /// Longest combo chain achieved.
  final int maxCombo;

  /// Number of moves that triggered a combo.
  final int comboMoveCount;

  /// Score earned while grid was >60% full.
  final int pressureScore;

  /// Final score for the game.
  final int totalScore;

  /// When the game was played.
  final DateTime playedAt;

  Map<String, dynamic> toMap() => {
        'gridFillRatio': gridFillRatio,
        'synthesisCount': synthesisCount,
        'movesUsed': movesUsed,
        'maxCombo': maxCombo,
        'comboMoveCount': comboMoveCount,
        'pressureScore': pressureScore,
        'totalScore': totalScore,
        'playedAt': playedAt.toIso8601String(),
      };

  factory GameStats.fromMap(Map<String, dynamic> map) => GameStats(
        gridFillRatio: (map['gridFillRatio'] as num).toDouble(),
        synthesisCount: map['synthesisCount'] as int,
        movesUsed: map['movesUsed'] as int,
        maxCombo: map['maxCombo'] as int,
        comboMoveCount: map['comboMoveCount'] as int,
        pressureScore: map['pressureScore'] as int,
        totalScore: map['totalScore'] as int,
        playedAt: DateTime.parse(map['playedAt'] as String),
      );
}

/// Tracks a player's skill across 4 axes based on their last 10 games.
class SkillProfile {
  SkillProfile({required List<GameStats> recentGames})
      : recentGames = List.unmodifiable(recentGames);

  /// Named constructor — empty profile with no games recorded.
  SkillProfile.empty() : recentGames = const [];

  /// Up to 10 most recent games, oldest first (FIFO ring buffer).
  final List<GameStats> recentGames;

  /// True when fewer than 3 games have been recorded; axes return 0.5.
  bool get isCalibrating => recentGames.length < 3;

  // ─── Axis computations ──────────────────────────────────────────────────

  /// Average grid fill ratio across recent games (higher = better space use).
  double get gridEfficiency {
    if (isCalibrating) return 0.5;
    final avg =
        recentGames.map((g) => g.gridFillRatio).reduce((a, b) => a + b) /
            recentGames.length;
    return avg.clamp(0.0, 1.0);
  }

  /// Synthesis rate per move, normalised so >=0.5 synthesis/move → 1.0.
  double get synthesisSkill {
    if (isCalibrating) return 0.5;
    final avg = recentGames
            .map((g) => g.synthesisCount / max(g.movesUsed, 1))
            .reduce((a, b) => a + b) /
        recentGames.length;
    return (avg / 0.5).clamp(0.0, 1.0);
  }

  /// Combo depth × frequency, normalised to 0–1.
  double get comboSkill {
    if (isCalibrating) return 0.5;
    final avg = recentGames.map((g) {
          final frequency = g.comboMoveCount / max(g.movesUsed, 1);
          return (g.maxCombo * frequency).clamp(0.0, 1.0);
        }).reduce((a, b) => a + b) /
        recentGames.length;
    return avg.clamp(0.0, 1.0);
  }

  /// Fraction of total score earned under high-pressure grid conditions.
  double get pressureResilience {
    if (isCalibrating) return 0.5;
    final avg = recentGames
            .map((g) => g.pressureScore / max(g.totalScore, 1))
            .reduce((a, b) => a + b) /
        recentGames.length;
    return avg.clamp(0.0, 1.0);
  }

  /// Mean of all 4 skill axes.
  double get overallSkill =>
      (gridEfficiency + synthesisSkill + comboSkill + pressureResilience) / 4;

  // ─── Cooldown ───────────────────────────────────────────────────────────

  /// Returns a new profile with each axis moved 20% toward 0.5 when the
  /// most recent game was played more than 7 days ago.
  SkillProfile applyCooldown() {
    if (recentGames.isEmpty) return this;
    final daysSinceLast =
        DateTime.now().difference(recentGames.last.playedAt).inDays;
    if (daysSinceLast <= 7) return this;
    return _CooledSkillProfile(recentGames: List.of(recentGames));
  }

  // ─── Ring-buffer mutation ────────────────────────────────────────────────

  /// Returns a new [SkillProfile] with [game] appended.
  /// If there are already 10 games, the oldest is dropped (FIFO).
  SkillProfile addGame(GameStats game) {
    final updated = List<GameStats>.of(recentGames);
    if (updated.length >= 10) updated.removeAt(0);
    updated.add(game);
    return SkillProfile(recentGames: updated);
  }

  // ─── Serialization ──────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'recentGames': recentGames.map((g) => g.toMap()).toList(),
      };

  factory SkillProfile.fromMap(Map<String, dynamic> map) {
    final games = (map['recentGames'] as List<dynamic>)
        .map((e) => GameStats.fromMap(e as Map<String, dynamic>))
        .toList();
    return SkillProfile(recentGames: games);
  }

  String toJson() => jsonEncode(toMap());

  factory SkillProfile.fromJson(String source) =>
      SkillProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Internal subclass that applies the 20%-toward-0.5 cooldown to all axes.
class _CooledSkillProfile extends SkillProfile {
  _CooledSkillProfile({required super.recentGames});

  double _cool(double value) => value + (0.5 - value) * 0.2;

  @override
  double get gridEfficiency => _cool(super.gridEfficiency);

  @override
  double get synthesisSkill => _cool(super.synthesisSkill);

  @override
  double get comboSkill => _cool(super.comboSkill);

  @override
  double get pressureResilience => _cool(super.pressureResilience);
}
