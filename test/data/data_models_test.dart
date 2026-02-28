import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/data/local/data_models.dart';

void main() {
  // ─── Score ──────────────────────────────────────────────────────────────

  group('Score', () {
    test('stores mode, value, and timestamp', () {
      final now = DateTime.now();
      final score = Score(mode: 'classic', value: 1500, timestamp: now);
      expect(score.mode, 'classic');
      expect(score.value, 1500);
      expect(score.timestamp, now);
    });
  });

  // ─── UserProfile ────────────────────────────────────────────────────────

  group('UserProfile', () {
    test('creates with username', () {
      final profile = UserProfile(username: 'TestPlayer');
      expect(profile.username, 'TestPlayer');
    });

    test('defaults are correct', () {
      final profile = UserProfile(username: 'Test');
      expect(profile.sfxEnabled, isTrue);
      expect(profile.musicEnabled, isTrue);
      expect(profile.hapticsEnabled, isTrue);
      expect(profile.adsRemoved, isFalse);
      expect(profile.currentStreak, 0);
      expect(profile.platform, 'unknown');
      expect(profile.lastPlayedDate, isNull);
    });

    test('fields are mutable', () {
      final profile = UserProfile(username: 'Test');
      profile.sfxEnabled = false;
      profile.musicEnabled = false;
      profile.hapticsEnabled = false;
      profile.adsRemoved = true;
      profile.currentStreak = 5;
      profile.username = 'NewName';

      expect(profile.sfxEnabled, isFalse);
      expect(profile.musicEnabled, isFalse);
      expect(profile.hapticsEnabled, isFalse);
      expect(profile.adsRemoved, isTrue);
      expect(profile.currentStreak, 5);
      expect(profile.username, 'NewName');
    });
  });
}
