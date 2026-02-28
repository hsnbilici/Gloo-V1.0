import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Kombo veya guclu olaylarda kisa sureli ekran sarsintisi uygular.
/// [child] widget'ini saran Transform.translate ile calisir.
class ScreenShake extends StatefulWidget {
  const ScreenShake({
    super.key,
    required this.child,
    required this.intensity,
    this.duration = const Duration(milliseconds: 300),
  });

  final Widget child;
  /// Sarsinti yogunlugu (piksel): epic=4, large=2.
  final double intensity;
  final Duration duration;

  @override
  State<ScreenShake> createState() => _ScreenShakeState();
}

class _ScreenShakeState extends State<ScreenShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final decay = 1.0 - _ctrl.value;
        final dx = (_rng.nextDouble() - 0.5) * 2 * widget.intensity * decay;
        final dy = (_rng.nextDouble() - 0.5) * 2 * widget.intensity * decay;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: widget.child,
        );
      },
    );
  }
}

// ─── Ortam Yuzucu Jel Damlaciklari ─────────────────────────────────

/// Arka planda yavasca hareket eden dekoratif jel parcaciklari.
class AmbientGelDroplets extends StatefulWidget {
  const AmbientGelDroplets({
    super.key,
    this.count = 10,
    this.baseColor = const Color(0xFF3CFF8B),
    this.speedFactor = 1.0,
  });

  final int count;
  final Color baseColor;
  final double speedFactor;

  @override
  State<AmbientGelDroplets> createState() => _AmbientGelDropletsState();
}

class _AmbientGelDropletsState extends State<AmbientGelDroplets>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_DropletData> _droplets;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final rng = math.Random(42);
    _droplets = List.generate(widget.count, (i) {
      return _DropletData(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 3.0 + rng.nextDouble() * 5.0,
        speedX: (rng.nextDouble() - 0.5) * 0.008 * widget.speedFactor,
        speedY: (rng.nextDouble() - 0.5) * 0.006 * widget.speedFactor,
        phase: rng.nextDouble() * 2 * math.pi,
        opacity: 0.06 + rng.nextDouble() * 0.08,
        hueShift: (rng.nextDouble() - 0.5) * 40,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _AmbientDropletPainter(
              time: _ctrl.value,
              droplets: _droplets,
              baseColor: widget.baseColor,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _DropletData {
  _DropletData({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.phase,
    required this.opacity,
    required this.hueShift,
  });

  final double x;
  final double y;
  final double radius;
  final double speedX;
  final double speedY;
  final double phase;
  final double opacity;
  final double hueShift;
}

class _AmbientDropletPainter extends CustomPainter {
  const _AmbientDropletPainter({
    required this.time,
    required this.droplets,
    required this.baseColor,
  });

  final double time;
  final List<_DropletData> droplets;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in droplets) {
      final t = time * 2 * math.pi;
      // Yuzme hareketi: sinusoidal dalga + yavas drift
      final x = ((d.x + d.speedX * time * 20 + math.sin(t + d.phase) * 0.02) % 1.0) *
          size.width;
      final y = ((d.y + d.speedY * time * 20 + math.cos(t * 0.7 + d.phase) * 0.015) %
              1.0) *
          size.height;

      // Nefes alma boyut degisimi
      final breathScale = 1.0 + math.sin(t * 1.3 + d.phase) * 0.2;
      final r = d.radius * breathScale;

      // Glow
      canvas.drawCircle(
        Offset(x, y),
        r * 2.5,
        Paint()
          ..color = baseColor.withValues(alpha: d.opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Jel blob
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = baseColor.withValues(alpha: d.opacity),
      );

      // Specular highlight
      canvas.drawCircle(
        Offset(x - r * 0.25, y - r * 0.25),
        r * 0.35,
        Paint()..color = Colors.white.withValues(alpha: d.opacity * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientDropletPainter old) => old.time != time;
}
