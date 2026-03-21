import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/services/consent_service.dart';

/// Method channel used by user_messaging_platform plugin.
const _kChannel = 'com.terwesten.gabriel/user_messaging_platform';

/// Sets up method channel mock for UMP plugin.
/// Returns Map<String, String> with enum name strings (plugin protocol).
void _setUpUmpChannel({
  required String consentStatus,
  required String formStatus,
  String? formResultConsentStatus,
}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(_kChannel),
    (MethodCall call) async {
      switch (call.method) {
        case 'requestConsentInfoUpdate':
          return <String, String>{
            'consentStatus': consentStatus,
            'formStatus': formStatus,
          };
        case 'showConsentForm':
          return <String, String>{
            'consentStatus': formResultConsentStatus ?? consentStatus,
            'formStatus': 'unavailable',
          };
        case 'resetConsentInfo':
          return null;
        default:
          return null;
      }
    },
  );
}

/// Sets up method channel that always throws PlatformException.
void _setUpUmpChannelError() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(_kChannel),
    (MethodCall call) async {
      throw PlatformException(
        code: 'ERROR',
        message: 'UMP SDK unavailable',
      );
    },
  );
}

void _clearUmpChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel(_kChannel), null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ConsentService service;

  setUp(() async {
    service = ConsentService();
    // Reset singleton via mock channel
    _setUpUmpChannel(
      consentStatus: 'unknown',
      formStatus: 'unavailable',
    );
    await service.reset();
  });

  tearDown(() {
    _clearUmpChannel();
  });

  group('ConsentService', () {
    test('singleton returns same instance', () {
      final a = ConsentService();
      final b = ConsentService();
      expect(identical(a, b), isTrue);
    });

    test('canShowAds is false after reset', () {
      expect(service.canShowAds, isFalse);
    });

    test('initialize sets canShowAds true when consent obtained', () async {
      _setUpUmpChannel(
        consentStatus: 'obtained',
        formStatus: 'unavailable',
      );

      await service.initialize();

      expect(service.canShowAds, isTrue);
    });

    test('initialize sets canShowAds true when consent not required', () async {
      _setUpUmpChannel(
        consentStatus: 'notRequired',
        formStatus: 'unavailable',
      );

      await service.initialize();

      expect(service.canShowAds, isTrue);
    });

    test('initialize sets canShowAds false when consent required', () async {
      _setUpUmpChannel(
        consentStatus: 'required',
        formStatus: 'unavailable',
      );

      await service.initialize();

      expect(service.canShowAds, isFalse);
    });

    test('initialize sets canShowAds false when consent unknown', () async {
      _setUpUmpChannel(
        consentStatus: 'unknown',
        formStatus: 'unavailable',
      );

      await service.initialize();

      expect(service.canShowAds, isFalse);
    });

    test('initialize shows consent form when available and user grants',
        () async {
      _setUpUmpChannel(
        consentStatus: 'required',
        formStatus: 'available',
        formResultConsentStatus: 'obtained',
      );

      await service.initialize();

      expect(service.canShowAds, isTrue);
    });

    test('canShowAds false when user denies consent form', () async {
      _setUpUmpChannel(
        consentStatus: 'required',
        formStatus: 'available',
        formResultConsentStatus: 'required',
      );

      await service.initialize();

      expect(service.canShowAds, isFalse);
    });

    test('initialize does not throw on platform error', () async {
      _setUpUmpChannelError();

      await expectLater(service.initialize(), completes);
      expect(service.canShowAds, isFalse);
    });

    test('initialize is idempotent — second call is no-op', () async {
      _setUpUmpChannel(
        consentStatus: 'obtained',
        formStatus: 'unavailable',
      );

      await service.initialize();
      expect(service.canShowAds, isTrue);

      // Change channel to return "required" — but init should skip
      _setUpUmpChannel(
        consentStatus: 'required',
        formStatus: 'unavailable',
      );

      await service.initialize();
      // Should still be true because second init was skipped
      expect(service.canShowAds, isTrue);
    });

    test('showConsentForm updates canShowAds', () async {
      _setUpUmpChannel(
        consentStatus: 'unknown',
        formStatus: 'unavailable',
        formResultConsentStatus: 'obtained',
      );

      expect(service.canShowAds, isFalse);
      await service.showConsentForm();
      expect(service.canShowAds, isTrue);
    });

    test('showConsentForm handles error gracefully', () async {
      _setUpUmpChannelError();

      await expectLater(service.showConsentForm(), completes);
    });

    test('showConsentForm keeps canShowAds false when denied', () async {
      _setUpUmpChannel(
        consentStatus: 'unknown',
        formStatus: 'unavailable',
        formResultConsentStatus: 'required',
      );

      await service.showConsentForm();
      expect(service.canShowAds, isFalse);
    });

    test('reset clears canShowAds and allows re-initialization', () async {
      _setUpUmpChannel(
        consentStatus: 'obtained',
        formStatus: 'unavailable',
      );

      await service.initialize();
      expect(service.canShowAds, isTrue);

      await service.reset();
      expect(service.canShowAds, isFalse);

      // Re-initialize with notRequired
      _setUpUmpChannel(
        consentStatus: 'notRequired',
        formStatus: 'unavailable',
      );

      await service.initialize();
      expect(service.canShowAds, isTrue);
    });

    test('service remains usable after initialize error', () async {
      _setUpUmpChannelError();
      await service.initialize();
      expect(service.canShowAds, isFalse);

      // Reset, then retry with working channel
      _setUpUmpChannel(
        consentStatus: 'unknown',
        formStatus: 'unavailable',
      );
      await service.reset();

      _setUpUmpChannel(
        consentStatus: 'obtained',
        formStatus: 'unavailable',
      );
      await service.initialize();
      expect(service.canShowAds, isTrue);
    });
  });
}
