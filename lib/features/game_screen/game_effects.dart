import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/near_miss_detector.dart';
import '../../game/systems/combo_detector.dart';
import '../../providers/locale_provider.dart';

/// Combo kazanıldığında ortada beliren animasyonlu banner.
class ComboEffect extends ConsumerStatefulWidget {
  const ComboEffect({super.key, required this.combo, required this.onDismiss});

  final ComboEvent combo;
  final VoidCallback onDismiss;

  @override
  ConsumerState<ComboEffect> createState() => _ComboEffectState();
}

class _ComboEffectState extends ConsumerState<ComboEffect> {
  @override
  void initState() {
    super.initState();
    // Toplam animasyon süresi: 350ms giriş + 750ms bekleme + 400ms çıkış = ~1500ms
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final label = switch (widget.combo.tier) {
      ComboTier.small  => l.comboSmall,
      ComboTier.medium => l.comboMedium,
      ComboTier.large  => l.comboLarge,
      ComboTier.epic   => l.comboEpic,
      ComboTier.none   => '',
    };
    final color = _tierColor(widget.combo.tier);

    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                shadows: [Shadow(color: color.withValues(alpha: 0.8), blurRadius: 24)],
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.2, 0.2),
                  end: const Offset(1.0, 1.0),
                  duration: 350.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 150.ms)
                .then(delay: 750.ms)
                .fadeOut(duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              'x${widget.combo.multiplier.toStringAsFixed(1)}',
              style: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            )
                .animate()
                .slideY(begin: 0.8, end: 0, duration: 350.ms, curve: Curves.easeOutCubic)
                .fadeIn(duration: 200.ms)
                .then(delay: 750.ms)
                .fadeOut(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Color _tierColor(ComboTier tier) => switch (tier) {
        ComboTier.small  => const Color(0xFF3CFF8B),
        ComboTier.medium => const Color(0xFFFFE03C),
        ComboTier.large  => const Color(0xFFFF7B3C),
        ComboTier.epic   => const Color(0xFFFF3B3B),
        ComboTier.none   => Colors.transparent,
      };
}

/// Parça yerleştirme geri bildirimi: kısa süreyle yukarı kayan "+N" yazısı.
class PlaceFeedbackEffect extends StatefulWidget {
  const PlaceFeedbackEffect({
    super.key,
    required this.count,
    required this.color,
    required this.onDismiss,
  });

  final int count;
  final Color color;
  final VoidCallback onDismiss;

  @override
  State<PlaceFeedbackEffect> createState() => _PlaceFeedbackEffectState();
}

class _PlaceFeedbackEffectState extends State<PlaceFeedbackEffect> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 650), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Text(
        '+${widget.count}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(color: widget.color.withValues(alpha: 0.9), blurRadius: 10),
            Shadow(color: widget.color.withValues(alpha: 0.5), blurRadius: 20),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 80.ms)
          .slideY(begin: 0, end: -3.0, duration: 650.ms, curve: Curves.easeOut)
          .fadeOut(delay: 350.ms, duration: 300.ms),
    );
  }
}

/// Near-miss tespit edildiğinde ekran kenarlarını kırmızı/turuncu titreşimle
/// uyaran ve ortada metin gösteren overlay efekti.
class NearMissEffect extends ConsumerStatefulWidget {
  const NearMissEffect({super.key, required this.event, required this.onDismiss});

  final NearMissEvent event;
  final VoidCallback onDismiss;

  @override
  ConsumerState<NearMissEffect> createState() => _NearMissEffectState();
}

class _NearMissEffectState extends ConsumerState<NearMissEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final isCritical = widget.event.isCritical;
    final color = isCritical ? const Color(0xFFFF3B3B) : const Color(0xFFFF7B3C);
    final label = isCritical ? l.nearMissCritical : l.nearMissStandard;

    return IgnorePointer(
      child: Stack(
        children: [
          // Faz F: Radyal vignette overlay
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) {
              final v = _pulseAnim.value;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color.withValues(alpha: 0.35 + 0.65 * v),
                    width: isCritical ? 4 : 3,
                  ),
                ),
                child: CustomPaint(
                  painter: _VignettePainter(
                    color: color,
                    intensity: isCritical ? 0.40 + 0.30 * v : 0.25 + 0.20 * v,
                  ),
                  child: const SizedBox.expand(),
                ),
              );
            },
          ),
          Align(
            alignment: const Alignment(0, -0.58),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isCritical ? 30 : 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
                shadows: [Shadow(color: color.withValues(alpha: 0.9), blurRadius: 20)],
              ),
            )
                .animate()
                .fadeIn(duration: 150.ms)
                .then(delay: 1500.ms)
                .fadeOut(duration: 350.ms),
          ),
        ],
      ),
    );
  }
}

// ─── Hücre patlaması ──────────────────────────────────────────────────────────

