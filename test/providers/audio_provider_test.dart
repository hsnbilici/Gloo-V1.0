import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/providers/audio_provider.dart';

void main() {
  // ─── AppSettings ──────────────────────────────────────────────────────

  group('AppSettings', () {
    test('default values', () {
      const settings = AppSettings();
      expect(settings.sfxEnabled, isTrue);
      expect(settings.musicEnabled, isTrue);
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.colorBlindMode, isFalse);
      expect(settings.analyticsEnabled, isTrue);
      expect(settings.glooPlus, isFalse);
      expect(settings.adsRemoved, isFalse);
    });

    test('copyWith updates only specified fields', () {
      const settings = AppSettings();
      final updated = settings.copyWith(sfxEnabled: false);
      expect(updated.sfxEnabled, isFalse);
      expect(updated.musicEnabled, isTrue);
      expect(updated.hapticsEnabled, isTrue);
    });

    test('copyWith can update all fields', () {
      const settings = AppSettings();
      final updated = settings.copyWith(
        sfxEnabled: false,
        musicEnabled: false,
        hapticsEnabled: false,
        colorBlindMode: true,
        analyticsEnabled: false,
        glooPlus: true,
        adsRemoved: true,
      );
      expect(updated.sfxEnabled, isFalse);
      expect(updated.musicEnabled, isFalse);
      expect(updated.hapticsEnabled, isFalse);
      expect(updated.colorBlindMode, isTrue);
      expect(updated.analyticsEnabled, isFalse);
      expect(updated.glooPlus, isTrue);
      expect(updated.adsRemoved, isTrue);
    });

    test('custom constructor values', () {
      const settings = AppSettings(
        sfxEnabled: false,
        glooPlus: true,
        adsRemoved: true,
      );
      expect(settings.sfxEnabled, isFalse);
      expect(settings.musicEnabled, isTrue);
      expect(settings.glooPlus, isTrue);
      expect(settings.adsRemoved, isTrue);
    });
  });

  // ─── AppSettingsNotifier ──────────────────────────────────────────────
  // Note: toggleSfx/Music/Haptics call AudioManager/HapticManager singletons
  // which need a Flutter engine. We test the state-only methods here.

  group('AppSettingsNotifier', () {
    late AppSettingsNotifier notifier;

    setUp(() {
      notifier = AppSettingsNotifier();
    });

    test('initial state is default AppSettings', () {
      expect(notifier.state.sfxEnabled, isTrue);
      expect(notifier.state.musicEnabled, isTrue);
      expect(notifier.state.hapticsEnabled, isTrue);
      expect(notifier.state.colorBlindMode, isFalse);
      expect(notifier.state.analyticsEnabled, isTrue);
      expect(notifier.state.glooPlus, isFalse);
      expect(notifier.state.adsRemoved, isFalse);
    });

    test('toggleColorBlindMode toggles', () {
      notifier.toggleColorBlindMode();
      expect(notifier.state.colorBlindMode, isTrue);
      notifier.toggleColorBlindMode();
      expect(notifier.state.colorBlindMode, isFalse);
    });

    test('setColorBlindMode sets specific value', () {
      notifier.setColorBlindMode(enabled: true);
      expect(notifier.state.colorBlindMode, isTrue);
      notifier.setColorBlindMode(enabled: false);
      expect(notifier.state.colorBlindMode, isFalse);
    });

    test('toggleAnalytics toggles', () {
      notifier.toggleAnalytics();
      expect(notifier.state.analyticsEnabled, isFalse);
      notifier.toggleAnalytics();
      expect(notifier.state.analyticsEnabled, isTrue);
    });

    test('setAnalyticsEnabled sets specific value', () {
      notifier.setAnalyticsEnabled(enabled: false);
      expect(notifier.state.analyticsEnabled, isFalse);
    });

    test('setGlooPlus sets value', () {
      notifier.setGlooPlus(enabled: true);
      expect(notifier.state.glooPlus, isTrue);
    });

    test('setAdsRemoved sets value', () {
      notifier.setAdsRemoved(removed: true);
      expect(notifier.state.adsRemoved, isTrue);
    });
  });
}
