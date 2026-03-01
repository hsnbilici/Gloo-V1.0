import '../game/systems/combo_detector.dart';
import 'haptic_manager.dart';

class SoundBank {
  SoundBank({HapticManager? haptic}) : _haptic = haptic ?? HapticManager();

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

  Future<void> onLineClear({required int lines}) async {}

  Future<void> onCombo(ComboEvent combo) async {
    if (combo.tier == ComboTier.epic) {
      await _haptic.trigger(HapticProfile.comboEpic);
    }
  }

  Future<void> onGameOver() async {}

  Future<void> onLevelComplete() async {
    await _haptic.trigger(HapticProfile.levelComplete);
  }
}
