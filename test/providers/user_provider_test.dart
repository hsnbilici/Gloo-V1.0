import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/data/local/data_models.dart';
import 'package:gloo/data/local/local_repository.dart';
import 'package:gloo/providers/user_provider.dart';

void main() {
  // ─── localRepositoryProvider ──────────────────────────────────────────────

  group('localRepositoryProvider', () {
    test('resolves to LocalRepository', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = await container.read(localRepositoryProvider.future);
      expect(repo, isA<LocalRepository>());
    });

    test('returns same instance on repeated reads', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo1 = await container.read(localRepositoryProvider.future);
      final repo2 = await container.read(localRepositoryProvider.future);
      expect(identical(repo1, repo2), isTrue);
    });
  });

  // ─── userProfileProvider ──────────────────────────────────────────────────

  group('userProfileProvider', () {
    test('returns null when no profile saved', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profile = await container.read(userProfileProvider.future);
      expect(profile, isNull);
    });

    test('returns UserProfile when username exists', () async {
      SharedPreferences.setMockInitialValues({
        'username': 'testUser',
        'sfx': true,
        'music': false,
        'haptics': true,
        'streak_count': 5,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profile = await container.read(userProfileProvider.future);
      expect(profile, isNotNull);
      expect(profile!.username, 'testUser');
      expect(profile.sfxEnabled, isTrue);
      expect(profile.musicEnabled, isFalse);
      expect(profile.hapticsEnabled, isTrue);
      expect(profile.currentStreak, 5);
    });
  });

  // ─── highScoreProvider ────────────────────────────────────────────────────

  group('highScoreProvider', () {
    test('returns 0 when no score saved', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final score = await container.read(highScoreProvider('classic').future);
      expect(score, 0);
    });

    test('returns saved high score for mode', () async {
      SharedPreferences.setMockInitialValues({
        'highscore_classic': 1500,
        'highscore_timeTrial': 800,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final classic = await container.read(highScoreProvider('classic').future);
      final timeTrial =
          await container.read(highScoreProvider('timeTrial').future);
      expect(classic, 1500);
      expect(timeTrial, 800);
    });

    test('different modes are independent', () async {
      SharedPreferences.setMockInitialValues({
        'highscore_classic': 2000,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final classic = await container.read(highScoreProvider('classic').future);
      final zen = await container.read(highScoreProvider('zen').future);
      expect(classic, 2000);
      expect(zen, 0);
    });
  });

  // ─── streakProvider ───────────────────────────────────────────────────────

  group('streakProvider', () {
    test('returns 1 on first login (no previous streak)', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final streak = await container.read(streakProvider.future);
      // First call to checkAndUpdateStreak: no lastDate → streak resets to 1
      expect(streak, 1);
    });

    test('returns existing streak when already checked today', () async {
      final now = DateTime.now();
      final todayKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      SharedPreferences.setMockInitialValues({
        'streak_count': 7,
        'streak_last_date': todayKey,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final streak = await container.read(streakProvider.future);
      expect(streak, 7);
    });
  });

  // ─── eloProvider ──────────────────────────────────────────────────────────

  group('eloProvider', () {
    test('returns default 1000 when no elo saved', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final elo = await container.read(eloProvider.future);
      expect(elo, 1000);
    });

    test('returns saved elo', () async {
      SharedPreferences.setMockInitialValues({'elo': 1450});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final elo = await container.read(eloProvider.future);
      expect(elo, 1450);
    });
  });

  // ─── Provider type verification ───────────────────────────────────────────

  group('provider types', () {
    test('localRepositoryProvider is FutureProvider<LocalRepository>', () {
      expect(localRepositoryProvider, isA<FutureProvider<LocalRepository>>());
    });

    test('userProfileProvider is FutureProvider<UserProfile?>', () {
      expect(userProfileProvider, isA<FutureProvider<UserProfile?>>());
    });

    test('highScoreProvider is FutureProviderFamily', () {
      // family providers create per-argument instances
      expect(highScoreProvider, isNotNull);
      expect(highScoreProvider('classic'), isA<FutureProvider<int>>());
    });

    test('streakProvider is FutureProvider<int>', () {
      expect(streakProvider, isA<FutureProvider<int>>());
    });

    test('eloProvider is FutureProvider<int>', () {
      expect(eloProvider, isA<FutureProvider<int>>());
    });
  });
}
