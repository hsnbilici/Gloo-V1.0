import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/audio/haptic_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // HapticManager uses HapticFeedback (SystemChannels.platform).
  // In test environment we mock the platform channel to capture calls.

  group('HapticProfile enum', () {
    test('has exactly 14 profiles', () {
      expect(HapticProfile.values.length, 14);
    });

    test('contains all expected base profiles', () {
      final names = HapticProfile.values.map((p) => p.name).toSet();
      expect(names, contains('gelPlace'));
      expect(names, contains('gelMergeSmall'));
      expect(names, contains('gelMergeLarge'));
      expect(names, contains('comboEpic'));
      expect(names, contains('levelComplete'));
      expect(names, contains('buttonTap'));
    });

    test('contains all phase-4 profiles', () {
      final names = HapticProfile.values.map((p) => p.name).toSet();
      expect(names, contains('powerupActivate'));
      expect(names, contains('iceBreak'));
      expect(names, contains('gravityDrop'));
      expect(names, contains('rainbowMerge'));
      expect(names, contains('levelCompleteNew'));
      expect(names, contains('bombExplosion'));
      expect(names, contains('pvpObstacleReceived'));
      expect(names, contains('pvpObstacleSent'));
    });

    test('profile names are unique', () {
      final names = HapticProfile.values.map((p) => p.name).toList();
      expect(names.toSet().length, names.length);
    });
  });

  group('HapticManager singleton', () {
    test('factory constructor returns the same instance', () {
      final a = HapticManager();
      final b = HapticManager();
      expect(identical(a, b), isTrue);
    });
  });

  group('HapticManager enabled/disabled', () {
    late HapticManager manager;

    setUp(() {
      manager = HapticManager();
      manager.setEnabled(true);
    });

    test('trigger returns immediately when disabled (no throw)', () async {
      manager.setEnabled(false);
      // Should not invoke any platform calls
      await manager.trigger(HapticProfile.gelPlace);
    });

    test(
      'trigger does not throw for any profile when disabled',
      () async {
        manager.setEnabled(false);
        for (final profile in HapticProfile.values) {
          await manager.trigger(profile);
        }
      },
    );
  });

  group('HapticManager trigger with mocked platform channel', () {
    late HapticManager manager;
    final List<String> hapticCalls = [];

    setUp(() {
      manager = HapticManager();
      manager.setEnabled(true);
      hapticCalls.clear();

      // Mock the SystemChannels.platform to record haptic calls
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        hapticCalls.add(call.method);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('gelPlace triggers lightImpact', () async {
      await manager.trigger(HapticProfile.gelPlace);
      expect(hapticCalls, contains('HapticFeedback.vibrate'));
    });

    test('gelMergeSmall triggers lightImpact', () async {
      await manager.trigger(HapticProfile.gelMergeSmall);
      expect(hapticCalls, contains('HapticFeedback.vibrate'));
    });

    test('gelMergeLarge triggers mediumImpact', () async {
      await manager.trigger(HapticProfile.gelMergeLarge);
      expect(hapticCalls, contains('HapticFeedback.vibrate'));
    });

    test('buttonTap triggers selectionClick', () async {
      await manager.trigger(HapticProfile.buttonTap);
      expect(hapticCalls, contains('HapticFeedback.vibrate'));
    });

    test('disabled manager does not produce any platform calls', () async {
      manager.setEnabled(false);
      await manager.trigger(HapticProfile.gelPlace);
      expect(hapticCalls, isEmpty);
    });

    test('re-enabling produces platform calls again', () async {
      manager.setEnabled(false);
      await manager.trigger(HapticProfile.gelPlace);
      expect(hapticCalls, isEmpty);

      manager.setEnabled(true);
      await manager.trigger(HapticProfile.gelPlace);
      expect(hapticCalls, isNotEmpty);
    });
  });
}
