import 'dart:async';

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
  Timer? _duckTimer;

  /// Müzik volume'unu geçici olarak düşür (ducking).
  void _duckMusic({Duration duration = const Duration(milliseconds: 500)}) {
    _duckTimer?.cancel();
    _audio.setMusicVolume(AudioConfig.musicVolume * 0.5);
    _duckTimer = Timer(duration, () {
      _audio.setMusicVolume(AudioConfig.musicVolume);
    });
  }

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

  Future<void> onLineClear({required int lines, double? pitch}) async {
    await _audio.playSfx(
      lines >= 2 ? AudioPaths.lineClearCrystal : AudioPaths.lineClear,
      speed: pitch,
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
      _duckMusic();
    } else if (combo.tier == ComboTier.large) {
      await _haptic.trigger(HapticProfile.gelMergeLarge);
      _duckMusic();
    }
  }

  Future<void> onGameOver() async {
    await _audio.playSfx(AudioPaths.gameOver);
    await _haptic.trigger(HapticProfile.gelMergeLarge);
  }

  Future<void> onLevelComplete() async {
    await _audio.playSfx(AudioPaths.levelComplete);
    await _haptic.trigger(HapticProfile.levelComplete);
  }

  Future<void> onSynthesis() async {
    await _audio.playSfx(AudioPaths.colorSynthesis);
    await _haptic.trigger(HapticProfile.rainbowMerge);
  }

  Future<void> onIceBreak() async {
    await _audio.playSfx(AudioPaths.iceBreak);
    await _haptic.trigger(HapticProfile.iceBreak);
  }

  Future<void> onStoneBroken() async {
    await _audio.playSfx(AudioPaths.bombExplosion);
    await _haptic.trigger(HapticProfile.iceBreak);
  }

  Future<void> onPowerUpActivate() async {
    await _audio.playSfx(AudioPaths.powerupActivate);
    await _haptic.trigger(HapticProfile.powerupActivate);
  }

  Future<void> onGravityDrop() async {
    await _audio.playSfx(AudioPaths.gravityDrop);
    await _haptic.trigger(HapticProfile.gravityDrop);
  }

  Future<void> onButtonTap() async {
    await _audio.playSfx(AudioPaths.buttonTap);
    await _haptic.trigger(HapticProfile.buttonTap);
  }

  Future<void> onGelOzuEarn() async {
    await _audio.playSfx(AudioPaths.gelOzuEarn);
  }

  Future<void> onNearMiss({required bool survived}) async {
    await _audio.playSfx(
      survived ? AudioPaths.nearMissRelief : AudioPaths.nearMissTension,
    );
    if (survived) {
      await _haptic.trigger(HapticProfile.gelMergeSmall);
    } else {
      await _haptic.trigger(HapticProfile.gelMergeLarge);
    }
  }

  Future<void> onBombExplosion() async {
    await _audio.playSfx(AudioPaths.bombExplosion);
    await _haptic.trigger(HapticProfile.bombExplosion);
    _duckMusic();
  }

  Future<void> onRotate() async {
    await _audio.playSfx(AudioPaths.rotateClick);
    await _haptic.trigger(HapticProfile.powerupActivate);
  }

  Future<void> onUndo() async {
    await _audio.playSfx(AudioPaths.undoWhoosh);
    await _haptic.trigger(HapticProfile.powerupActivate);
  }

  Future<void> onFreeze() async {
    await _audio.playSfx(AudioPaths.freezeChime);
    await _haptic.trigger(HapticProfile.powerupActivate);
  }

  Future<void> onPvpVictory() async {
    await _audio.playSfx(AudioPaths.pvpVictory);
    await _haptic.trigger(HapticProfile.levelCompleteNew);
  }

  Future<void> onPvpDefeat() async {
    await _audio.playSfx(AudioPaths.pvpDefeat);
    await _haptic.trigger(HapticProfile.gelMergeLarge);
  }

  Future<void> onPvpObstacleSent() async {
    await _audio.playSfx(AudioPaths.pvpObstacleSent);
    await _haptic.trigger(HapticProfile.pvpObstacleSent);
  }

  // ─── Drag-and-drop ──────────────────────────────────────────────────

  Future<void> onDragStart() async {
    await _haptic.trigger(HapticProfile.dragStart);
  }

  Future<void> onDragSnap() async {
    await _haptic.trigger(HapticProfile.dragSnap);
  }

  Future<void> onDragInvalid() async {
    await _audio.playSfx(AudioPaths.nearMissTension, volume: 0.3);
    await _haptic.trigger(HapticProfile.dragInvalid);
  }

  Future<void> onPvpObstacleReceived() async {
    await _audio.playSfx(AudioPaths.pvpObstacleReceived);
    await _haptic.trigger(HapticProfile.pvpObstacleReceived);
  }
}
