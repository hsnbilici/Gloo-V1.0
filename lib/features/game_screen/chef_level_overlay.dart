import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../shared/glow_orb.dart';
import '../../providers/locale_provider.dart';

// ─── Seviye tamamlama overlay ─────────────────────────────────────────────────

class ChefLevelOverlay extends ConsumerWidget {
  const ChefLevelOverlay({
    super.key,
    required this.completedLevelIndex,
    required this.targetColor,
    required this.isAllComplete,
    required this.onContinue,
    required this.onHome,
  });

  final int completedLevelIndex;
  final GelColor targetColor;
  final bool isAllComplete;
  final VoidCallback onContinue;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(stringsProvider);
    final color = targetColor.displayColor;
    final levelNumber = completedLevelIndex + 1;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: kBgDark, child: SizedBox.expand()),
          // Üst ışıma — hedef renk tonu
          Positioned(
            top: -120,
            left: -80,
            child: GlowOrb(size: 380, color: color, opacity: 0.14),
          ),
          // Alt karşıt ışıma — kColorChef sabit
          const Positioned(
            bottom: -80,
            right: -60,
            child: GlowOrb(size: 260, color: kColorChef, opacity: 0.10),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Mod rozeti
                _ChefBadge(
                  levelNumber: isAllComplete ? null : levelNumber,
                  isAllComplete: isAllComplete,
                  color: color,
                ).animate(delay: 60.ms).fadeIn(duration: 260.ms).scale(
                      begin: const Offset(0.75, 0.75),
                      duration: 260.ms,
                      curve: Curves.easeOutBack,
                    ),
                // Merkez içerik
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Büyük renk damlası
                      _ColorDrop(color: color)
                          .animate(delay: 120.ms)
                          .fadeIn(duration: 320.ms)
                          .scale(
                            begin: const Offset(0.4, 0.4),
                            duration: 480.ms,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 28),
                      // Başlık
                      Text(
                        isAllComplete ? l.chefAllComplete : l.chefLevelComplete,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isAllComplete ? 24 : 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              color: color.withValues(alpha: 0.60),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(
                            begin: -0.10,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 12),
                      // Hedef renk adı
                      Text(
                        l.colorName(targetColor),
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ).animate(delay: 280.ms).fadeIn(duration: 260.ms),
                      const SizedBox(height: 10),
                      // Parıldayan ayraç
                      _GlowLine(color: color).animate(delay: 340.ms).scaleX(
                            begin: 0,
                            end: 1,
                            duration: 360.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      if (isAllComplete) ...[
                        const SizedBox(height: 24),
                        _AllCompleteStars(color: color)
                            .animate(delay: 420.ms)
                            .fadeIn(duration: 400.ms),
                      ],
                    ],
                  ),
                ),
                // Butonlar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isAllComplete) ...[
                        _OverlayButton(
                          label: l.chefContinue,
                          icon: Icons.arrow_forward_rounded,
                          color: color,
                          filled: true,
                          onTap: onContinue,
                        )
                            .animate(delay: 480.ms)
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.18, end: 0, duration: 300.ms),
                        const SizedBox(height: 12),
                      ],
                      _OverlayButton(
                        label: l.gameOverHome,
                        icon: Icons.home_rounded,
                        color: kMuted,
                        filled: false,
                        onTap: onHome,
                      )
                          .animate(delay: isAllComplete ? 480.ms : 560.ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.18, end: 0, duration: 300.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rozet ────────────────────────────────────────────────────────────────────

class _ChefBadge extends StatelessWidget {
  const _ChefBadge({
    required this.levelNumber,
    required this.isAllComplete,
    required this.color,
  });

  final int? levelNumber;
  final bool isAllComplete;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = isAllComplete ? 'RENK ŞEFİ' : 'SEVİYE $levelNumber';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 1),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.14), blurRadius: 12),
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

// ─── Renk damlası ─────────────────────────────────────────────────────────────

class _ColorDrop extends StatelessWidget {
  const _ColorDrop({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.55),
              blurRadius: 36,
              spreadRadius: 4),
          BoxShadow(color: color.withValues(alpha: 0.20), blurRadius: 80),
        ],
      ),
      child: Icon(
        Icons.check_rounded,
        color: Colors.black.withValues(alpha: 0.60),
        size: 44,
      ),
    );
  }
}

// ─── Parıldayan çizgi ─────────────────────────────────────────────────────────

class _GlowLine extends StatelessWidget {
  const _GlowLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, color, Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusXxs),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.70),
              blurRadius: 8,
              spreadRadius: 1),
        ],
      ),
    );
  }
}

// ─── Tüm seviyeler yıldız göstergesi ─────────────────────────────────────────

class _AllCompleteStars extends StatelessWidget {
  const _AllCompleteStars({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            Icons.star_rounded,
            color: color.withValues(alpha: 0.3 + i * 0.14),
            size: 20 + i * 3.0,
          ).animate(delay: Duration(milliseconds: 420 + i * 80)).scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
        );
      }),
    );
  }
}

// ─── Aksiyon butonu ───────────────────────────────────────────────────────────

class _OverlayButton extends StatefulWidget {
  const _OverlayButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_OverlayButton> createState() => _OverlayButtonState();
}

class _OverlayButtonState extends State<_OverlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _pressed ? 0.97 : 1.0,
          _pressed ? 0.97 : 1.0,
          1.0,
        ),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: widget.filled
              ? widget.color.withValues(alpha: _pressed ? 0.20 : 0.13)
              : Colors.white.withValues(alpha: _pressed ? 0.07 : 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: widget.filled
                ? widget.color.withValues(alpha: _pressed ? 0.70 : 0.50)
                : Colors.white.withValues(alpha: _pressed ? 0.16 : 0.09),
            width: widget.filled ? 1.5 : 1,
          ),
          boxShadow: widget.filled
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 18),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
