import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

// ─── Yeni rekor rozeti ───────────────────────────────────────────────────────

class NewRecordBadge extends StatelessWidget {
  const NewRecordBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(UIConstants.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Score count-up ──────────────────────────────────────────────────────────

class ScoreCountUp extends StatelessWidget {
  const ScoreCountUp({super.key, required this.score, required this.color});

  final int score;
  final Color color;

  static String _fmt(int val) {
    if (val >= 10000) return '${(val / 1000).toStringAsFixed(1)}K';
    if (val >= 1000) {
      final k = val / 1000;
      final s = k.toStringAsFixed(1);
      return '${s.endsWith('.0') ? k.toInt() : s}K';
    }
    return '$val';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: score),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (_, val, __) => Text(
        _fmt(val),
        style: TextStyle(
          color: Colors.white,
          fontSize: 82,
          fontWeight: FontWeight.w900,
          letterSpacing: -3,
          height: 1,
          shadows: [
            Shadow(
              color: color.withValues(alpha: 0.65),
              blurRadius: 36,
            ),
            Shadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 80,
            ),
          ],
        ),
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 360.ms);
  }
}

// ─── Mod rozeti ──────────────────────────────────────────────────────────────

class GameOverModeBadge extends StatelessWidget {
  const GameOverModeBadge(
      {super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        border: Border.all(color: color.withValues(alpha: 0.38), width: 1),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 3.5,
        ),
      ),
    );
  }
}

// ─── Parıldayan ayraç ───────────────────────────────────────────────────────

class GlowDivider extends StatelessWidget {
  const GlowDivider({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, color, Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusXxs),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.7),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ─── İstatistik satırı ──────────────────────────────────────────────────────

class GameOverStatRow extends StatelessWidget {
  const GameOverStatRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
