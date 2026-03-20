import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_models.dart';
import 'secure_storage_interface.dart';

class LocalRepository {
  LocalRepository(this._prefs, {SecureStorageInterface? secureStorage})
      : _secure = secureStorage ?? const SecureStorageImpl();

  final SharedPreferences _prefs;
  final SecureStorageInterface _secure;

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

  Future<UserProfile?> getProfile() async {
    final username = _prefs.getString('username');
    if (username == null) return null;
    final profile = UserProfile(username: username);
    profile.sfxEnabled = _prefs.getBool('sfx') ?? true;
    profile.musicEnabled = _prefs.getBool('music') ?? true;
    profile.hapticsEnabled = _prefs.getBool('haptics') ?? true;
    profile.currentStreak = _prefs.getInt('streak_count') ?? 0;
    return profile;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString('username', profile.username);
    await _prefs.setBool('sfx', profile.sfxEnabled);
    await _prefs.setBool('music', profile.musicEnabled);
    await _prefs.setBool('haptics', profile.hapticsEnabled);
    await _prefs.setInt('streak_count', profile.currentStreak);
  }

  bool getOnboardingDone() => _prefs.getBool('onboarding_done') ?? false;

  Future<void> setOnboardingDone() async {
    await _prefs.setBool('onboarding_done', true);
  }

  bool getTutorialDone() => _prefs.getBool('tutorial_done') ?? false;

  Future<void> setTutorialDone() async {
    await _prefs.setBool('tutorial_done', true);
  }

  bool getColorblindPromptShown() =>
      _prefs.getBool('colorblind_prompt_shown') ?? false;

  Future<void> setColorblindPromptShown() async {
    await _prefs.setBool('colorblind_prompt_shown', true);
  }

  // ─── COPPA yaş kapısı ──────────────────────────────────────────────────────

  Future<bool> getAgeVerified() async {
    final secure = await _secure.read(key: 'age_verified');
    if (secure != null) return secure == 'true';
    return _prefs.getBool('age_verified') ?? false;
  }

  Future<bool> getIsChild() async {
    final secure = await _secure.read(key: 'is_child');
    if (secure != null) return secure == 'true';
    return _prefs.getBool('is_child') ?? false;
  }

  Future<void> setAgeVerified({required bool isChild}) async {
    await _secure.write(key: 'age_verified', value: 'true');
    await _secure.write(key: 'is_child', value: isChild.toString());
    await _prefs.remove('age_verified');
    await _prefs.remove('is_child');
  }

  // ─── Gizlilik & Analitik ─────────────────────────────────────────────────

  bool getAnalyticsEnabled() => _prefs.getBool('analytics_enabled') ?? false;

  Future<void> setAnalyticsEnabled(bool value) async {
    await _prefs.setBool('analytics_enabled', value);
  }

  bool getConsentShown() => _prefs.getBool('consent_shown') ?? false;

  Future<void> setConsentShown() async {
    await _prefs.setBool('consent_shown', true);
  }

  /// GDPR: tüm yerel kullanıcı verilerini siler.
  Future<void> clearAllData() async {
    await _prefs.clear();
    await _secure.deleteAll();
  }

  /// GDPR Article 20: tüm yerel kullanıcı verilerini JSON Map olarak döner.
  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'profile': {
        'username': _prefs.getString('username'),
      },
      'settings': {
        'sfx': _prefs.getBool('sfx') ?? true,
        'music': _prefs.getBool('music') ?? true,
        'haptics': _prefs.getBool('haptics') ?? true,
        'analytics_enabled': getAnalyticsEnabled(),
      },
      'scores': {
        'classic': await getHighScore('classic'),
        'colorChef': await getHighScore('colorChef'),
        'timeTrial': await getHighScore('timeTrial'),
        'zen': await getHighScore('zen'),
        'daily': await getHighScore('daily'),
        'level': await getHighScore('level'),
        'duel': await getHighScore('duel'),
      },
      'stats': {
        'total_games_played': getTotalGamesPlayed(),
        'average_score': getAverageScore(),
        'consecutive_losses': getConsecutiveLosses(),
      },
      'currency': {
        'gel_ozu': await getGelOzu(),
        'gel_energy': await getGelEnergy(),
        'total_earned_energy': getTotalEarnedEnergy(),
        'lifetime_earnings': await getLifetimeEarnings(),
      },
      'progress': {
        'current_level': getCurrentLevel(),
        'max_completed_level': getMaxCompletedLevel(),
        'completed_levels': getCompletedLevels().toList(),
      },
      'pvp': {
        'elo': await getElo(),
        'wins': await getPvpWins(),
        'losses': await getPvpLosses(),
      },
      'streak': {
        'count': getStreak(),
        'last_date': _prefs.getString('streak_last_date'),
        'last_reward_day': getLastStreakRewardDay(),
      },
      'collections': {
        'discovered_colors': getDiscoveredColors().toList(),
      },
      'daily_puzzle': {
        'completed_today': isDailyCompleted(),
        'today_score': getDailyScore(),
      },
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  // ─── Streak ───────────────────────────────────────────────────────────────

