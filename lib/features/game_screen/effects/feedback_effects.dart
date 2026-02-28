import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/near_miss_detector.dart';
import '../../../game/systems/combo_detector.dart';
import '../../../providers/locale_provider.dart';

/// Combo kazanildiginda ortada beliren animasyonlu banner.
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
    // Toplam animasyon suresi: 350ms giris + 750ms bekleme + 400ms cikis = ~1500ms
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

/// Parca yerlestirme geri bildirimi: kisa sureyle yukari kayan "+N" yazisi.
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

/// Near-miss tespit edildiginde ekran kenarlarini kirmizi/turuncu titresimle
/// uyaran ve ortada metin gosteren overlay efekti.
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
