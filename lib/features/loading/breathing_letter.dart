import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';

/// A single jel (gel) letter tile for the loading screen.
///
/// Renders a rounded-rect gel capsule with a linear gradient, specular
/// highlight and glow shadow. Optionally breathes via a sinusoidal scale
/// driven by [breathController].
class BreathingLetter extends StatelessWidget {
  const BreathingLetter({
    required this.letter,
    required this.color,
    required this.phase,
    this.animate = true,
    this.breathController,
    super.key,
  });

  /// The single character to display.
  final String letter;

  /// The gel accent colour for this tile.
  final Color color;

  /// Phase offset in radians for the breathing sinusoid.
  final double phase;

  /// When false the tile is rendered statically (reduce-motion or no controller).
  final bool animate;

  /// External [AnimationController] that drives the 0→1 breath cycle.
  final AnimationController? breathController;

  // ─── Layout constants ──────────────────────────────────────────────────────
  static const double _width = 52.0;
  static const double _height = 60.0;
  static const double _radius = 10.0;

  // ─── Specular constants ────────────────────────────────────────────────────
  static const double _specW = 14.0;
  static const double _specH = 6.0;
  static const double _specTop = 6.0;
  static const double _specLeft = 10.0;
  static const double _specAlpha = 0.45;

  // ─── Shadow constants ──────────────────────────────────────────────────────
  static const double _glowBlur = 16.0;
  static const double _glowSpread = 2.0;
  static const double _glowAlpha = 0.35;
  static const double _dropBlur = 6.0;
  static const Offset _dropOffset = Offset(0, 3);
  static const double _dropAlpha = 0.2;

  // ─── Typography ────────────────────────────────────────────────────────────
  static const double _fontSize = 32.0;

  // ─── Breathing ─────────────────────────────────────────────────────────────
  static const double _breathAmplitude = 0.025;

  /// Darkens [base] by [amount] (0.0–1.0).
  Color _darken(Color base, double amount) {
    final r = ((base.r * 255).round() * (1 - amount)).round().clamp(0, 255);
    final g = ((base.g * 255).round() * (1 - amount)).round().clamp(0, 255);
    final b = ((base.b * 255).round() * (1 - amount)).round().clamp(0, 255);
    return Color.fromARGB(255, r, g, b);
  }

  Widget _buildTile() {
    final darker = _darken(color, 0.30);

    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, darker],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: _glowAlpha),
            blurRadius: _glowBlur,
            spreadRadius: _glowSpread,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: _dropAlpha),
            blurRadius: _dropBlur,
            offset: _dropOffset,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Specular highlight
          Positioned(
            top: _specTop,
            left: _specLeft,
            child: Container(
              width: _specW,
              height: _specH,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _specAlpha),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          // Letter
          Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontSize: _fontSize,
                fontWeight: FontWeight.w900,
                color: kBgDark,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tile = _buildTile();

    if (!animate || breathController == null) {
      return tile;
    }

    return AnimatedBuilder(
      animation: breathController!,
      builder: (_, __) {
        final t = breathController!.value;
        final scale = 1.0 + sin(t * 2 * pi + phase) * _breathAmplitude;
        return Transform.scale(scale: scale, child: tile);
      },
    );
  }
}
