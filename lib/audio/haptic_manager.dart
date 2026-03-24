import 'package:flutter/services.dart';

enum HapticProfile {
  gelPlace,
  gelMergeSmall,
  gelMergeLarge,
  comboEpic,
  levelComplete,
  buttonTap,

  // Faz 4 — yeni profiller
  powerupActivate,
  iceBreak,
  gravityDrop,
  rainbowMerge,
  levelCompleteNew,
  bombExplosion,
  pvpObstacleReceived,
  pvpObstacleSent,

  // Drag-and-drop profilleri
  dragStart,
  dragSnap,
  dragInvalid,
}

class HapticManager {
  static final HapticManager _instance = HapticManager._();
  factory HapticManager() => _instance;
  HapticManager._();

  bool _enabled = true;

  void setEnabled(bool value) => _enabled = value;

  /// Haptic sekansını ateşle-ve-unut: çağıran bloke olmaz.
  // ignore: avoid_void_async
  static void _fireAndForget(Future<void> Function() sequence) {
    sequence(); // intentionally not awaited
  }

  Future<void> trigger(HapticProfile profile) async {
    if (!_enabled) return;

    switch (profile) {
      // ─── Tek vuruşlar — anında döner ────────────────────────────────────
      case HapticProfile.gelPlace:
      case HapticProfile.gelMergeSmall:
        await HapticFeedback.lightImpact();

      case HapticProfile.gelMergeLarge:
        await HapticFeedback.mediumImpact();

      case HapticProfile.buttonTap:
        await HapticFeedback.selectionClick();

      // ─── Çok adımlı sekanslar — fire-and-forget ─────────────────────────

      case HapticProfile.comboEpic:
        _fireAndForget(() async {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.heavyImpact();
        });

      case HapticProfile.levelComplete:
        _fireAndForget(() async {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.lightImpact();
        });

      // ─── Faz 4 profilleri ─────────────────────────────────────────────────

      case HapticProfile.powerupActivate:
        _fireAndForget(() async {
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 80));
          await HapticFeedback.lightImpact();
        });

      case HapticProfile.iceBreak:
        _fireAndForget(() async {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 50));
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 50));
          await HapticFeedback.lightImpact();
        });

      case HapticProfile.gravityDrop:
        _fireAndForget(() async {
          for (int i = 0; i < 3; i++) {
            await HapticFeedback.lightImpact();
            if (i < 2) {
              await Future.delayed(const Duration(milliseconds: 60));
            }
          }
        });

      case HapticProfile.rainbowMerge:
        _fireAndForget(() async {
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.heavyImpact();
        });

      case HapticProfile.levelCompleteNew:
        _fireAndForget(() async {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 200));
          await HapticFeedback.heavyImpact();
        });

      case HapticProfile.bombExplosion:
        _fireAndForget(() async {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 60));
          await HapticFeedback.heavyImpact();
        });

      case HapticProfile.pvpObstacleReceived:
        _fireAndForget(() async {
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 80));
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 80));
          await HapticFeedback.mediumImpact();
        });

      case HapticProfile.pvpObstacleSent:
        _fireAndForget(() async {
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 120));
          await HapticFeedback.mediumImpact();
        });

      // ─── Drag-and-drop profilleri ─────────────────────────────────────────

      case HapticProfile.dragStart:
        await HapticFeedback.selectionClick();

      case HapticProfile.dragSnap:
        await HapticFeedback.lightImpact();

      case HapticProfile.dragInvalid:
        _fireAndForget(() async {
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 60));
          await HapticFeedback.mediumImpact();
        });
    }
  }
}
