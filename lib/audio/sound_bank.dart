import '../core/constants/audio_constants.dart';
import '../core/models/combo_types.dart';
import 'audio_manager.dart';
import 'haptic_manager.dart';

class SoundBank {
  SoundBank({AudioManager? audio, HapticManager? haptic})
      : _audio = audio ?? AudioManager(),
        _haptic = haptic ?? HapticManager();

  final AudioManager _audio;
  final HapticManager _haptic;

  Future<void> onGelPlaced({bool soft = false}) async {
    await _audio.playSfx(soft ? AudioPaths.gelPlaceSoft : AudioPaths.gelPlace);
    await _haptic.trigger(HapticProfile.gelPlace);
  }

  Future<void> onGelMerge({required int mergeCount}) async {
    final sfx = switch (mergeCount) {
      >= 4 => AudioPaths.gelMergeLarge,
      >= 3 => AudioPaths.gelMergeMedium,
      _ => AudioPaths.gelMergeSmall,
    };
    await _audio.playSfx(sfx);
    final haptic = mergeCount >= 3
        ? HapticProfile.gelMergeLarge
        : HapticProfile.gelMergeSmall;
    await _haptic.trigger(haptic);
  }

  Future<void> onLineClear({required int lines}) async {
    await _audio.playSfx(
      lines >= 2 ? AudioPaths.lineClearCrystal : AudioPaths.lineClear,
    );
    await _haptic.trigger(HapticProfile.gelMergeLarge);
  }

  Future<void> onCombo(ComboEvent combo) async {
    final sfx = switch (combo.tier) {
      ComboTier.small => AudioPaths.comboSmall,
      ComboTier.medium => AudioPaths.comboMedium,
      ComboTier.large => AudioPaths.comboLarge,
      ComboTier.epic => AudioPaths.comboEpic,
      ComboTier.none => null,
    };
    if (sfx != null) {
      final volume = combo.tier == ComboTier.small ? 0.5 : 1.0;
      await _audio.playSfx(sfx, volume: volume);
    }
    if (combo.tier == ComboTier.epic) {
      await _haptic.trigger(HapticProfile.comboEpic);
    }
  }

  Future<void> onGameOver() async {
    await _audio.playSfx(AudioPaths.gameOver);
  }

  Future<void> onLevelComplete() async {
    await _audio.playSfx(AudioPaths.levelComplete);
    await _haptic.trigger(HapticProfile.levelComplete);
  }

  Future<void> onSynthesis() async {
    await _audio.playSfx(AudioPaths.colorSynthesis);
  }

  Future<void> onIceBreak() async {
    await _audio.playSfx(AudioPaths.iceBreak);
    await _haptic.trigger(HapticProfile.iceBreak);
  }

  Future<void> onPowerUpActivate() async {
    await _audio.playSfx(AudioPaths.powerupActivate);
    await _haptic.trigger(HapticProfile.powerupActivate);
  }

  Future<void> onGravityDrop() async {
    await _audio.playSfx(AudioPaths.gravityDrop);
  }

  Future<void> onButtonTap() async {
    await _audio.playSfx(AudioPaths.buttonTap);
  }

  Future<void> onGelOzuEarn() async {
    await _audio.playSfx(AudioPaths.gelOzuEarn);
  }

  Future<void> onNearMiss({required bool survived}) async {
    await _audio.playSfx(
      survived ? AudioPaths.nearMissRelief : AudioPaths.nearMissTension,
    );
  }
}
