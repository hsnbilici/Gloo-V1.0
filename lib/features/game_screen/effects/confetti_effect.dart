import 'dart:math';

import 'package:flutter/material.dart';

/// Tam ekran konfeti patlama efekti — yeni yuksek skor kazanildiginda oynatilir.
///
/// 40 dikdortgen parcacik yukari firlatilip yercekim ile duserken opakligi
/// azalarak solar. Animasyon bitince [onDismiss] callback'i cagirilir.
class ConfettiEffect extends StatefulWidget {
  const ConfettiEffect({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2500);

  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(40, (_) => _Particle(rng));

    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) widget.onDismiss();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      );
}

// ─── Parcacik modeli ────────────────────────────────────────────────────────

const List<Color> _kConfettiColors = [
  Color(0xFFFF6B6B),
  Color(0xFF4ECDC4),
  Color(0xFFFFE66D),
  Color(0xFFA8E6CF),
  Color(0xFFFF8A5C),
  Color(0xFF6C5CE7),
  Color(0xFFFF85A1),
  Color(0xFF00D2FF),
];

class _Particle {
  _Particle(Random rng)
      : x = rng.nextDouble(),
        vx = (rng.nextDouble() - 0.5) * 0.6,
        vy = -(0.6 + rng.nextDouble() * 0.8),
        width = 6 + rng.nextDouble() * 8,
        height = 4 + rng.nextDouble() * 6,
        rotation = rng.nextDouble() * pi * 2,
        rotationSpeed = (rng.nextDouble() - 0.5) * pi * 6,
        color = _kConfettiColors[rng.nextInt(_kConfettiColors.length)];

  /// Normalise horizontal start position [0, 1].
  final double x;

  /// Horizontal drift per second (normalised screen width).
  final double vx;

  /// Vertical velocity — negative = upward (normalised screen height / s).
  final double vy;

  final double width;
  final double height;
  final double rotation;
  final double rotationSpeed;
  final Color color;
}

// ─── Painter ────────────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  final List<_Particle> particles;
  final double progress;

  /// Gravity acceleration in normalised screen heights per second squared.
  static const double _gravity = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2.5; // seconds elapsed (duration = 2.5 s)
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final paint = Paint();

    for (final p in particles) {
      // Simple kinematic: y(t) = vy*t + 0.5*gravity*t^2
      final nx = p.x + p.vx * t;
      final ny = 0.15 + p.vy * t + 0.5 * _gravity * t * t;
      final px = nx * size.width;
      final py = ny * size.height;

      // Skip particles that have left the visible area.
      if (py > size.height + 20 || px < -20 || px > size.width + 20) continue;

      final angle = p.rotation + p.rotationSpeed * t;
      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.width, height: p.height),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress || old.particles != particles;
}
