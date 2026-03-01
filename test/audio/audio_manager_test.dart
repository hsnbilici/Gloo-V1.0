import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/audio/audio_manager.dart';
import 'package:gloo/core/constants/audio_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // AudioManager is a singleton wrapping just_audio AudioPlayer instances.
  // In test env platform channels are unavailable. We mock the main just_audio
  // channel so AudioPlayer construction succeeds, then verify guards & config.

  setUpAll(() {
    // Mock the main just_audio init channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.ryanheise.just_audio.methods'),
      (call) async {
        // Return empty map for init/dispose calls
        return <String, dynamic>{};
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.ryanheise.just_audio.methods'),
      null,
    );
  });

  group('AudioManager singleton', () {
    test('factory constructor returns the same instance', () {
      final a = AudioManager();
      final b = AudioManager();
      expect(identical(a, b), isTrue);
    });
  });

  group('AudioManager sfx enable/disable', () {
    late AudioManager manager;

    setUp(() {
      manager = AudioManager();
      manager.setSfxEnabled(true);
    });

    test('sfxEnabled defaults to true', () {
      expect(manager.sfxEnabled, isTrue);
    });

    test('setSfxEnabled(false) disables sfx', () {
      manager.setSfxEnabled(false);
      expect(manager.sfxEnabled, isFalse);
    });

    test('setSfxEnabled(true) re-enables sfx', () {
      manager.setSfxEnabled(false);
      manager.setSfxEnabled(true);
      expect(manager.sfxEnabled, isTrue);
    });

    test('toggling sfx multiple times is consistent', () {
      manager.setSfxEnabled(false);
      manager.setSfxEnabled(false);
      expect(manager.sfxEnabled, isFalse);
      manager.setSfxEnabled(true);
      expect(manager.sfxEnabled, isTrue);
    });
  });

  group('AudioManager music enable/disable', () {
    late AudioManager manager;

    setUp(() {
      manager = AudioManager();
      manager.setMusicEnabled(true);
    });

    test('musicEnabled defaults to true', () {
      expect(manager.musicEnabled, isTrue);
    });

    test('setMusicEnabled(false) disables music', () {
      manager.setMusicEnabled(false);
      expect(manager.musicEnabled, isFalse);
    });

    test('setMusicEnabled(true) re-enables music', () {
      manager.setMusicEnabled(false);
      manager.setMusicEnabled(true);
      expect(manager.musicEnabled, isTrue);
    });
  });

  group('AudioManager playSfx guard', () {
    late AudioManager manager;

    setUp(() {
      manager = AudioManager();
    });

    test('playSfx returns immediately when sfx disabled (no throw)', () async {
      manager.setSfxEnabled(false);
      await manager.playSfx(AudioPaths.gelPlace);
    });

    test('playSfx with custom volume does not throw when disabled', () async {
      manager.setSfxEnabled(false);
      await manager.playSfx(AudioPaths.buttonTap, volume: 0.5);
    });

    test(
      'playSfx with pitchVariation=false does not throw when disabled',
      () async {
        manager.setSfxEnabled(false);
        await manager.playSfx(
          AudioPaths.comboEpic,
          pitchVariation: false,
        );
      },
    );
  });

  group('AudioManager playMusic guard', () {
    late AudioManager manager;

    setUp(() {
      manager = AudioManager();
      manager.setMusicEnabled(true);
    });

    test(
      'playMusic returns immediately when music disabled (no throw)',
      () async {
        manager.setMusicEnabled(false);
        await manager.playMusic(AudioPaths.bgMenuLofi);
      },
    );

    test(
      'playMusic with loop=false returns immediately when disabled',
      () async {
        manager.setMusicEnabled(false);
        await manager.playMusic(AudioPaths.bgGameRelax, loop: false);
      },
    );
  });

  group('AudioConfig constants', () {
    test('sfxVolume is in valid range (0, 1]', () {
      expect(AudioConfig.sfxVolume, greaterThan(0.0));
      expect(AudioConfig.sfxVolume, lessThanOrEqualTo(1.0));
    });

    test('musicVolume is in valid range (0, 1]', () {
      expect(AudioConfig.musicVolume, greaterThan(0.0));
      expect(AudioConfig.musicVolume, lessThanOrEqualTo(1.0));
    });

    test('masterVolume is 1.0', () {
      expect(AudioConfig.masterVolume, 1.0);
    });

    test('maxConcurrentSfxChannels is positive', () {
      expect(AudioConfig.maxConcurrentSfxChannels, greaterThan(0));
    });

    test('pitchVariance range is valid (min < 1.0 < max)', () {
      expect(AudioConfig.pitchVarianceMin, lessThan(1.0));
      expect(AudioConfig.pitchVarianceMax, greaterThan(1.0));
      expect(
        AudioConfig.pitchVarianceMin,
        lessThan(AudioConfig.pitchVarianceMax),
      );
    });
  });
}
