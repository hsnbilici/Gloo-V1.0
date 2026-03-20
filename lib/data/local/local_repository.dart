import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_models.dart';
import 'economy_repository.dart';
import 'game_data_repository.dart';
import 'profile_repository.dart';
import 'pvp_repository.dart';
import 'secure_storage_interface.dart';
import 'settings_repository.dart';

/// Facade: tüm domain-specific sub-repository'leri tek bir API altında toplar.
/// Mevcut callers sıfır değişiklikle bu sınıfı kullanmaya devam edebilir.
class LocalRepository {
  LocalRepository(SharedPreferences prefs,
      {SecureStorageInterface? secureStorage})
      : _secure = secureStorage ?? const SecureStorageImpl(),
        _prefs = prefs {
    profile = ProfileRepository(_prefs, _secure);
    gameData = GameDataRepository(_prefs);
    economy = EconomyRepository(_prefs, _secure);
    pvp = PvpRepository(_prefs, _secure);
    settings = SettingsRepository(_prefs);
  }

  final SharedPreferences _prefs;
  final SecureStorageInterface _secure;

  // ─── Sub-repository erişimi ───────────────────────────────────────────────

  late final ProfileRepository profile;
  late final GameDataRepository gameData;
  late final EconomyRepository economy;
  late final PvpRepository pvp;
  late final SettingsRepository settings;

  // ─── High Score ──────────────────────────────────────────────────────────

  Future<void> saveScore({required String mode, required int value}) =>
      gameData.saveScore(mode: mode, value: value);

  Future<int> getHighScore(String mode) => gameData.getHighScore(mode);

  // ─── Profile ─────────────────────────────────────────────────────────────

  Future<UserProfile?> getProfile() => profile.getProfile();

  Future<void> saveProfile(UserProfile p) => profile.saveProfile(p);

  // ─── Onboarding ──────────────────────────────────────────────────────────

  bool getOnboardingDone() => settings.getOnboardingDone();

  Future<void> setOnboardingDone() => settings.setOnboardingDone();

  // ─── Tutorial ────────────────────────────────────────────────────────────

  bool getTutorialDone() => gameData.getTutorialDone();

  Future<void> setTutorialDone() => gameData.setTutorialDone();

  // ─── Colorblind Prompt ───────────────────────────────────────────────────

  bool getColorblindPromptShown() => settings.getColorblindPromptShown();

  Future<void> setColorblindPromptShown() =>
      settings.setColorblindPromptShown();

  // ─── COPPA Yaş Kapısı ────────────────────────────────────────────────────

  Future<bool> getAgeVerified() => profile.getAgeVerified();

  Future<bool> getIsChild() => profile.getIsChild();

  Future<void> setAgeVerified({required bool isChild}) =>
      profile.setAgeVerified(isChild: isChild);

  // ─── Gizlilik & Analitik ─────────────────────────────────────────────────

  bool getAnalyticsEnabled() => settings.getAnalyticsEnabled();

  Future<void> setAnalyticsEnabled(bool value) =>
      settings.setAnalyticsEnabled(value);

  bool getConsentShown() => settings.getConsentShown();

  Future<void> setConsentShown() => settings.setConsentShown();

  // ─── GDPR ────────────────────────────────────────────────────────────────

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
      'monetization': {
        'unlocked_products': await getUnlockedProducts(),
        'redeemed_codes': await getRedeemedCodes(),
      },
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  // ─── Streak ──────────────────────────────────────────────────────────────

  int getStreak() => gameData.getStreak();

  Future<int> checkAndUpdateStreak() => gameData.checkAndUpdateStreak();

  int getLastStreakRewardDay() => gameData.getLastStreakRewardDay();

  Future<void> setLastStreakRewardDay(int day) =>
      gameData.setLastStreakRewardDay(day);

  // ─── Koleksiyon (keşfedilen renkler) ────────────────────────────────────

  Set<String> getDiscoveredColors() => gameData.getDiscoveredColors();

  Future<void> addDiscoveredColor(String colorName) =>
      gameData.addDiscoveredColor(colorName);

  // ─── Günlük Bulmaca ──────────────────────────────────────────────────────

  bool isDailyCompleted() => gameData.isDailyCompleted();

  int getDailyScore() => gameData.getDailyScore();

  Future<void> saveDailyResult(int score) => gameData.saveDailyResult(score);

  // ─── Jel Özü (Soft Currency) ─────────────────────────────────────────────

  Future<int> getGelOzu() => economy.getGelOzu();

  Future<void> saveGelOzu(int value) => economy.saveGelOzu(value);

  Future<int> getLifetimeEarnings() => economy.getLifetimeEarnings();

  Future<void> saveLifetimeEarnings(int value) =>
      economy.saveLifetimeEarnings(value);

