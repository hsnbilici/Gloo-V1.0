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
}

class HapticManager {
  static final HapticManager _instance = HapticManager._();
  factory HapticManager() => _instance;
  HapticManager._();

  bool _enabled = true;

  void setEnabled(bool value) => _enabled = value;

  Future<void> trigger(HapticProfile profile) async {
    if (!_enabled) return;

    switch (profile) {
      case HapticProfile.gelPlace:
      case HapticProfile.gelMergeSmall:
        await HapticFeedback.lightImpact();

      case HapticProfile.gelMergeLarge:
        await HapticFeedback.mediumImpact();

      case HapticProfile.comboEpic:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();

      case HapticProfile.levelComplete:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.lightImpact();

      case HapticProfile.buttonTap:
        await HapticFeedback.selectionClick();

      // ─── Faz 4 profilleri ─────────────────────────────────────────────────

      case HapticProfile.powerupActivate:
        // Medium + delay + light
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.lightImpact();

      case HapticProfile.iceBreak:
        // Heavy + 2× (light + delay) — "çatırdama" hissi
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();

      case HapticProfile.gravityDrop:
        // 3× (light + delay) — "tok tok tok" düşüş hissi
        for (int i = 0; i < 3; i++) {
          await HapticFeedback.lightImpact();
          if (i < 2) await Future.delayed(const Duration(milliseconds: 60));
        }

      case HapticProfile.rainbowMerge:
        // Crescendo: light → medium → heavy
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();

      case HapticProfile.levelCompleteNew:
        // Heavy → medium → light → heavy (victory pattern)
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.heavyImpact();

      case HapticProfile.bombExplosion:
        // Heavy + heavy (çift darbe)
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.heavyImpact();

      case HapticProfile.pvpObstacleReceived:
        // Uyarı: medium + light + medium
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.mediumImpact();

      case HapticProfile.pvpObstacleSent:
        // Tatmin: light + delay + medium
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.mediumImpact();
    }
  }
}
