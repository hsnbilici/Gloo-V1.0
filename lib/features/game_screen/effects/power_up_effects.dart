import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/utils/motion_utils.dart';

/// Power-up kullanildiginda gosterilen parilti efekti.
class PowerUpActivateEffect extends StatefulWidget {
  const PowerUpActivateEffect({
    super.key,
    required this.color,
    required this.onDismiss,
  });

  final Color color;
  final VoidCallback onDismiss;

  @override
  State<PowerUpActivateEffect> createState() => _PowerUpActivateEffectState();
}

class _PowerUpActivateEffectState extends State<PowerUpActivateEffect> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldReduceMotion(context)) return const SizedBox.shrink();

    return ExcludeSemantics(
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withValues(alpha: 0.0),
                  widget.color.withValues(alpha: 0.3),
                  widget.color.withValues(alpha: 0.0),
                ],
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(3.0, 3.0),
                duration: 600.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(delay: 400.ms, duration: 400.ms),
        ),
      ),
    );
  }
}

// ─── Bomb patlama efekti ──────────────────────────────────────────────

/// 3x3 bomb temizlemede gosterilen patlama efekti.
class BombExplosionEffect extends StatefulWidget {
  const BombExplosionEffect({
    super.key,
    required this.cellSize,
    required this.onDismiss,
  });

  final double cellSize;
  final VoidCallback onDismiss;

  @override
  State<BombExplosionEffect> createState() => _BombExplosionEffectState();
}

class _BombExplosionEffectState extends State<BombExplosionEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AnimationDurations.explosion,
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) widget.onDismiss();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldReduceMotion(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDismiss();
      });
      return const SizedBox.shrink();
    }

    final size = widget.cellSize * 6.0;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _BombPainter(
              progress: _ctrl.value,
              cellSize: widget.cellSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _BombPainter extends CustomPainter {
  const _BombPainter({
    required this.progress,
    required this.cellSize,
  });

  final double progress;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final center = Offset(size.width / 2, size.height / 2);

    // Sok dalgasi -- genisleyen turuncu halka
    final shockEased = Curves.easeOutCubic.transform(progress.clamp(0, 1));
    final shockRadius = cellSize * 3.0 * shockEased;
    final shockOpacity = (1.0 - shockEased) * 0.6;

    canvas.drawCircle(
      center,
      shockRadius,
      Paint()
        ..color = kAmberDark.withValues(alpha: shockOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - shockEased) * 4 + 0.5,
    );

    // Merkez patlama -- beyaz -> turuncu gradyan
    if (progress < 0.4) {
      final t = progress / 0.4;
      final radius = cellSize * 2.0 * Curves.easeOut.transform(t);
      final opacity = (1.0 - t) * 0.8;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: opacity),
              kAmberDark.withValues(alpha: opacity * 0.5),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    // Kivilcimlar
    if (progress > 0.1 && progress < 0.9) {
      final sparkT = ((progress - 0.1) / 0.8).clamp(0.0, 1.0);
      const sparkCount = 12;
      for (int i = 0; i < sparkCount; i++) {
        final angle = (i / sparkCount) * 2 * math.pi;
        final dist = cellSize * 2.5 * sparkT;
        final sparkX = math.cos(angle) * dist;
        final sparkY =
            math.sin(angle) * dist + sparkT * sparkT * cellSize * 0.4;
        final sparkSize = cellSize * 0.12 * (1.0 - sparkT);
        if (sparkSize <= 0) continue;
        final opacity = (1.0 - sparkT * sparkT) * 0.9;

        canvas.drawCircle(
          center.translate(sparkX, sparkY),
          sparkSize,
          Paint()..color = kGold.withValues(alpha: opacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BombPainter old) => old.progress != progress;
}

// ─── Undo geri sarma efekti ────────────────────────────────────────────

/// Undo kullanildiginda geri alinan hucrelerde amber halka + beyaz parlama.
class UndoRewindEffect extends StatefulWidget {
  const UndoRewindEffect({
    super.key,
    required this.cells,
    required this.cellSize,
    required this.gridGap,
    required this.onDismiss,
  });

  final List<(int, int)> cells;
  final double cellSize;
  final double gridGap;
  final VoidCallback onDismiss;

  @override
  State<UndoRewindEffect> createState() => _UndoRewindEffectState();
}

class _UndoRewindEffectState extends State<UndoRewindEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldReduceMotion(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDismiss();
      });
      return const SizedBox.shrink();
    }

    return ExcludeSemantics(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _UndoRewindPainter(
              progress: _ctrl.value,
              cells: widget.cells,
              cellSize: widget.cellSize,
              gridGap: widget.gridGap,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _UndoRewindPainter extends CustomPainter {
  const _UndoRewindPainter({
    required this.progress,
    required this.cells,
    required this.cellSize,
    required this.gridGap,
  });

  final double progress;
  final List<(int, int)> cells;
  final double cellSize;
  final double gridGap;

  static const _kAmberColor = kAmber;
  static const _kAmberGlow = kAmberGlow;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || cells.isEmpty) return;

    final step = cellSize + gridGap;

    for (final (row, col) in cells) {
      final cx = col * step + cellSize / 2;
      final cy = row * step + cellSize / 2;

      final eased = Curves.easeOutCubic.transform(progress);
      final maxRadius = cellSize * 0.8;
      final radius = maxRadius * eased;
      final opacity = (1.0 - eased) * 0.85;

      // Amber glow halkasi
      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()
          ..color = _kAmberGlow.withValues(alpha: opacity * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1.0 - eased) * 3.5 + 0.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Keskin amber halka
      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()
          ..color = _kAmberColor.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1.0 - eased) * 2.5 + 0.3,
      );

      // Beyaz merkez parlama
      if (progress < 0.5) {
        final flashT = progress / 0.5;
        final flashOpacity =
            flashT < 0.4 ? flashT * 2.5 : (1.0 - flashT) * 1.67;
        canvas.drawCircle(
          Offset(cx, cy),
          cellSize * 0.35 * flashT,
          Paint()
            ..color = Colors.white
                .withValues(alpha: flashOpacity.clamp(0.0, 1.0) * 0.7)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_UndoRewindPainter old) => old.progress != progress;
}
