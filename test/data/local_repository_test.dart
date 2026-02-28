import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/data/local/data_models.dart';
import 'package:gloo/data/local/local_repository.dart';

void main() {
  late LocalRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<LocalRepository> createRepo() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalRepository(prefs);
  }

  // ─── High Score ─────────────────────────────────────────────────────────

  group('High Score', () {
    test('getHighScore returns 0 for unknown mode', () async {
      repo = await createRepo();
      expect(await repo.getHighScore('classic'), 0);
    });

    test('saveScore saves new high score', () async {
      repo = await createRepo();
      await repo.saveScore(mode: 'classic', value: 1000);
      expect(await repo.getHighScore('classic'), 1000);
    });

    test('saveScore does not overwrite with lower score', () async {
      repo = await createRepo();
      await repo.saveScore(mode: 'classic', value: 1000);
      await repo.saveScore(mode: 'classic', value: 500);
      expect(await repo.getHighScore('classic'), 1000);
    });

    test('saveScore overwrites with higher score', () async {
      repo = await createRepo();
      await repo.saveScore(mode: 'classic', value: 1000);
      await repo.saveScore(mode: 'classic', value: 1500);
      expect(await repo.getHighScore('classic'), 1500);
    });

    test('different modes have independent scores', () async {
      repo = await createRepo();
      await repo.saveScore(mode: 'classic', value: 1000);
      await repo.saveScore(mode: 'timeTrial', value: 2000);
      expect(await repo.getHighScore('classic'), 1000);
      expect(await repo.getHighScore('timeTrial'), 2000);
    });
  });

  // ─── Profile ────────────────────────────────────────────────────────────

  group('Profile', () {
    test('getProfile returns null when no profile saved', () async {
      repo = await createRepo();
      expect(await repo.getProfile(), isNull);
    });

    test('saveProfile + getProfile round trip', () async {
      repo = await createRepo();
      final profile = UserProfile(username: 'TestPlayer');
      profile.sfxEnabled = false;
      profile.musicEnabled = false;
      profile.hapticsEnabled = false;
      profile.currentStreak = 5;
      await repo.saveProfile(profile);

      final loaded = await repo.getProfile();
      expect(loaded, isNotNull);
      expect(loaded!.username, 'TestPlayer');
      expect(loaded.sfxEnabled, isFalse);
      expect(loaded.musicEnabled, isFalse);
      expect(loaded.hapticsEnabled, isFalse);
      expect(loaded.currentStreak, 5);
    });
  });

  // ─── Onboarding ─────────────────────────────────────────────────────────

  group('Onboarding', () {
    test('getOnboardingDone defaults to false', () async {
      repo = await createRepo();
      expect(repo.getOnboardingDone(), isFalse);
    });

    test('setOnboardingDone sets to true', () async {
      repo = await createRepo();
      await repo.setOnboardingDone();
      expect(repo.getOnboardingDone(), isTrue);
    });
  });

  // ─── Colorblind Prompt ──────────────────────────────────────────────────

  group('Colorblind Prompt', () {
    test('defaults to false', () async {
      repo = await createRepo();
      expect(repo.getColorblindPromptShown(), isFalse);
    });

    test('setColorblindPromptShown sets to true', () async {
      repo = await createRepo();
      await repo.setColorblindPromptShown();
      expect(repo.getColorblindPromptShown(), isTrue);
    });
  });

  // ─── Analytics ──────────────────────────────────────────────────────────

  group('Analytics', () {
    test('defaults to true', () async {
      repo = await createRepo();
      expect(repo.getAnalyticsEnabled(), isTrue);
    });

    test('setAnalyticsEnabled persists', () async {
      repo = await createRepo();
      await repo.setAnalyticsEnabled(false);
      expect(repo.getAnalyticsEnabled(), isFalse);
    });
  });

  // ─── GDPR Clear All ────────────────────────────────────────────────────

  group('clearAllData', () {
    test('removes all stored data', () async {
      repo = await createRepo();
      await repo.saveScore(mode: 'classic', value: 1000);
      await repo.setOnboardingDone();
      await repo.saveGelOzu(50);

      await repo.clearAllData();
      expect(await repo.getHighScore('classic'), 0);
      expect(repo.getOnboardingDone(), isFalse);
      expect(repo.getGelOzu(), 0);
    });
  });

  // ─── Streak ─────────────────────────────────────────────────────────────

  group('Streak', () {
    test('getStreak defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getStreak(), 0);
    });

    test('checkAndUpdateStreak sets streak to 1 on first call', () async {
      repo = await createRepo();
      final streak = await repo.checkAndUpdateStreak();
      expect(streak, 1);
    });

    test('checkAndUpdateStreak same day returns same streak', () async {
      repo = await createRepo();
      await repo.checkAndUpdateStreak();
      final streak = await repo.checkAndUpdateStreak();
      expect(streak, 1);
    });
  });

  // ─── Collection (discovered colors) ─────────────────────────────────────

  group('Discovered Colors', () {
    test('defaults to empty set', () async {
      repo = await createRepo();
      expect(repo.getDiscoveredColors(), isEmpty);
    });

    test('addDiscoveredColor adds to set', () async {
      repo = await createRepo();
      await repo.addDiscoveredColor('orange');
      expect(repo.getDiscoveredColors(), contains('orange'));
    });

    test('addDiscoveredColor no duplicates', () async {
      repo = await createRepo();
      await repo.addDiscoveredColor('orange');
      await repo.addDiscoveredColor('orange');
      expect(repo.getDiscoveredColors().length, 1);
    });

    test('multiple colors', () async {
      repo = await createRepo();
      await repo.addDiscoveredColor('orange');
      await repo.addDiscoveredColor('purple');
      await repo.addDiscoveredColor('green');
      expect(repo.getDiscoveredColors().length, 3);
    });
  });

  // ─── Daily Puzzle ───────────────────────────────────────────────────────

  group('Daily Puzzle', () {
    test('isDailyCompleted defaults to false', () async {
      repo = await createRepo();
      expect(repo.isDailyCompleted(), isFalse);
    });

    test('getDailyScore defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getDailyScore(), 0);
    });

    test('saveDailyResult records score and marks completed', () async {
      repo = await createRepo();
      await repo.saveDailyResult(500);
      expect(repo.isDailyCompleted(), isTrue);
      expect(repo.getDailyScore(), 500);
    });

    test('saveDailyResult keeps higher score on same day', () async {
      repo = await createRepo();
      await repo.saveDailyResult(500);
      await repo.saveDailyResult(300);
      expect(repo.getDailyScore(), 500);
    });

    test('saveDailyResult updates to higher score on same day', () async {
      repo = await createRepo();
      await repo.saveDailyResult(500);
      await repo.saveDailyResult(800);
      expect(repo.getDailyScore(), 800);
    });
  });

  // ─── Gel Ozu (Soft Currency) ────────────────────────────────────────────

  group('Gel Ozu', () {
    test('defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getGelOzu(), 0);
    });

    test('saveGelOzu persists', () async {
      repo = await createRepo();
      await repo.saveGelOzu(100);
      expect(repo.getGelOzu(), 100);
    });
  });

  // ─── Gel Energy ─────────────────────────────────────────────────────────

  group('Gel Energy', () {
    test('defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getGelEnergy(), 0);
    });

    test('saveGelEnergy persists', () async {
      repo = await createRepo();
      await repo.saveGelEnergy(50);
      expect(repo.getGelEnergy(), 50);
    });

    test('total earned energy defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getTotalEarnedEnergy(), 0);
    });

    test('saveTotalEarnedEnergy persists', () async {
      repo = await createRepo();
      await repo.saveTotalEarnedEnergy(200);
      expect(repo.getTotalEarnedEnergy(), 200);
    });
  });

  // ─── Level Progression ──────────────────────────────────────────────────

  group('Level Progression', () {
    test('getCurrentLevel defaults to 1', () async {
      repo = await createRepo();
      expect(repo.getCurrentLevel(), 1);
    });

    test('saveCurrentLevel persists', () async {
      repo = await createRepo();
      await repo.saveCurrentLevel(15);
      expect(repo.getCurrentLevel(), 15);
    });

    test('getMaxCompletedLevel defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getMaxCompletedLevel(), 0);
    });

    test('saveMaxCompletedLevel only increases', () async {
      repo = await createRepo();
      await repo.saveMaxCompletedLevel(10);
      expect(repo.getMaxCompletedLevel(), 10);
      await repo.saveMaxCompletedLevel(5);
      expect(repo.getMaxCompletedLevel(), 10);
      await repo.saveMaxCompletedLevel(15);
      expect(repo.getMaxCompletedLevel(), 15);
    });

    test('getLevelHighScore defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getLevelHighScore(1), 0);
    });

    test('saveLevelHighScore only keeps higher', () async {
      repo = await createRepo();
      await repo.saveLevelHighScore(5, 1000);
      expect(repo.getLevelHighScore(5), 1000);
      await repo.saveLevelHighScore(5, 500);
      expect(repo.getLevelHighScore(5), 1000);
      await repo.saveLevelHighScore(5, 1500);
      expect(repo.getLevelHighScore(5), 1500);
    });

    test('getCompletedLevels defaults to empty', () async {
      repo = await createRepo();
      expect(repo.getCompletedLevels(), isEmpty);
    });

    test('setLevelCompleted adds to completed set', () async {
      repo = await createRepo();
      await repo.setLevelCompleted(5, 1000);
      expect(repo.getCompletedLevels(), contains(5));
      expect(repo.getMaxCompletedLevel(), 5);
      expect(repo.getLevelHighScore(5), 1000);
    });

    test('getLevelScore returns null for unplayed', () async {
      repo = await createRepo();
      expect(repo.getLevelScore(99), isNull);
    });

    test('getLevelScore returns score for played', () async {
      repo = await createRepo();
      await repo.saveLevelHighScore(3, 800);
      expect(repo.getLevelScore(3), 800);
    });
  });

  // ─── Game Stats ─────────────────────────────────────────────────────────

  group('Game Stats', () {
    test('getTotalGamesPlayed defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getTotalGamesPlayed(), 0);
    });

    test('incrementGamesPlayed increments by 1', () async {
      repo = await createRepo();
      await repo.incrementGamesPlayed();
      expect(repo.getTotalGamesPlayed(), 1);
      await repo.incrementGamesPlayed();
      expect(repo.getTotalGamesPlayed(), 2);
    });

    test('getAverageScore defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getAverageScore(), 0);
    });

    test('getConsecutiveLosses defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getConsecutiveLosses(), 0);
    });

    test('setConsecutiveLosses persists', () async {
      repo = await createRepo();
      await repo.setConsecutiveLosses(3);
      expect(repo.getConsecutiveLosses(), 3);
    });
  });

  // ─── PvP / ELO ─────────────────────────────────────────────────────────

  group('PvP / ELO', () {
    test('getElo defaults to 1000', () async {
      repo = await createRepo();
      expect(repo.getElo(), 1000);
    });

    test('saveElo persists', () async {
      repo = await createRepo();
      await repo.saveElo(1250);
      expect(repo.getElo(), 1250);
    });

    test('getPvpWins defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getPvpWins(), 0);
    });

    test('getPvpLosses defaults to 0', () async {
      repo = await createRepo();
      expect(repo.getPvpLosses(), 0);
    });

    test('recordPvpResult win increments wins', () async {
      repo = await createRepo();
      await repo.recordPvpResult(isWin: true);
      expect(repo.getPvpWins(), 1);
      expect(repo.getPvpLosses(), 0);
    });

    test('recordPvpResult loss increments losses', () async {
      repo = await createRepo();
      await repo.recordPvpResult(isWin: false);
      expect(repo.getPvpWins(), 0);
      expect(repo.getPvpLosses(), 1);
    });

    test('multiple PvP results accumulate', () async {
      repo = await createRepo();
      await repo.recordPvpResult(isWin: true);
      await repo.recordPvpResult(isWin: true);
      await repo.recordPvpResult(isWin: false);
      expect(repo.getPvpWins(), 2);
      expect(repo.getPvpLosses(), 1);
    });
  });

  // ─── Island State ───────────────────────────────────────────────────────

  group('Island State', () {
    test('defaults to empty map', () async {
      repo = await createRepo();
      expect(repo.getIslandState(), isEmpty);
    });

    test('saveIslandState + getIslandState round trip', () async {
      repo = await createRepo();
      final state = {'gelFactory': 3, 'asmrTower': 1};
      await repo.saveIslandState(state);
      expect(repo.getIslandState(), state);
    });
  });

  // ─── Character State ────────────────────────────────────────────────────

  group('Character State', () {
    test('defaults to empty map', () async {
      repo = await createRepo();
      expect(repo.getCharacterState(), isEmpty);
    });

    test('saveCharacterState + getCharacterState round trip', () async {
      repo = await createRepo();
      final state = {'equippedCostume': 'default', 'talents': [1, 2]};
      await repo.saveCharacterState(state);
      final loaded = repo.getCharacterState();
      expect(loaded['equippedCostume'], 'default');
    });
  });

  // ─── Season Pass State ──────────────────────────────────────────────────

  group('Season Pass State', () {
    test('defaults to empty map', () async {
      repo = await createRepo();
      expect(repo.getSeasonPassState(), isEmpty);
    });

    test('saveSeasonPassState + getSeasonPassState round trip', () async {
      repo = await createRepo();
      final state = {'xp': 500, 'tier': 5};
      await repo.saveSeasonPassState(state);
      expect(repo.getSeasonPassState(), state);
    });
  });

  // ─── Daily Quest Progress ───────────────────────────────────────────────

  group('Daily Quest Progress', () {
    test('defaults to empty map', () async {
      repo = await createRepo();
      expect(repo.getDailyQuestProgress(), isEmpty);
    });

    test('saveDailyQuestProgress round trip', () async {
      repo = await createRepo();
      final progress = {'quest1': 3, 'quest2': 0};
      await repo.saveDailyQuestProgress(progress);
      expect(repo.getDailyQuestProgress(), progress);
    });

    test('getDailyQuestDate defaults to null', () async {
      repo = await createRepo();
      expect(repo.getDailyQuestDate(), isNull);
    });

    test('saveDailyQuestDate persists', () async {
      repo = await createRepo();
      await repo.saveDailyQuestDate('2026-02-28');
      expect(repo.getDailyQuestDate(), '2026-02-28');
    });
  });

  // ─── Redeem Codes ───────────────────────────────────────────────────────

  group('Redeem Codes', () {
    test('getRedeemedCodes defaults to empty', () async {
      repo = await createRepo();
      expect(repo.getRedeemedCodes(), isEmpty);
    });

    test('addRedeemedCode adds code', () async {
      repo = await createRepo();
      await repo.addRedeemedCode('ABC123');
      expect(repo.getRedeemedCodes(), ['ABC123']);
    });

    test('addRedeemedCode no duplicates', () async {
      repo = await createRepo();
      await repo.addRedeemedCode('ABC123');
      await repo.addRedeemedCode('ABC123');
      expect(repo.getRedeemedCodes().length, 1);
    });
  });

  // ─── Unlocked Products ──────────────────────────────────────────────────

  group('Unlocked Products', () {
    test('getUnlockedProducts defaults to empty', () async {
      repo = await createRepo();
      expect(repo.getUnlockedProducts(), isEmpty);
    });

    test('addUnlockedProducts adds products', () async {
      repo = await createRepo();
      await repo.addUnlockedProducts(['product1', 'product2']);
      final products = repo.getUnlockedProducts();
      expect(products, contains('product1'));
      expect(products, contains('product2'));
    });

    test('addUnlockedProducts deduplicates', () async {
      repo = await createRepo();
      await repo.addUnlockedProducts(['product1']);
      await repo.addUnlockedProducts(['product1', 'product2']);
      final products = repo.getUnlockedProducts();
      expect(products.where((p) => p == 'product1').length, 1);
    });
  });
}
