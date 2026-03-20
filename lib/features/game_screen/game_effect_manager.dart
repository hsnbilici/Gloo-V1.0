import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';

/// Centralized animation controller management for GameScreen.
/// Owns shared controllers and provides factory methods for transient effects.
class GameEffectManager {
  GameEffectManager(this._vsync) {
    breathCtrl = AnimationController(
      vsync: _vsync,
      duration: AnimationDurations.breathCycle,
    )..repeat();
  }

  final TickerProvider _vsync;
  late final AnimationController breathCtrl;

  /// Create a transient controller for short-lived effects.
  /// Caller is responsible for disposal.
  AnimationController createTransient({
    required Duration duration,
    double? lowerBound,
    double? upperBound,
  }) {
    return AnimationController(
      vsync: _vsync,
      duration: duration,
      lowerBound: lowerBound ?? 0.0,
      upperBound: upperBound ?? 1.0,
    );
  }

  void dispose() {
    breathCtrl.dispose();
  }
}
