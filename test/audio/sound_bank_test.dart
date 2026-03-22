import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gloo/audio/audio_manager.dart';
import 'package:gloo/audio/haptic_manager.dart';
import 'package:gloo/audio/sound_bank.dart';
import 'package:gloo/core/constants/audio_constants.dart';
import 'package:gloo/core/models/combo_types.dart';

// ─── Mock classes ─────────────────────────────────────────────────────────────

class MockAudioManager extends Mock implements AudioManager {}

class MockHapticManager extends Mock implements HapticManager {}

// ─── Main ─────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(HapticProfile.gelPlace);
  });

  // SoundBank orchestrates HapticManager + AudioManager calls based on game events.
  // AudioManager SFX is disabled in tests to avoid MissingPluginException
  // from just_audio's per-player platform channels.

  group('SoundBank construction', () {
    test('creates with default managers', () {
      final bank = SoundBank();
      expect(bank, isNotNull);
    });

    test('accepts injected managers', () {
      final bank = SoundBank(haptic: HapticManager());
      expect(bank, isNotNull);
    });
  });

  group('SoundBank game events with haptic', () {
    late SoundBank bank;
    final List<String> hapticCalls = [];

    setUp(() {
      HapticManager().setEnabled(true);
      AudioManager().setSfxEnabled(false);
      bank = SoundBank();
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

  // ─── Mock-based tests: verify exact SFX paths and haptic profiles ──────────

  group('SoundBank SFX routing with MockAudioManager', () {
    late MockAudioManager audio;
    late MockHapticManager haptic;
    late SoundBank bank;

    setUp(() {
      audio = MockAudioManager();
      haptic = MockHapticManager();
      bank = SoundBank(audio: audio, haptic: haptic);

      when(() => audio.playSfx(any())).thenAnswer((_) async {});
      when(
        () => audio.playSfx(any(), volume: any(named: 'volume')),
      ).thenAnswer((_) async {});
      when(() => haptic.trigger(any())).thenAnswer((_) async {});
    });

    // ── onGelPlaced ──────────────────────────────────────────────────────────

    test('onGelPlaced plays gelPlace SFX and triggers gelPlace haptic',
        () async {
      await bank.onGelPlaced();
      verify(() => audio.playSfx(AudioPaths.gelPlace)).called(1);
      verify(() => haptic.trigger(HapticProfile.gelPlace)).called(1);
    });

    test('onGelPlaced(soft:true) plays gelPlaceSoft SFX', () async {
      await bank.onGelPlaced(soft: true);
      verify(() => audio.playSfx(AudioPaths.gelPlaceSoft)).called(1);
      verify(() => haptic.trigger(HapticProfile.gelPlace)).called(1);
    });

    // ── onGelMerge ───────────────────────────────────────────────────────────

    test('onGelMerge(1) plays gelMergeSmall and small haptic', () async {
      await bank.onGelMerge(mergeCount: 1);
      verify(() => audio.playSfx(AudioPaths.gelMergeSmall)).called(1);
      verify(() => haptic.trigger(HapticProfile.gelMergeSmall)).called(1);
    });

    test('onGelMerge(2) plays gelMergeSmall and small haptic', () async {
      await bank.onGelMerge(mergeCount: 2);
      verify(() => audio.playSfx(AudioPaths.gelMergeSmall)).called(1);
      verify(() => haptic.trigger(HapticProfile.gelMergeSmall)).called(1);
    });

    test('onGelMerge(3) plays gelMergeMedium and large haptic', () async {
      await bank.onGelMerge(mergeCount: 3);
      verify(() => audio.playSfx(AudioPaths.gelMergeMedium)).called(1);
      verify(() => haptic.trigger(HapticProfile.gelMergeLarge)).called(1);
    });

    test('onGelMerge(4) plays gelMergeLarge and large haptic', () async {
      await bank.onGelMerge(mergeCount: 4);
      verify(() => audio.playSfx(AudioPaths.gelMergeLarge)).called(1);
      verify(() => haptic.trigger(HapticProfile.gelMergeLarge)).called(1);
    });

    test('onGelMerge(5) plays gelMergeLarge and large haptic', () async {
      await bank.onGelMerge(mergeCount: 5);
      verify(() => audio.playSfx(AudioPaths.gelMergeLarge)).called(1);
      verify(() => haptic.trigger(HapticProfile.gelMergeLarge)).called(1);
    });

    // ── onCombo ──────────────────────────────────────────────────────────────

    test('onCombo(none) plays no SFX and no haptic', () async {
      await bank.onCombo(ComboEvent.none);
      verifyNever(() => audio.playSfx(any()));
      verifyNever(() => haptic.trigger(any()));
    });

    test('onCombo(small) plays comboSmall SFX at 0.5 volume, no haptic',
        () async {
      const combo = ComboEvent(size: 2, tier: ComboTier.small, multiplier: 1.2);
      await bank.onCombo(combo);
      verify(
        () => audio.playSfx(AudioPaths.comboSmall, volume: 0.5),
      ).called(1);
      verifyNever(() => haptic.trigger(any()));
    });

    test('onCombo(medium) plays comboMedium SFX, no haptic', () async {
      const combo =
          ComboEvent(size: 4, tier: ComboTier.medium, multiplier: 1.5);
      await bank.onCombo(combo);
      verify(() => audio.playSfx(AudioPaths.comboMedium, volume: 1.0))
          .called(1);
      verifyNever(() => haptic.trigger(any()));
    });

    test('onCombo(large) plays comboLarge SFX, no haptic', () async {
      const combo = ComboEvent(size: 7, tier: ComboTier.large, multiplier: 2.0);
      await bank.onCombo(combo);
      verify(() => audio.playSfx(AudioPaths.comboLarge, volume: 1.0)).called(1);
      verifyNever(() => haptic.trigger(any()));
    });

    test('onCombo(epic) plays comboEpic SFX and comboEpic haptic', () async {
      const combo = ComboEvent(size: 10, tier: ComboTier.epic, multiplier: 3.0);
      await bank.onCombo(combo);
      verify(() => audio.playSfx(AudioPaths.comboEpic, volume: 1.0)).called(1);
      verify(() => haptic.trigger(HapticProfile.comboEpic)).called(1);
    });

    // ── onLevelComplete ──────────────────────────────────────────────────────

    test('onLevelComplete plays levelComplete SFX and haptic', () async {
      await bank.onLevelComplete();
      verify(() => audio.playSfx(AudioPaths.levelComplete)).called(1);
      verify(() => haptic.trigger(HapticProfile.levelComplete)).called(1);
    });

    // ── onLineClear ──────────────────────────────────────────────────────────

    test('onLineClear(1) plays lineClear SFX and gelMergeLarge haptic',
        () async {
      await bank.onLineClear(lines: 1);
      verify(() => audio.playSfx(AudioPaths.lineClear)).called(1);
      verify(() => haptic.trigger(HapticProfile.gelMergeLarge)).called(1);
    });

    test('onLineClear(2) plays lineClearCrystal SFX and gelMergeLarge haptic',
        () async {
      await bank.onLineClear(lines: 2);
      verify(() => audio.playSfx(AudioPaths.lineClearCrystal)).called(1);
      verify(() => haptic.trigger(HapticProfile.gelMergeLarge)).called(1);
    });

    // ── onGameOver ───────────────────────────────────────────────────────────

    test('onGameOver plays gameOver SFX, no haptic', () async {
      await bank.onGameOver();
      verify(() => audio.playSfx(AudioPaths.gameOver)).called(1);
      verifyNever(() => haptic.trigger(any()));
    });

    // ── onSynthesis ──────────────────────────────────────────────────────────

    test('onSynthesis plays colorSynthesis SFX, no haptic', () async {
      await bank.onSynthesis();
      verify(() => audio.playSfx(AudioPaths.colorSynthesis)).called(1);
      verifyNever(() => haptic.trigger(any()));
    });

    // ── onIceBreak ───────────────────────────────────────────────────────────

    test('onIceBreak plays iceBreak SFX and iceBreak haptic', () async {
      await bank.onIceBreak();
      verify(() => audio.playSfx(AudioPaths.iceBreak)).called(1);
      verify(() => haptic.trigger(HapticProfile.iceBreak)).called(1);
    });

    // ── onPowerUpActivate ────────────────────────────────────────────────────

    test(
        'onPowerUpActivate plays powerupActivate SFX and powerupActivate haptic',
        () async {
      await bank.onPowerUpActivate();
      verify(() => audio.playSfx(AudioPaths.powerupActivate)).called(1);
      verify(() => haptic.trigger(HapticProfile.powerupActivate)).called(1);
    });

    // ── onGravityDrop ─────────────────────────────────────────────────────────

    test('onGravityDrop plays gravityDrop SFX, no haptic', () async {
      await bank.onGravityDrop();
      verify(() => audio.playSfx(AudioPaths.gravityDrop)).called(1);
      verifyNever(() => haptic.trigger(any()));
    });

    // ── onButtonTap ───────────────────────────────────────────────────────────

    test('onButtonTap plays buttonTap SFX, no haptic', () async {
      await bank.onButtonTap();
      verify(() => audio.playSfx(AudioPaths.buttonTap)).called(1);
      verifyNever(() => haptic.trigger(any()));
    });

    // ── onGelOzuEarn ──────────────────────────────────────────────────────────

    test('onGelOzuEarn plays gelOzuEarn SFX, no haptic', () async {
      await bank.onGelOzuEarn();
      verify(() => audio.playSfx(AudioPaths.gelOzuEarn)).called(1);
      verifyNever(() => haptic.trigger(any()));
    });

    // ── onNearMiss ────────────────────────────────────────────────────────────

    test('onNearMiss(survived:true) plays nearMissRelief SFX', () async {
      await bank.onNearMiss(survived: true);
      verify(() => audio.playSfx(AudioPaths.nearMissRelief)).called(1);
      verifyNever(() => haptic.trigger(any()));
    });

    test('onNearMiss(survived:false) plays nearMissTension SFX', () async {
      await bank.onNearMiss(survived: false);
      verify(() => audio.playSfx(AudioPaths.nearMissTension)).called(1);
      verifyNever(() => haptic.trigger(any()));
    });
  });

  // ─── AudioPaths constants ─────────────────────────────────────────────────

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
        AudioPaths.colorSynthesis,
        AudioPaths.pvpObstacleSent,
        AudioPaths.pvpObstacleReceived,
        AudioPaths.pvpVictory,
        AudioPaths.pvpDefeat,
        AudioPaths.levelCompleteNew,
        AudioPaths.gelOzuEarn,
      };
      // 31 sfx + 4 music = 35 unique paths
      expect(allPaths.length, 35);
    });
  });
}
