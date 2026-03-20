import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/ui_constants.dart';

/// Kombo veya guclu olaylarda kisa sureli ekran sarsintisi uygular.
/// [child] widget'ini saran Transform.translate ile calisir.
class ScreenShake extends StatefulWidget {
  const ScreenShake({
    super.key,
    required this.child,
    required this.intensity,
    this.duration = AnimationDurations.medium,
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
    this.baseColor = kGreen,
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
  late _AmbientDropletPainter _painter;

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

    _painter = _AmbientDropletPainter(
      repaint: _ctrl,
      droplets: _droplets,
      baseColor: widget.baseColor,
    );
  }

  @override
  void didUpdateWidget(AmbientGelDroplets oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseColor != widget.baseColor) {
      _painter = _AmbientDropletPainter(
        repaint: _ctrl,
        droplets: _droplets,
        baseColor: widget.baseColor,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _painter,
        child: const SizedBox.expand(),
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
  _AmbientDropletPainter({
    required Animation<double> repaint,
    required this.droplets,
    required this.baseColor,
  })  : _animation = repaint,
        _glowPaint = Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        _blobPaint = Paint(),
        _highlightPaint = Paint(),
        super(repaint: repaint);

  final Animation<double> _animation;
  final List<_DropletData> droplets;
  final Color baseColor;
  final Paint _glowPaint;
  final Paint _blobPaint;
  final Paint _highlightPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final time = _animation.value;
    for (final d in droplets) {
      final t = time * 2 * math.pi;
      // Yuzme hareketi: sinusoidal dalga + yavas drift
      final x =
          ((d.x + d.speedX * time * 20 + math.sin(t + d.phase) * 0.02) % 1.0) *
              size.width;
      final y =
          ((d.y + d.speedY * time * 20 + math.cos(t * 0.7 + d.phase) * 0.015) %
                  1.0) *
              size.height;

      // Nefes alma boyut degisimi
      final breathScale = 1.0 + math.sin(t * 1.3 + d.phase) * 0.2;
      final r = d.radius * breathScale;

      // Glow
      _glowPaint.color = baseColor.withValues(alpha: d.opacity * 0.3);
      canvas.drawCircle(Offset(x, y), r * 2.5, _glowPaint);

      // Jel blob
      _blobPaint.color = baseColor.withValues(alpha: d.opacity);
      canvas.drawCircle(Offset(x, y), r, _blobPaint);

      // Specular highlight
      _highlightPaint.color = Colors.white.withValues(alpha: d.opacity * 0.6);
      canvas.drawCircle(
          Offset(x - r * 0.25, y - r * 0.25), r * 0.35, _highlightPaint);
    }
  }

  @override
  bool shouldRepaint(_AmbientDropletPainter old) =>
      old.droplets != droplets || old.baseColor != baseColor;
}
