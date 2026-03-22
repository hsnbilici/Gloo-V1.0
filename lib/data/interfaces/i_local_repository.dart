import 'package:flutter/material.dart';

import 'package:gloo/data/local/data_models.dart';

/// Abstract interface for local data persistence.
/// Mirrors the public API of [LocalRepository] to allow testable abstractions.
abstract class ILocalRepository {
  // ─── High Score ──────────────────────────────────────────────────────────

  Future<void> saveScore({required String mode, required int value});

  Future<int> getHighScore(String mode);

  // ─── Profile ─────────────────────────────────────────────────────────────

  Future<UserProfile?> getProfile();

  Future<void> saveProfile(UserProfile p);

  // ─── Onboarding ──────────────────────────────────────────────────────────

  bool getOnboardingDone();

  Future<void> setOnboardingDone();

  // ─── Tutorial ────────────────────────────────────────────────────────────

  bool getTutorialDone();

  Future<void> setTutorialDone();

  // ─── Colorblind Prompt ───────────────────────────────────────────────────

  bool getColorblindPromptShown();

  Future<void> setColorblindPromptShown();

  // ─── Gizlilik & Analitik ─────────────────────────────────────────────────

  bool getAnalyticsEnabled();

  Future<void> setAnalyticsEnabled(bool value);

  bool getConsentShown();

  Future<void> setConsentShown();

  // ─── GDPR ────────────────────────────────────────────────────────────────

  Future<void> clearAllData();

  Future<Map<String, dynamic>> exportAllData();

  // ─── Streak ──────────────────────────────────────────────────────────────

  int getStreak();

  Future<int> checkAndUpdateStreak();

  // ─── Streak Freeze ──────────────────────────────────────────────────────

  bool hasStreakFreeze();

  Future<void> setStreakFreeze(bool value);

  int getLastStreakRewardDay();

  Future<void> setLastStreakRewardDay(int day);

  // ─── Koleksiyon (keşfedilen renkler) ────────────────────────────────────

  Set<String> getDiscoveredColors();

  Future<void> addDiscoveredColor(String colorName);

  bool isCollectionRewardClaimed();

  Future<void> setCollectionRewardClaimed();

  // ─── Günlük Bulmaca ──────────────────────────────────────────────────────

  bool isDailyCompleted();

  int getDailyScore();

  Future<void> saveDailyResult(int score);

  // ─── Jel Özü (Soft Currency) ─────────────────────────────────────────────

  Future<int> getGelOzu();

  Future<void> saveGelOzu(int value);

  Future<int> getLifetimeEarnings();

  Future<void> saveLifetimeEarnings(int value);

  // ─── Jel Enerjisi (Meta-game Resource) ───────────────────────────────────

  Future<int> getGelEnergy();

  Future<void> saveGelEnergy(int value);

  int getTotalEarnedEnergy();

  Future<void> saveTotalEarnedEnergy(int value);

  // ─── Seviye İlerleme ─────────────────────────────────────────────────────

  int getCurrentLevel();

  Future<void> saveCurrentLevel(int level);

  int getMaxCompletedLevel();

  Future<void> saveMaxCompletedLevel(int level);

  int getLevelHighScore(int levelId);

  Future<void> saveLevelHighScore(int levelId, int score);

  Set<int> getCompletedLevels();

  Future<void> setLevelCompleted(int levelId, int score);

  int? getLevelScore(int levelId);

  // ─── Oyun İstatistikleri ─────────────────────────────────────────────────

  int getTotalGamesPlayed();

  Future<void> incrementGamesPlayed();

  int getAverageScore();

  Future<void> updateAverageScore(int newScore);

  int getConsecutiveLosses();

  Future<void> setConsecutiveLosses(int count);

  // ─── PvP / ELO ───────────────────────────────────────────────────────────

  Future<int> getElo();

  Future<void> saveElo(int value);

  Future<int> getPvpWins();

  Future<int> getPvpLosses();

  Future<void> recordPvpResult({required bool isWin});

  // ─── Ada Durumu ──────────────────────────────────────────────────────────

  Map<String, int> getIslandState();

  Future<void> saveIslandState(Map<String, int> state);

  // ─── Karakter Durumu ─────────────────────────────────────────────────────

  Map<String, dynamic> getCharacterState();

  Future<void> saveCharacterState(Map<String, dynamic> state);

  // ─── Sezon Pası Durumu ───────────────────────────────────────────────────

  Map<String, int> getSeasonPassState();

  Future<void> saveSeasonPassState(Map<String, int> state);

  // ─── Günlük Görev İlerleme ───────────────────────────────────────────────

  Map<String, int> getDailyQuestProgress();

  Future<void> saveDailyQuestProgress(Map<String, int> progress);

  String? getDailyQuestDate();

  Future<void> saveDailyQuestDate(String date);

  // ─── IAP Pending Verification ────────────────────────────────────────────

  Future<List<String>> getPendingVerification();

  Future<Map<String, String>> getPendingVerificationMap();

  Future<void> savePendingVerificationMap(Map<String, String> pending);

  Future<void> savePendingVerification(List<String> productIds);

  // ─── Redeem Code ─────────────────────────────────────────────────────────

  Future<List<String>> getRedeemedCodes();

  Future<void> addRedeemedCode(String code);

  Future<List<String>> getUnlockedProducts();

  Future<void> addUnlockedProducts(List<String> productIds);

  // ─── Tema Modu ───────────────────────────────────────────────────────────

  Future<ThemeMode> getThemeMode();

  Future<void> setThemeMode(ThemeMode mode);
}