  // ─── Jel Enerjisi (Meta-game Resource) ───────────────────────────────────

  Future<int> getGelEnergy() => economy.getGelEnergy();

  Future<void> saveGelEnergy(int value) => economy.saveGelEnergy(value);

  int getTotalEarnedEnergy() => economy.getTotalEarnedEnergy();

  Future<void> saveTotalEarnedEnergy(int value) =>
      economy.saveTotalEarnedEnergy(value);

  // ─── Seviye İlerleme ─────────────────────────────────────────────────────

  int getCurrentLevel() => gameData.getCurrentLevel();

  Future<void> saveCurrentLevel(int level) => gameData.saveCurrentLevel(level);

  int getMaxCompletedLevel() => gameData.getMaxCompletedLevel();

  Future<void> saveMaxCompletedLevel(int level) =>
      gameData.saveMaxCompletedLevel(level);

  int getLevelHighScore(int levelId) => gameData.getLevelHighScore(levelId);

  Future<void> saveLevelHighScore(int levelId, int score) =>
      gameData.saveLevelHighScore(levelId, score);

  Set<int> getCompletedLevels() => gameData.getCompletedLevels();

  Future<void> setLevelCompleted(int levelId, int score) =>
      gameData.setLevelCompleted(levelId, score);

  int? getLevelScore(int levelId) => gameData.getLevelScore(levelId);

  // ─── Oyun İstatistikleri ─────────────────────────────────────────────────

  int getTotalGamesPlayed() => gameData.getTotalGamesPlayed();

  Future<void> incrementGamesPlayed() => gameData.incrementGamesPlayed();

  int getAverageScore() => gameData.getAverageScore();

  Future<void> updateAverageScore(int newScore) =>
      gameData.updateAverageScore(newScore);

  int getConsecutiveLosses() => gameData.getConsecutiveLosses();

  Future<void> setConsecutiveLosses(int count) =>
      gameData.setConsecutiveLosses(count);

  // ─── PvP / ELO ───────────────────────────────────────────────────────────

  Future<int> getElo() => pvp.getElo();

  Future<void> saveElo(int value) => pvp.saveElo(value);

  Future<int> getPvpWins() => pvp.getPvpWins();

  Future<int> getPvpLosses() => pvp.getPvpLosses();

  Future<void> recordPvpResult({required bool isWin}) =>
      pvp.recordPvpResult(isWin: isWin);

  // ─── Ada Durumu ──────────────────────────────────────────────────────────

  Map<String, int> getIslandState() => gameData.getIslandState();

  Future<void> saveIslandState(Map<String, int> state) =>
      gameData.saveIslandState(state);

  // ─── Karakter Durumu ─────────────────────────────────────────────────────

  Map<String, dynamic> getCharacterState() => gameData.getCharacterState();

  Future<void> saveCharacterState(Map<String, dynamic> state) =>
      gameData.saveCharacterState(state);

  // ─── Sezon Pası Durumu ───────────────────────────────────────────────────

  Map<String, int> getSeasonPassState() => gameData.getSeasonPassState();

  Future<void> saveSeasonPassState(Map<String, int> state) =>
      gameData.saveSeasonPassState(state);

  // ─── Günlük Görev İlerleme ───────────────────────────────────────────────

  Map<String, int> getDailyQuestProgress() => gameData.getDailyQuestProgress();

  Future<void> saveDailyQuestProgress(Map<String, int> progress) =>
      gameData.saveDailyQuestProgress(progress);

  String? getDailyQuestDate() => gameData.getDailyQuestDate();

  Future<void> saveDailyQuestDate(String date) =>
      gameData.saveDailyQuestDate(date);

  // ─── IAP Pending Verification ────────────────────────────────────────────

  Future<List<String>> getPendingVerification() =>
      economy.getPendingVerification();

  Future<Map<String, String>> getPendingVerificationMap() =>
      economy.getPendingVerificationMap();

  Future<void> savePendingVerificationMap(Map<String, String> pending) =>
      economy.savePendingVerificationMap(pending);

  Future<void> savePendingVerification(List<String> productIds) =>
      economy.savePendingVerification(productIds);

  // ─── Redeem Code ─────────────────────────────────────────────────────────

  Future<List<String>> getRedeemedCodes() => economy.getRedeemedCodes();

  Future<void> addRedeemedCode(String code) => economy.addRedeemedCode(code);

  Future<List<String>> getUnlockedProducts() => economy.getUnlockedProducts();

  Future<void> addUnlockedProducts(List<String> productIds) =>
      economy.addUnlockedProducts(productIds);

  // ─── Tema Modu ───────────────────────────────────────────────────────────

  Future<ThemeMode> getThemeMode() => settings.getThemeMode();

  Future<void> setThemeMode(ThemeMode mode) => settings.setThemeMode(mode);
}
