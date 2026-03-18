import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/audio/audio_manager.dart';
import 'package:gloo/audio/haptic_manager.dart';
import 'package:gloo/providers/audio_provider.dart';
import 'package:gloo/providers/service_providers.dart';

void main() {
  // AudioManager/HapticManager need Flutter engine bindings (AudioPlayer).
  TestWidgetsFlutterBinding.ensureInitialized();
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
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          audioManagerProvider.overrideWithValue(AudioManager()),
          hapticManagerProvider.overrideWithValue(HapticManager()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('initial state is default AppSettings', () {
      final state = container.read(appSettingsProvider);
      expect(state.sfxEnabled, isTrue);
      expect(state.musicEnabled, isTrue);
      expect(state.hapticsEnabled, isTrue);
      expect(state.colorBlindMode, isFalse);
      expect(state.analyticsEnabled, isTrue);
      expect(state.glooPlus, isFalse);
      expect(state.adsRemoved, isFalse);
    });

    test('toggleColorBlindMode toggles', () {
      container.read(appSettingsProvider.notifier).toggleColorBlindMode();
      expect(container.read(appSettingsProvider).colorBlindMode, isTrue);
      container.read(appSettingsProvider.notifier).toggleColorBlindMode();
      expect(container.read(appSettingsProvider).colorBlindMode, isFalse);
    });

    test('setColorBlindMode sets specific value', () {
      container
          .read(appSettingsProvider.notifier)
          .setColorBlindMode(enabled: true);
      expect(container.read(appSettingsProvider).colorBlindMode, isTrue);
      container
          .read(appSettingsProvider.notifier)
          .setColorBlindMode(enabled: false);
      expect(container.read(appSettingsProvider).colorBlindMode, isFalse);
    });

    test('toggleAnalytics toggles', () {
      container.read(appSettingsProvider.notifier).toggleAnalytics();
      expect(container.read(appSettingsProvider).analyticsEnabled, isFalse);
      container.read(appSettingsProvider.notifier).toggleAnalytics();
      expect(container.read(appSettingsProvider).analyticsEnabled, isTrue);
    });

    test('setAnalyticsEnabled sets specific value', () {
      container
          .read(appSettingsProvider.notifier)
          .setAnalyticsEnabled(enabled: false);
      expect(container.read(appSettingsProvider).analyticsEnabled, isFalse);
    });

    test('setGlooPlus sets value', () {
      container.read(appSettingsProvider.notifier).setGlooPlus(enabled: true);
      expect(container.read(appSettingsProvider).glooPlus, isTrue);
    });

    test('setAdsRemoved sets value', () {
      container.read(appSettingsProvider.notifier).setAdsRemoved(removed: true);
      expect(container.read(appSettingsProvider).adsRemoved, isTrue);
    });
  });
}
