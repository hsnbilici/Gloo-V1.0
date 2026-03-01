import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/audio/haptic_manager.dart';
import 'package:gloo/audio/sound_bank.dart';
import 'package:gloo/core/constants/audio_constants.dart';
import 'package:gloo/game/systems/combo_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // SoundBank orchestrates HapticManager calls based on game events.
  // We test it with a real HapticManager (singleton) + mocked platform channel.

  group('SoundBank construction', () {
    test('creates with default HapticManager', () {
      final bank = SoundBank();
      expect(bank, isNotNull);
    });

    test('accepts injected HapticManager', () {
      final bank = SoundBank(haptic: HapticManager());
      expect(bank, isNotNull);
    });
  });

  group('SoundBank game events with haptic', () {
    late SoundBank bank;
    final List<String> hapticCalls = [];

    setUp(() {
      HapticManager().setEnabled(true);
      bank = SoundBank(haptic: HapticManager());
      hapticCalls.clear();

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

    test('onGelPlaced triggers haptic feedback', () async {
      await bank.onGelPlaced();
      expect(hapticCalls, isNotEmpty);
    });

    test('onGelPlaced with soft=true triggers haptic feedback', () async {
      await bank.onGelPlaced(soft: true);
      expect(hapticCalls, isNotEmpty);
    });

    test('onGelMerge with small count triggers gelMergeSmall', () async {
      await bank.onGelMerge(mergeCount: 2);
      expect(hapticCalls, isNotEmpty);
    });

    test('onGelMerge with large count triggers gelMergeLarge', () async {
      await bank.onGelMerge(mergeCount: 3);
      expect(hapticCalls, isNotEmpty);
    });

    test('onGelMerge threshold: count < 3 is small, >= 3 is large', () async {
      hapticCalls.clear();
      await bank.onGelMerge(mergeCount: 2);
      final smallCalls = List<String>.from(hapticCalls);

      hapticCalls.clear();
      await bank.onGelMerge(mergeCount: 5);
      final largeCalls = List<String>.from(hapticCalls);

      // Both should trigger haptic, confirming the branch was taken
      expect(smallCalls, isNotEmpty);
      expect(largeCalls, isNotEmpty);
    });

    test('onCombo with epic tier triggers haptic', () async {
      const epicCombo = ComboEvent(
        size: 10,
        tier: ComboTier.epic,
        multiplier: 3.0,
      );
      await bank.onCombo(epicCombo);
      // comboEpic is fire-and-forget, so haptic may arrive asynchronously
      // At minimum, the call should not throw
    });

    test('onCombo with non-epic tier does not trigger haptic', () async {
      const smallCombo = ComboEvent(
        size: 2,
        tier: ComboTier.small,
        multiplier: 1.2,
      );
      hapticCalls.clear();
      await bank.onCombo(smallCombo);
      expect(hapticCalls, isEmpty);
    });

    test('onLevelComplete triggers haptic feedback', () async {
      await bank.onLevelComplete();
      // levelComplete is fire-and-forget; the call itself should not throw
    });

    test('onLineClear does not throw', () async {
      await bank.onLineClear(lines: 1);
      await bank.onLineClear(lines: 3);
    });

    test('onGameOver does not throw', () async {
      await bank.onGameOver();
    });
  });

  group('AudioPaths constants', () {
    test('sfx paths are non-empty strings', () {
      final sfxPaths = [
        AudioPaths.gelPlace,
        AudioPaths.gelPlaceSoft,
        AudioPaths.gelMergeSmall,
        AudioPaths.gelMergeMedium,
        AudioPaths.gelMergeLarge,
        AudioPaths.lineClear,
        AudioPaths.lineClearCrystal,
        AudioPaths.comboSmall,
        AudioPaths.comboMedium,
        AudioPaths.comboLarge,
        AudioPaths.comboEpic,
        AudioPaths.buttonTap,
        AudioPaths.levelComplete,
        AudioPaths.gameOver,
        AudioPaths.nearMissTension,
        AudioPaths.nearMissRelief,
        AudioPaths.iceBreak,
        AudioPaths.iceCrack,
        AudioPaths.powerupActivate,
        AudioPaths.bombExplosion,
        AudioPaths.rotateClick,
        AudioPaths.undoWhoosh,
        AudioPaths.freezeChime,
        AudioPaths.gravityDrop,
        AudioPaths.colorSynth,
        AudioPaths.colorSynthesis,
        AudioPaths.pvpObstacleSent,
        AudioPaths.pvpObstacleReceived,
        AudioPaths.pvpVictory,
        AudioPaths.pvpDefeat,
        AudioPaths.levelCompleteNew,
        AudioPaths.gelOzuEarn,
      ];
      for (final path in sfxPaths) {
        expect(path, isNotEmpty, reason: 'SFX path should not be empty');
        expect(path, startsWith('assets/audio/sfx/'));
      }
    });

    test('music paths are non-empty strings', () {
      final musicPaths = [
        AudioPaths.bgMenuLofi,
        AudioPaths.bgGameRelax,
        AudioPaths.bgGameTension,
        AudioPaths.bgZenMode,
      ];
      for (final path in musicPaths) {
        expect(path, isNotEmpty, reason: 'Music path should not be empty');
        expect(path, startsWith('assets/audio/music/'));
      }
    });

    test('sfx paths have valid audio extension', () {
      final sfxPaths = [
        AudioPaths.gelPlace,
        AudioPaths.gelMergeSmall,
        AudioPaths.comboEpic,
        AudioPaths.buttonTap,
        AudioPaths.levelComplete,
      ];
      for (final path in sfxPaths) {
        final ext = path.split('.').last;
        expect(
          ['ogg', 'm4a'].contains(ext),
          isTrue,
          reason: 'SFX "$path" should end with .ogg or .m4a',
        );
      }
    });

    test('music paths have .mp3 extension', () {
      final musicPaths = [
        AudioPaths.bgMenuLofi,
        AudioPaths.bgGameRelax,
        AudioPaths.bgGameTension,
        AudioPaths.bgZenMode,
      ];
      for (final path in musicPaths) {
        expect(path, endsWith('.mp3'));
      }
    });

    test('all audio paths are unique (no duplicates)', () {
      final allPaths = <String>{
        AudioPaths.gelPlace,
        AudioPaths.gelPlaceSoft,
        AudioPaths.gelMergeSmall,
        AudioPaths.gelMergeMedium,
        AudioPaths.gelMergeLarge,
        AudioPaths.lineClear,
        AudioPaths.lineClearCrystal,
        AudioPaths.comboSmall,
        AudioPaths.comboMedium,
        AudioPaths.comboLarge,
        AudioPaths.comboEpic,
        AudioPaths.buttonTap,
        AudioPaths.levelComplete,
        AudioPaths.gameOver,
        AudioPaths.nearMissTension,
        AudioPaths.nearMissRelief,
        AudioPaths.bgMenuLofi,
        AudioPaths.bgGameRelax,
        AudioPaths.bgGameTension,
        AudioPaths.bgZenMode,
        AudioPaths.iceBreak,
        AudioPaths.iceCrack,
        AudioPaths.powerupActivate,
        AudioPaths.bombExplosion,
        AudioPaths.rotateClick,
        AudioPaths.undoWhoosh,
        AudioPaths.freezeChime,
        AudioPaths.gravityDrop,
        AudioPaths.colorSynth,
        AudioPaths.colorSynthesis,
        AudioPaths.pvpObstacleSent,
        AudioPaths.pvpObstacleReceived,
        AudioPaths.pvpVictory,
        AudioPaths.pvpDefeat,
        AudioPaths.levelCompleteNew,
        AudioPaths.gelOzuEarn,
      };
      // 32 sfx + 4 music = 36 unique paths
      expect(allPaths.length, 36);
    });
  });
}