/// Satır/sütun temizlendiğinde her hücrenin üzerinde oynayan jel patlaması.
/// [delay] ile stagger uygulanır; efekt bitince [onDismiss] çağrılır.
class CellBurstEffect extends StatefulWidget {
  const CellBurstEffect({
    super.key,
    required this.color,
    required this.cellSize,
    required this.delay,
    required this.onDismiss,
  });

  final Color color;
  final double cellSize;
  final Duration delay;
  final VoidCallback onDismiss;

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
      duration: const Duration(milliseconds: 580),
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
    final size = widget.cellSize * 4.0;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _BurstPainter(
            progress: _ctrl.value,
            color: widget.color,
            cellSize: widget.cellSize,
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({
    required this.progress,
    required this.color,
    required this.cellSize,
  });

  final double progress;
  final Color color;
  final double cellSize;

  // Faz F: 8 → 16 parçacık, Bezier trajectory
  static const int _particleCount = 16;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Işık patlaması (Light Flash): beyaz daire, 0→1→0 opasite, 120ms
    if (progress < 0.22) {
      final t = progress / 0.22;
      final flashOpacity = t < 0.5 ? t * 2.0 : (1.0 - t) * 2.0;
      _drawFlash(canvas, center, flashOpacity);
    }

    // 2. Dalga halka efekti (Ripple Ring): 0→2× boyut, stroke azalma
    if (progress < 0.68) {
      final t = progress / 0.68;
      _drawRing(canvas, center, t);
    }

    // 3. Jel damlacık parçacıkları: Bezier eğrisi trajectory + yerçekimi
    if (progress > 0.06) {
      final t = (progress - 0.06) / 0.94;
      _drawParticles(canvas, center, t);
    }
  }

  void _drawFlash(Canvas canvas, Offset center, double opacity) {
    // Faz 4: 1.5× hücre boyutu (eskiden 0.85×)
    final radius = cellSize * 1.5;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: opacity * 0.92),
          color.withValues(alpha: opacity * 0.65),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _drawRing(Canvas canvas, Offset center, double t) {
    final eased = Curves.easeOutCubic.transform(t);
    // Faz 4: 2× boyut genişleme
    final radius = cellSize * 0.42 + cellSize * 1.8 * eased;
    final opacity = (1.0 - eased) * 0.80;
    // Faz 4: Stroke width 3→0.5 azalma
    final strokeW = (1.0 - eased) * 3.0 + 0.5;

    // Glow katmanı
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius, glowPaint);

    // Keskin halka
    final ringPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW;
    canvas.drawCircle(center, radius, ringPaint);
  }

  void _drawParticles(Canvas canvas, Offset center, double t) {
    final eased = Curves.easeOut.transform(t);
    final maxDist = cellSize * 1.65;

    for (int i = 0; i < _particleCount; i++) {
      final angle = (i / _particleCount) * 2 * math.pi;
      // Faz F: Bezier eğrisi trajectory — kontrol noktası ile kavisli yol
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
      // Yerçekimi: y += t^2 * 0.3
      final gravity = t * t * cellSize * 0.3;
      final pos = center.translate(dx, dy + gravity);

      // Faz 4: Boyut 3-8px aralığında varyasyon
      final sizeVariation = 0.24 + (i % 3) * 0.06;
      final particleSize = cellSize * sizeVariation * (1.0 - t * t);
      if (particleSize <= 0) continue;

      // Faz 4: Karesel opasite azalması (quadratic decay)
      final opacity = (1.0 - t * t) * 0.95;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos, width: particleSize, height: particleSize),
        Radius.circular(particleSize * 0.38),
      );

      // Glow
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = color.withValues(alpha: opacity * 0.42)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Jel blob gövdesi
      canvas.drawRRect(rrect, Paint()..color = color.withValues(alpha: opacity));

      // İç highlight
      final hlSize = particleSize * 0.38;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: pos.translate(-particleSize * 0.12, -particleSize * 0.12),
            width: hlSize,
            height: hlSize,
          ),
          Radius.circular(hlSize * 0.5),
        ),
        Paint()..color = Colors.white.withValues(alpha: opacity * 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}

// ─── Faz 4: Ekran sarsıntısı (Screen Shake) ─────────────────────────────────

/// Kombo veya güçlü olaylarda kısa süreli ekran sarsıntısı uygular.
/// [child] widget'ını saran Transform.translate ile çalışır.
class ScreenShake extends StatefulWidget {
  const ScreenShake({
    super.key,
    required this.child,
    required this.intensity,
    this.duration = const Duration(milliseconds: 300),
  });

