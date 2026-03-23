import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/utils/motion_utils.dart';

/// Satir/sutun temizlendiginde her hucrenin uzerinde oynayan jel patlamasi.
/// [delay] ile stagger uygulanir; efekt bitince [onDismiss] cagrilir.
class CellBurstEffect extends StatefulWidget {
  const CellBurstEffect({
    super.key,
    required this.color,
    required this.cellSize,
    required this.delay,
    required this.onDismiss,
    this.intensity = 1.0,
  });

  final Color color;
  final double cellSize;
  final Duration delay;
  final VoidCallback onDismiss;

  /// Efekt yoğunluğu — parçacık sayısını ve yayılma mesafesini çarpar.
  /// 1.0 = tek satır (16 parçacık), 1.5 = 2+ satır, 2.0 = 4+ satır (maks 32).
  final double intensity;

  @override
  State<CellBurstEffect> createState() => _CellBurstEffectState();
}

class _CellBurstEffectState extends State<CellBurstEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AnimationDurations.cellBurst,
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) widget.onDismiss();
    });
    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
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

    final size = widget.cellSize * 4.0;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _BurstPainter(
              progress: _ctrl.value,
              color: widget.color,
              cellSize: widget.cellSize,
              intensity: widget.intensity,
            ),
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.color,
    required this.cellSize,
    this.intensity = 1.0,
  })  : _flashPaint = Paint(),
        _glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        _ringPaint = Paint()..style = PaintingStyle.stroke,
        _particleGlowPaint = Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        _particleBodyPaint = Paint(),
        _particleHighlightPaint = Paint();

  final double progress;
  final Color color;
  final double cellSize;
  final double intensity;

  // Faz F: 8 -> 16 parcacik, Bezier trajectory. intensity ile maks 32'ye kadar olceklenir.
  static const int _baseParticleCount = 16;
  static const int _maxParticleCount = 32;

  // Pre-allocated reusable Paint objects
  final Paint _flashPaint;
  final Paint _glowPaint;
  final Paint _ringPaint;
  final Paint _particleGlowPaint;
  final Paint _particleBodyPaint;
  final Paint _particleHighlightPaint;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Isik patlamasi (Light Flash): beyaz daire, 0->1->0 opasite, 120ms
    if (progress < 0.22) {
      final t = progress / 0.22;
      final flashOpacity = t < 0.5 ? t * 2.0 : (1.0 - t) * 2.0;
      _drawFlash(canvas, center, flashOpacity);
    }

    // 2. Dalga halka efekti (Ripple Ring): 0->2x boyut, stroke azalma
    if (progress < 0.68) {
      final t = progress / 0.68;
      _drawRing(canvas, center, t);
    }

    // 3. Jel damlacik parcaciklari: Bezier egrisi trajectory + yercekimi
    if (progress > 0.06) {
      final t = (progress - 0.06) / 0.94;
      final count = (_baseParticleCount * intensity)
          .round()
          .clamp(_baseParticleCount, _maxParticleCount);
      _drawParticles(canvas, center, t, count);
    }
  }

  void _drawFlash(Canvas canvas, Offset center, double opacity) {
    // Faz 4: 1.5x hucre boyutu (eskiden 0.85x); intensity ile hafifce buyur
    final radius = cellSize * 1.5 * (1.0 + (intensity - 1.0) * 0.25);
    _flashPaint.shader = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: opacity * 0.92),
        color.withValues(alpha: opacity * 0.65),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, _flashPaint);
  }

  void _drawRing(Canvas canvas, Offset center, double t) {
    final eased = Curves.easeOutCubic.transform(t);
    // Faz 4: 2x boyut genisleme
    final radius = cellSize * 0.42 + cellSize * 1.8 * eased;
    final opacity = (1.0 - eased) * 0.80;
    // Faz 4: Stroke width 3->0.5 azalma
    final strokeW = (1.0 - eased) * 3.0 + 0.5;

    // Glow katmani
    _glowPaint
      ..color = color.withValues(alpha: opacity * 0.45)
      ..strokeWidth = strokeW + 4.0;
    canvas.drawCircle(center, radius, _glowPaint);

    // Keskin halka
    _ringPaint
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = strokeW;
    canvas.drawCircle(center, radius, _ringPaint);
  }

  void _drawParticles(Canvas canvas, Offset center, double t, int count) {
    final eased = Curves.easeOut.transform(t);
    // intensity ile yayılma mesafesini artır (max +35%)
    final maxDist = cellSize * 1.65 * (1.0 + (intensity - 1.0) * 0.35);

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi;
      // Faz F: Bezier egrisi trajectory -- kontrol noktasi ile kavisli yol
      final controlAngle = angle + (i.isEven ? 0.4 : -0.4);
      final controlDist = maxDist * 0.5;
      final endDx = math.cos(angle) * maxDist;
      final endDy = math.sin(angle) * maxDist;
      final ctrlDx = math.cos(controlAngle) * controlDist;
      final ctrlDy = math.sin(controlAngle) * controlDist;
      // Quadratic Bezier: P(t) = (1-t)^2*P0 + 2*(1-t)*t*P1 + t^2*P2
      final bt = eased;
      final omt = 1.0 - bt;
      final dx = 2 * omt * bt * ctrlDx + bt * bt * endDx;
      final dy = 2 * omt * bt * ctrlDy + bt * bt * endDy;
      // Yercekimi: y += t^2 * 0.3
      final gravity = t * t * cellSize * 0.3;
      final posX = center.dx + dx;
      final posY = center.dy + dy + gravity;

      // Faz 4: Boyut 3-8px araliginda varyasyon
      final sizeVariation = 0.24 + (i % 3) * 0.06;
      final particleSize = cellSize * sizeVariation * (1.0 - t * t);
      if (particleSize <= 0) continue;

      // Faz 4: Karesel opasite azalmasi (quadratic decay)
      final opacity = (1.0 - t * t) * 0.95;

      final halfSize = particleSize / 2;
      final cornerRadius = Radius.circular(particleSize * 0.38);
      final rrect = RRect.fromLTRBR(
        posX - halfSize,
        posY - halfSize,
        posX + halfSize,
        posY + halfSize,
        cornerRadius,
      );

      // Glow
      _particleGlowPaint.color = color.withValues(alpha: opacity * 0.42);
      canvas.drawRRect(rrect, _particleGlowPaint);

      // Jel blob govdesi
      _particleBodyPaint.color = color.withValues(alpha: opacity);
      canvas.drawRRect(rrect, _particleBodyPaint);

      // Ic highlight
      final hlSize = particleSize * 0.38;
      final hlHalf = hlSize / 2;
      final hlX = posX - particleSize * 0.12;
      final hlY = posY - particleSize * 0.12;
      final hlCorner = Radius.circular(hlSize * 0.5);
      _particleHighlightPaint.color =
          Colors.white.withValues(alpha: opacity * 0.55);
      canvas.drawRRect(
        RRect.fromLTRBR(
          hlX - hlHalf,
          hlY - hlHalf,
          hlX + hlHalf,
          hlY + hlHalf,
          hlCorner,
        ),
        _particleHighlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      old.progress != progress || old.intensity != intensity;
}

// ─── Buz kirilma efekti ───────────────────────────────────────────────

/// Buz hucresi kirildignda gosterilen parcalanma efekti.
class IceBreakEffect extends StatefulWidget {
  const IceBreakEffect({
    super.key,
    required this.cellSize,
    required this.delay,
    required this.onDismiss,
  });

  final double cellSize;
  final Duration delay;
  final VoidCallback onDismiss;

  @override
  State<IceBreakEffect> createState() => _IceBreakEffectState();
}

class _IceBreakEffectState extends State<IceBreakEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) widget.onDismiss();
    });
    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
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

    final size = widget.cellSize * 3.0;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _IceBreakPainter(
              progress: _ctrl.value,
              cellSize: widget.cellSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _IceBreakPainter extends CustomPainter {
  const _IceBreakPainter({
    required this.progress,
    required this.cellSize,
  });

  final double progress;
  final double cellSize;

  static const _kShardCount = 8;
  static const _kIceColor = kIceColor;
  static const _kIceHighlight = kIceHighlight;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final eased = Curves.easeOut.transform(progress);

    // Buz parcalari disari firliyor
    for (int i = 0; i < _kShardCount; i++) {
      final angle = (i / _kShardCount) * 2 * math.pi + 0.3;
      final dist = cellSize * 1.2 * eased;
      final dx = math.cos(angle) * dist;
      final dy = math.sin(angle) * dist + progress * progress * cellSize * 0.2;
      final pos = center.translate(dx, dy);

      final shardSize = cellSize * 0.2 * (1.0 - progress);
      if (shardSize <= 0) continue;

      final opacity = (1.0 - progress * progress) * 0.85;

      // Buz parcasi -- duzensiz dortgen
      final rotation = angle + progress * 3.0;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rotation);

      final rect = Rect.fromCenter(
          center: Offset.zero, width: shardSize * 1.4, height: shardSize);
      canvas.drawRect(
        rect,
        Paint()..color = _kIceColor.withValues(alpha: opacity),
      );
      // Parlama
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset(-shardSize * 0.15, -shardSize * 0.1),
            width: shardSize * 0.5,
            height: shardSize * 0.3),
        Paint()..color = _kIceHighlight.withValues(alpha: opacity * 0.7),
      );

      canvas.restore();
    }

    // Merkez flas
    if (progress < 0.3) {
      final flashT = progress / 0.3;
      final flashOpacity = flashT < 0.5 ? flashT * 2.0 : (1.0 - flashT) * 2.0;
      canvas.drawCircle(
        center,
        cellSize * 0.6,
        Paint()
          ..color = _kIceHighlight.withValues(alpha: flashOpacity * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(_IceBreakPainter old) => old.progress != progress;
}

// ─── Renk Sentezi Color Bloom ──────────────────────────────────────────

/// Sentez aninda merkezden disa dogru renk patlamasi.
class ColorSynthesisBloomEffect extends StatefulWidget {
  const ColorSynthesisBloomEffect({
    super.key,
    required this.color,
    required this.cellSize,
    required this.onDismiss,
  });

  final Color color;
  final double cellSize;
  final VoidCallback onDismiss;

  @override
  State<ColorSynthesisBloomEffect> createState() =>
      _ColorSynthesisBloomEffectState();
}

class _ColorSynthesisBloomEffectState extends State<ColorSynthesisBloomEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AnimationDurations.synthBloom,
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

    final size = widget.cellSize * 5.0;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _SynthesisBloomPainter(
              progress: _ctrl.value,
              color: widget.color,
              cellSize: widget.cellSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _SynthesisBloomPainter extends CustomPainter {
  const _SynthesisBloomPainter({
    required this.progress,
    required this.color,
    required this.cellSize,
  });

  final double progress;
  final Color color;
  final double cellSize;

  static const int _bloomCount = 10;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Sentez flasi -- merkezde parlak daire
    if (progress < 0.35) {
      final t = progress / 0.35;
      final eased = Curves.easeOutCubic.transform(t);
      final radius = cellSize * 1.8 * eased;
      final opacity = t < 0.5 ? t * 2.0 : (1.0 - t) * 2.0;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: opacity * 0.85),
              color.withValues(alpha: opacity * 0.55),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    // 2. Renk halkalari -- 2 genisleyen halka
    for (int ring = 0; ring < 2; ring++) {
      final ringDelay = ring * 0.12;
      final ringT =
          ((progress - ringDelay) / (1.0 - ringDelay)).clamp(0.0, 1.0);
      if (ringT <= 0) continue;

      final eased = Curves.easeOutCubic.transform(ringT);
      final radius = cellSize * (1.0 + ring * 0.5) + cellSize * 1.5 * eased;
      final opacity = (1.0 - eased) * 0.60;
      final strokeW = (1.0 - eased) * 2.5 + 0.3;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // 3. Sentez parcaciklari -- merkezden disa yayilan renkli noktalar
    if (progress > 0.08) {
      final t = ((progress - 0.08) / 0.92).clamp(0.0, 1.0);
      final eased = Curves.easeOut.transform(t);
      final maxDist = cellSize * 2.0;

      for (int i = 0; i < _bloomCount; i++) {
        final angle = (i / _bloomCount) * 2 * math.pi + 0.15;
        final dist = maxDist * eased;
        final dx = math.cos(angle) * dist;
        final dy = math.sin(angle) * dist;
        final pos = center.translate(dx, dy);

        final particleSize = cellSize * 0.18 * (1.0 - t * t);
        if (particleSize <= 0) continue;
        final opacity = (1.0 - t * t) * 0.80;

        // Renkli blob
        canvas.drawCircle(
          pos,
          particleSize,
          Paint()..color = color.withValues(alpha: opacity),
        );
        // Parlama
        canvas.drawCircle(
          pos,
          particleSize * 1.8,
          Paint()
            ..color = color.withValues(alpha: opacity * 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SynthesisBloomPainter old) => old.progress != progress;
}

// ─── Satır Sweep Efekti ────────────────────────────────────────────────────

/// Çoklu satır temizlemede (lines >= 2) satır boyunca yatay ışık süpürmesi.
/// Soldan sağa (RTL'de sağdan sola) beyaz gradient sweep, 300ms.
class LineSweepEffect extends StatefulWidget {
  const LineSweepEffect({
    super.key,
    required this.cols,
    required this.cellSize,
    required this.gap,
    required this.onDismiss,
    this.isRtl = false,
  });

  final int cols;
  final double cellSize;
  final double gap;
  final VoidCallback onDismiss;
  final bool isRtl;

  @override
  State<LineSweepEffect> createState() => _LineSweepEffectState();
}

class _LineSweepEffectState extends State<LineSweepEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AnimationDurations.lineSweep,
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

    final totalW = widget.cols * widget.cellSize + (widget.cols - 1) * widget.gap;
    final totalH = widget.cellSize;

    return ExcludeSemantics(
      child: SizedBox(
        width: totalW,
        height: totalH,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            painter: _SweepPainter(
              progress: _ctrl.value,
              totalWidth: totalW,
              cellSize: widget.cellSize,
              isRtl: widget.isRtl,
            ),
          ),
        ),
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  const _SweepPainter({
    required this.progress,
    required this.totalWidth,
    required this.cellSize,
    required this.isRtl,
  });

  final double progress;
  final double totalWidth;
  final double cellSize;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    // Sweep bandının merkez x pozisyonu: 0 → totalWidth (LTR) ya da ters (RTL)
    final sweepWidth = cellSize * 2.0;
    final eased = Curves.easeInOut.transform(progress);
    final centerX = isRtl
        ? totalWidth - eased * totalWidth
        : eased * totalWidth;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final sweepRect = Rect.fromCenter(
      center: Offset(centerX, size.height / 2),
      width: sweepWidth,
      height: size.height,
    );

    // Şeffaf → beyaz (0.4) → şeffaf gradient
    final shader = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.white.withValues(alpha: 0.40),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(sweepRect);

    canvas.clipRect(rect);
    canvas.drawRect(
      sweepRect,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_SweepPainter old) =>
      old.progress != progress || old.isRtl != isRtl;
}

// ─── Sentez Pulse ─────────────────────────────────────────────────────────

/// Sentez sonucu hucresinde tek seferlik scale pulse animasyonu oynatir.
/// [isActive] true'ya gectiginde ileri dogru calisiyor; reduce motion'da atlar.
class SynthesisPulseCell extends StatefulWidget {
  const SynthesisPulseCell({
    super.key,
    required this.isActive,
    required this.child,
  });

  final bool isActive;
  final Widget child;

  @override
  State<SynthesisPulseCell> createState() => _SynthesisPulseCellState();
}

class _SynthesisPulseCellState extends State<SynthesisPulseCell>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  AnimationController _ensureController() {
    return _ctrl ??= AnimationController(
      vsync: this,
      duration: AnimationDurations.synthesisPulse,
    );
  }

  @override
  void didUpdateWidget(SynthesisPulseCell old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ensureController().forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive || _ctrl == null) return widget.child;
    if (shouldReduceMotion(context)) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl!,
      builder: (_, __) {
        final t = _ctrl!.value;
        // 0→0.5: scale up, 0.5→1: scale down
        final curve = t < 0.5 ? t * 2 : 2 - t * 2;
        final scale = 1.0 + 0.08 * Curves.easeOutBack.transform(curve);
        return Transform.scale(scale: scale, child: widget.child);
      },
    );
  }
}
