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
    await _haptic.trigger(HapticProfile.gelPlace);
  }

  Future<void> onGelMerge({required int mergeCount}) async {
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
    if (combo.tier == ComboTier.epic) {
      await _haptic.trigger(HapticProfile.comboEpic);
    }
  }

  Future<void> onGameOver() async {
    await _audio.playSfx(AudioPaths.gameOver);
    await _haptic.trigger(HapticProfile.comboEpic);
  }

  Future<void> onLevelComplete() async {
    await _haptic.trigger(HapticProfile.levelComplete);
  }
}