  final Widget child;
  /// Sarsıntı yoğunluğu (piksel): epic=4, large=2.
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

// ─── Faz 4: Buz kırılma efekti ───────────────────────────────────────────────

/// Buz hücresi kırıldığında gösterilen parçalanma efekti.
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
    final size = widget.cellSize * 3.0;
    return SizedBox(
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
  static const _kIceColor = Color(0xFFB0E0FF);
  static const _kIceHighlight = Color(0xFFE8F6FF);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final eased = Curves.easeOut.transform(progress);

    // Buz parçaları dışarı fırlıyor
    for (int i = 0; i < _kShardCount; i++) {
      final angle = (i / _kShardCount) * 2 * math.pi + 0.3;
      final dist = cellSize * 1.2 * eased;
      final dx = math.cos(angle) * dist;
      final dy = math.sin(angle) * dist + progress * progress * cellSize * 0.2;
      final pos = center.translate(dx, dy);

      final shardSize = cellSize * 0.2 * (1.0 - progress);
      if (shardSize <= 0) continue;

      final opacity = (1.0 - progress * progress) * 0.85;

      // Buz parçası — düzensiz dörtgen
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

    // Merkez flaş
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

// ─── Faz 4: Power-up aktivasyon efekti ───────────────────────────────────────

/// Power-up kullanıldığında gösterilen parıltı efekti.
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
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
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
    );
  }
}

// ─── Faz 4: Bomb patlama efekti ──────────────────────────────────────────────

/// 3×3 bomb temizlemede gösterilen patlama efekti.
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
      duration: const Duration(milliseconds: 650),
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
    final size = widget.cellSize * 6.0;
    return SizedBox(
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

    // Şok dalgası — genişleyen turuncu halka
    final shockEased = Curves.easeOutCubic.transform(progress.clamp(0, 1));
    final shockRadius = cellSize * 3.0 * shockEased;
    final shockOpacity = (1.0 - shockEased) * 0.6;

    canvas.drawCircle(
      center,
      shockRadius,
      Paint()
        ..color = const Color(0xFFFF8C00).withValues(alpha: shockOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - shockEased) * 4 + 0.5,
    );

    // Merkez patlama — beyaz → turuncu gradyan
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
              const Color(0xFFFF8C00).withValues(alpha: opacity * 0.5),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    // Kıvılcımlar
    if (progress > 0.1 && progress < 0.9) {
      final sparkT = ((progress - 0.1) / 0.8).clamp(0.0, 1.0);
      const sparkCount = 12;
      for (int i = 0; i < sparkCount; i++) {
        final angle = (i / sparkCount) * 2 * math.pi;
        final dist = cellSize * 2.5 * sparkT;
        final sparkX = math.cos(angle) * dist;
        final sparkY = math.sin(angle) * dist + sparkT * sparkT * cellSize * 0.4;
        final sparkSize = cellSize * 0.12 * (1.0 - sparkT);
        if (sparkSize <= 0) continue;
        final opacity = (1.0 - sparkT * sparkT) * 0.9;

        canvas.drawCircle(
          center.translate(sparkX, sparkY),
          sparkSize,
          Paint()..color = const Color(0xFFFFD700).withValues(alpha: opacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BombPainter old) => old.progress != progress;
}

// ─── Faz 4: Undo geri sarma efekti ────────────────────────────────────────────

/// Undo kullanıldığında geri alınan hücrelerde amber halka + beyaz parlama.
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
    return IgnorePointer(
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

  static const _kAmberColor = Color(0xFFFFD740);
  static const _kAmberGlow = Color(0xFFFFA000);

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

      // Amber glow halkası
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
        final flashOpacity = flashT < 0.4 ? flashT * 2.5 : (1.0 - flashT) * 1.67;
        canvas.drawCircle(
          Offset(cx, cy),
          cellSize * 0.35 * flashT,
          Paint()
            ..color = Colors.white.withValues(alpha: flashOpacity.clamp(0.0, 1.0) * 0.7)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_UndoRewindPainter old) => old.progress != progress;
}

// ─── Faz F: Vignette Painter (Near-Miss) ──────────────────────────────────────

class _VignettePainter extends CustomPainter {
  const _VignettePainter({required this.color, required this.intensity});

  final Color color;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.longestSide * 0.7;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.transparent,
          color.withValues(alpha: intensity * 0.5),
          color.withValues(alpha: intensity),
        ],
        stops: const [0.0, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_VignettePainter old) =>
      old.intensity != intensity || old.color != color;
}

// ─── Faz F: Renk Sentezi Color Bloom ──────────────────────────────────────────

/// Sentez anında merkezden dışa doğru renk patlaması.
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
      duration: const Duration(milliseconds: 700),
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
    final size = widget.cellSize * 5.0;
    return SizedBox(
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

    // 1. Sentez flaşı — merkezde parlak daire
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

    // 2. Renk halkaları — 2 genişleyen halka
    for (int ring = 0; ring < 2; ring++) {
      final ringDelay = ring * 0.12;
      final ringT = ((progress - ringDelay) / (1.0 - ringDelay)).clamp(0.0, 1.0);
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

    // 3. Sentez parcaciklari — merkezden disa yayilan renkli noktalar
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

// ─── Faz F: Ortam Yüzücü Jel Damlacıkları ─────────────────────────────────

/// Arka planda yavaşça hareket eden dekoratif jel parçacıkları.
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
      // Yüzme hareketi: sinüsoidal dalga + yavaş drift
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
