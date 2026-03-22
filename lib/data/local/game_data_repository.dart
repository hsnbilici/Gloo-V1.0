import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Yüksek skorlar, istatistikler, tutorial, günlük bulmaca, seviye ilerlemesi,
/// koleksiyon, ada/karakter/sezon durumu ve günlük görev verilerini yönetir.
class GameDataRepository {
  GameDataRepository(this._prefs);

  final SharedPreferences _prefs;

  // ─── High Score ──────────────────────────────────────────────────────────

  Future<void> saveScore({required String mode, required int value}) async {
    final key = 'highscore_$mode';
    final current = _prefs.getInt(key) ?? 0;
    if (value > current) {
      await _prefs.setInt(key, value);
    }
  }

  Future<int> getHighScore(String mode) async {
    return _prefs.getInt('highscore_$mode') ?? 0;
  }

  int getLastScore(String mode) {
    return _prefs.getInt('lastscore_$mode') ?? 0;
  }

  Future<void> saveLastScore({required String mode, required int value}) async {
    await _prefs.setInt('lastscore_$mode', value);
  }

  // ─── Tutorial ────────────────────────────────────────────────────────────

  bool getTutorialDone() => _prefs.getBool('tutorial_done') ?? false;

  Future<void> setTutorialDone() async {
    await _prefs.setBool('tutorial_done', true);
  }

  // ─── Streak ──────────────────────────────────────────────────────────────

  int getStreak() => _prefs.getInt('streak_count') ?? 0;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<int> checkAndUpdateStreak() async {
    final today = _todayKey();
    final lastDate = _prefs.getString('streak_last_date');

    if (lastDate == today) return getStreak();

    final yesterday = () {
      final dt = DateTime.now().subtract(const Duration(days: 1));
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }();

    final streak = (lastDate == yesterday) ? getStreak() + 1 : 1;
    await _prefs.setInt('streak_count', streak);
    await _prefs.setString('streak_last_date', today);
    return streak;
  }

  int getLastStreakRewardDay() => _prefs.getInt('streak_last_reward_day') ?? 0;

  Future<void> setLastStreakRewardDay(int day) async {
    await _prefs.setInt('streak_last_reward_day', day);
  }

  // ─── Koleksiyon (keşfedilen renkler) ────────────────────────────────────

  Set<String> getDiscoveredColors() {
    final raw = _prefs.getStringList('discovered_colors');
    return raw?.toSet() ?? {};
  }

  Future<void> addDiscoveredColor(String colorName) async {
    final current = getDiscoveredColors();
    if (current.contains(colorName)) return;
    current.add(colorName);
    await _prefs.setStringList('discovered_colors', current.toList());
  }

  // ─── Günlük Bulmaca ──────────────────────────────────────────────────────

  bool isDailyCompleted() {
    return _prefs.getString('daily_date') == _todayKey();
  }

  int getDailyScore() => _prefs.getInt('daily_score') ?? 0;

  Future<void> saveDailyResult(int score) async {
    final today = _todayKey();
    if (_prefs.getString('daily_date') == today) {
      if (score > getDailyScore()) {
        await _prefs.setInt('daily_score', score);
      }
    } else {
      await _prefs.setString('daily_date', today);
      await _prefs.setInt('daily_score', score);
    }
  }

  // ─── Seviye İlerleme ─────────────────────────────────────────────────────

  int getCurrentLevel() => _prefs.getInt('current_level') ?? 1;

  Future<void> saveCurrentLevel(int level) async {
    await _prefs.setInt('current_level', level);
  }

  int getMaxCompletedLevel() => _prefs.getInt('max_completed_level') ?? 0;

  Future<void> saveMaxCompletedLevel(int level) async {
    final current = _prefs.getInt('max_completed_level') ?? 0;
    if (level > current) {
      await _prefs.setInt('max_completed_level', level);
    }
  }

  int getLevelHighScore(int levelId) =>
      _prefs.getInt('level_highscore_$levelId') ?? 0;

  Future<void> saveLevelHighScore(int levelId, int score) async {
    final key = 'level_highscore_$levelId';
    final current = _prefs.getInt(key) ?? 0;
    if (score > current) {
      await _prefs.setInt(key, score);
    }
  }

  Set<int> getCompletedLevels() {
    final raw = _prefs.getStringList('completed_levels');
    if (raw == null) return {};
    return raw.map((s) => int.tryParse(s)).whereType<int>().toSet();
  }

  Future<void> setLevelCompleted(int levelId, int score) async {
    final current = getCompletedLevels();
    current.add(levelId);
    await _prefs.setStringList(
        'completed_levels', current.map((e) => e.toString()).toList());
    await saveMaxCompletedLevel(levelId);
    await saveLevelHighScore(levelId, score);
  }

  int? getLevelScore(int levelId) {
    final score = getLevelHighScore(levelId);
    return score > 0 ? score : null;
  }

  // ─── Oyun İstatistikleri ─────────────────────────────────────────────────

  int getTotalGamesPlayed() => _prefs.getInt('total_games_played') ?? 0;

  Future<void> incrementGamesPlayed() async {
    final current = getTotalGamesPlayed();
    await _prefs.setInt('total_games_played', current + 1);
  }

  int getAverageScore() => _prefs.getInt('average_score') ?? 0;

  Future<void> updateAverageScore(int newScore) async {
    final games = getTotalGamesPlayed();
    if (games == 0) {
      await _prefs.setInt('average_score', newScore);
      return;
    }
    final current = getAverageScore();
    final updated = ((current * (games - 1)) + newScore) ~/ games;
    await _prefs.setInt('average_score', updated);
  }

  int getConsecutiveLosses() => _prefs.getInt('consecutive_losses') ?? 0;

  Future<void> setConsecutiveLosses(int count) async {
    await _prefs.setInt('consecutive_losses', count);
  }

  // ─── Ada Durumu ──────────────────────────────────────────────────────────

  Map<String, int> getIslandState() {
    final raw = _prefs.getString('island_state');
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveIslandState(Map<String, int> state) async {
    await _prefs.setString('island_state', jsonEncode(state));
  }

  // ─── Karakter Durumu ─────────────────────────────────────────────────────

  Map<String, dynamic> getCharacterState() {
    final raw = _prefs.getString('character_state');
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCharacterState(Map<String, dynamic> state) async {
    await _prefs.setString('character_state', jsonEncode(state));
  }

  // ─── Sezon Pası Durumu ───────────────────────────────────────────────────

  Map<String, int> getSeasonPassState() {
    final raw = _prefs.getString('season_pass_state');
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveSeasonPassState(Map<String, int> state) async {
    await _prefs.setString('season_pass_state', jsonEncode(state));
  }

  // ─── Günlük Görev İlerleme ───────────────────────────────────────────────

  Map<String, int> getDailyQuestProgress() {
    final raw = _prefs.getString('daily_quest_progress');
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveDailyQuestProgress(Map<String, int> progress) async {
    await _prefs.setString('daily_quest_progress', jsonEncode(progress));
  }

  String? getDailyQuestDate() => _prefs.getString('daily_quest_date');

  Future<void> saveDailyQuestDate(String date) async {
    await _prefs.setString('daily_quest_date', date);
  }
}
