import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/audio/audio_manager.dart';
import 'package:gloo/audio/haptic_manager.dart';
import 'package:gloo/data/remote/remote_repository.dart';
import 'package:gloo/providers/service_providers.dart';
import 'package:gloo/services/ad_manager.dart';
import 'package:gloo/services/analytics_service.dart';
import 'package:gloo/services/purchase_service.dart';

void main() {
  // AudioManager constructor creates AudioPlayer which uses platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Provider type verification ───────────────────────────────────────────

  group('service provider types', () {
    test('audioManagerProvider is Provider<AudioManager>', () {
      expect(audioManagerProvider, isA<Provider<AudioManager>>());
    });

    test('hapticManagerProvider is Provider<HapticManager>', () {
      expect(hapticManagerProvider, isA<Provider<HapticManager>>());
    });

    test('adManagerProvider is Provider<AdManager>', () {
      expect(adManagerProvider, isA<Provider<AdManager>>());
    });

    test('purchaseServiceProvider is Provider<PurchaseService>', () {
      expect(purchaseServiceProvider, isA<Provider<PurchaseService>>());
    });

    test('analyticsServiceProvider is Provider<AnalyticsService>', () {
      expect(analyticsServiceProvider, isA<Provider<AnalyticsService>>());
    });

    test('remoteRepositoryProvider is Provider<RemoteRepository>', () {
      expect(remoteRepositoryProvider, isA<Provider<RemoteRepository>>());
    });
  });

  // ─── Override mechanism ───────────────────────────────────────────────────
  // Services without heavy platform-channel constructors can be tested with
  // overrideWithValue.  AudioManager uses AudioPlayer (platform channels)
  // and PurchaseService eagerly accesses InAppPurchase.instance, so we test
  // their override via overrideWith to avoid constructing a second singleton.

  group('override mechanism', () {
    test('hapticManagerProvider can be overridden', () {
      final container = ProviderContainer(
        overrides: [
          hapticManagerProvider.overrideWithValue(HapticManager()),
        ],
      );
      addTearDown(container.dispose);

      final manager = container.read(hapticManagerProvider);
      expect(manager, isA<HapticManager>());
    });

    test('analyticsServiceProvider can be overridden', () {
      final container = ProviderContainer(
        overrides: [
          analyticsServiceProvider.overrideWithValue(AnalyticsService()),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(analyticsServiceProvider);
      expect(service, isA<AnalyticsService>());
    });

    test('remoteRepositoryProvider can be overridden', () {
      final container = ProviderContainer(
        overrides: [
          remoteRepositoryProvider.overrideWithValue(RemoteRepository()),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(remoteRepositoryProvider);
      expect(repo, isA<RemoteRepository>());
    });

    test('adManagerProvider can be overridden', () {
      final container = ProviderContainer(
        overrides: [
          adManagerProvider.overrideWithValue(AdManager()),
        ],
      );
      addTearDown(container.dispose);

      final manager = container.read(adManagerProvider);
      expect(manager, isA<AdManager>());
    });

    test('audioManagerProvider can be overridden via overrideWith', () {
      // AudioManager() triggers AudioPlayer platform channels; use
      // overrideWith to verify the provider accepts an override.
      final container = ProviderContainer(
        overrides: [
          audioManagerProvider.overrideWith((ref) => AudioManager()),
        ],
      );
      addTearDown(container.dispose);

      final manager = container.read(audioManagerProvider);
      expect(manager, isA<AudioManager>());
    });

    // Note: purchaseServiceProvider override test is intentionally omitted.
    // PurchaseService() eagerly accesses InAppPurchase.instance which starts
    // an async Android billing connection that fails in the test runner.
    // The type verification test above confirms the provider definition.
  });

  // ─── Singleton consistency ────────────────────────────────────────────────
  // Factory constructors in these services return the static _instance field.
  // Reading the provider twice from the same container must yield the same
  // object reference.

  group('singleton consistency', () {
    test('hapticManagerProvider returns singleton instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final a = container.read(hapticManagerProvider);
      final b = container.read(hapticManagerProvider);
      expect(identical(a, b), isTrue);
    });

    test('analyticsServiceProvider returns singleton instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final a = container.read(analyticsServiceProvider);
      final b = container.read(analyticsServiceProvider);
      expect(identical(a, b), isTrue);
    });

    test('remoteRepositoryProvider returns singleton instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final a = container.read(remoteRepositoryProvider);
      final b = container.read(remoteRepositoryProvider);
      expect(identical(a, b), isTrue);
    });

    test('adManagerProvider returns singleton instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final a = container.read(adManagerProvider);
      final b = container.read(adManagerProvider);
      expect(identical(a, b), isTrue);
    });
  });
}