  int getStreak() => _prefs.getInt('streak_count') ?? 0;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Günlük girişi kayıt altına alır.
  /// Dün girdiyse streak +1, daha eskiyse 1'e sıfırlar, bugün zaten girdiyse değiştirmez.
  /// Güncel streak sayısını döner.
  Future<int> checkAndUpdateStreak() async {
    final today = _todayKey();
    final lastDate = _prefs.getString('streak_last_date');

    if (lastDate == today) return getStreak(); // bugün zaten sayıldı

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

  // ─── Koleksiyon (keşfedilen renkler) ──────────────────────────────────────

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

  // ─── Günlük Bulmaca ───────────────────────────────────────────────────────

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

  // ─── Faz 4: Jel Özü (Soft Currency) ──────────────────────────────────────

  Future<int> getGelOzu() async {
    final secure = await _secure.read(key: 'gel_ozu');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('gel_ozu') ?? 0;
  }

  Future<void> saveGelOzu(int value) async {
    await _secure.write(key: 'gel_ozu', value: value.toString());
    await _prefs.remove('gel_ozu');
  }

  Future<int> getLifetimeEarnings() async {
    final secure = await _secure.read(key: 'lifetime_earnings');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('lifetime_earnings') ?? 0;
  }

  Future<void> saveLifetimeEarnings(int value) async {
    await _secure.write(key: 'lifetime_earnings', value: value.toString());
    await _prefs.remove('lifetime_earnings');
  }

  // ─── Faz 4: Jel Enerjisi (Meta-game Resource) ────────────────────────────

  Future<int> getGelEnergy() async {
    final secure = await _secure.read(key: 'gel_energy');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('gel_energy') ?? 0;
  }

  Future<void> saveGelEnergy(int value) async {
    await _secure.write(key: 'gel_energy', value: value.toString());
    await _prefs.remove('gel_energy');
  }

  int getTotalEarnedEnergy() => _prefs.getInt('total_earned_energy') ?? 0;

  Future<void> saveTotalEarnedEnergy(int value) async {
    await _prefs.setInt('total_earned_energy', value);
  }

  // ─── Faz 4: Seviye İlerleme ──────────────────────────────────────────────

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

  /// Seviye bazlı en yüksek skor.
  int getLevelHighScore(int levelId) =>
      _prefs.getInt('level_highscore_$levelId') ?? 0;

  Future<void> saveLevelHighScore(int levelId, int score) async {
    final key = 'level_highscore_$levelId';
    final current = _prefs.getInt(key) ?? 0;
    if (score > current) {
      await _prefs.setInt(key, score);
    }
  }

  /// Tamamlanan seviyelerin ID setini doner.
  Set<int> getCompletedLevels() {
    final raw = _prefs.getStringList('completed_levels');
    if (raw == null) return {};
    return raw.map((s) => int.tryParse(s)).whereType<int>().toSet();
  }

  /// Belirtilen seviyeyi tamamlandi olarak isaretler ve skoru kaydeder.
  Future<void> setLevelCompleted(int levelId, int score) async {
    // Tamamlanan seviyeler seti
    final current = getCompletedLevels();
    current.add(levelId);
    await _prefs.setStringList(
        'completed_levels', current.map((e) => e.toString()).toList());
    // En yuksek seviye
    await saveMaxCompletedLevel(levelId);
    // Skor
    await saveLevelHighScore(levelId, score);
  }

  /// Belirtilen seviyenin skoru.
  int? getLevelScore(int levelId) {
    final score = getLevelHighScore(levelId);
    return score > 0 ? score : null;
  }

  // ─── Faz 4: Oyun İstatistikleri ──────────────────────────────────────────

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

  // ─── Faz 4: PvP / ELO ────────────────────────────────────────────────────

  Future<int> getElo() async {
    final secure = await _secure.read(key: 'elo');
    if (secure != null) return int.tryParse(secure) ?? 1000;
    return _prefs.getInt('elo') ?? 1000;
  }

  Future<void> saveElo(int value) async {
    await _secure.write(key: 'elo', value: value.toString());
    await _prefs.remove('elo');
  }

  Future<int> getPvpWins() async {
    final secure = await _secure.read(key: 'pvp_wins');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('pvp_wins') ?? 0;
  }

  Future<int> getPvpLosses() async {
    final secure = await _secure.read(key: 'pvp_losses');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('pvp_losses') ?? 0;
  }

  Future<void> recordPvpResult({required bool isWin}) async {
    if (isWin) {
      final wins = await getPvpWins();
      await _secure.write(key: 'pvp_wins', value: (wins + 1).toString());
      await _prefs.remove('pvp_wins');
    } else {
      final losses = await getPvpLosses();
      await _secure.write(key: 'pvp_losses', value: (losses + 1).toString());
      await _prefs.remove('pvp_losses');
    }
  }

  // ─── Faz 4: Ada Durumu ────────────────────────────────────────────────────

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

  // ─── Faz 4: Karakter Durumu ───────────────────────────────────────────────

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

  // ─── Faz 4: Sezon Pası Durumu ────────────────────────────────────────────

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

  // ─── Faz 4: Günlük Görev İlerleme ────────────────────────────────────────

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

  // ─── IAP Pending Verification ───────────────────────────────────────────

  Future<List<String>> getPendingVerification() async {
    final secure = await _secure.read(key: 'pending_verification');
    if (secure != null && secure.isNotEmpty) {
      return secure.split(',');
    }
    return _prefs.getStringList('pending_verification') ?? [];
  }

  /// Receipt'li pending verification map'ini döner (productId → receipt).
  /// Eski formattaki verileri (virgülle ayrılmış ID listesi) boş receipt ile migrate eder.
  Future<Map<String, String>> getPendingVerificationMap() async {
    final secure = await _secure.read(key: 'pending_verification_map');
    if (secure != null && secure.isNotEmpty) {
      final decoded = json.decode(secure);
      return Map<String, String>.from(decoded as Map);
    }
    // Eski formattan migration: receipt bilgisi yok, boş string olarak aktar
    final legacy = await getPendingVerification();
    if (legacy.isNotEmpty) {
      final map = {for (final id in legacy) id: ''};
      await savePendingVerificationMap(map);
      return map;
    }
    return {};
  }

  Future<void> savePendingVerificationMap(Map<String, String> pending) async {
    if (pending.isEmpty) {
      await _secure.write(key: 'pending_verification_map', value: null);
    } else {
      await _secure.write(
          key: 'pending_verification_map', value: json.encode(pending));
    }
    // Eski formatı temizle
    await _secure.write(key: 'pending_verification', value: null);
    await _prefs.remove('pending_verification');
  }

  Future<void> savePendingVerification(List<String> productIds) async {
    await _secure.write(
        key: 'pending_verification', value: productIds.join(','));
    await _prefs.remove('pending_verification');
  }

  // ─── Redeem Code ────────────────────────────────────────────────────────

  Future<List<String>> getRedeemedCodes() async {
    final secure = await _secure.read(key: 'redeemed_codes');
    if (secure != null && secure.isNotEmpty) {
      return secure.split(',');
    }
    return _prefs.getStringList('redeemed_codes') ?? [];
  }

  Future<void> addRedeemedCode(String code) async {
    final current = await getRedeemedCodes();
    if (!current.contains(code)) {
      current.add(code);
      await _secure.write(key: 'redeemed_codes', value: current.join(','));
      await _prefs.remove('redeemed_codes');
    }
  }

  Future<List<String>> getUnlockedProducts() async {
    final secure = await _secure.read(key: 'unlocked_products');
    if (secure != null && secure.isNotEmpty) {
      return secure.split(',');
    }
    return _prefs.getStringList('unlocked_products') ?? [];
  }

  Future<void> addUnlockedProducts(List<String> productIds) async {
    final current = await getUnlockedProducts();
    final updated = {...current, ...productIds}.toList();
    await _secure.write(key: 'unlocked_products', value: updated.join(','));
    await _prefs.remove('unlocked_products');
  }

  // ─── Tema Modu ────────────────────────────────────────────────────────────

  Future<ThemeMode> getThemeMode() async {
    final value = _prefs.getString('theme_mode');
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString('theme_mode', mode.name);
  }
}
