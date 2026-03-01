import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../shared/glow_orb.dart';
import '../../game/world/game_world.dart';
import '../../providers/locale_provider.dart';

// ─── Tam ekran Game Over overlay ─────────────────────────────────────────────

class GameOverOverlay extends ConsumerWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    required this.mode,
    required this.filledCells,
    required this.totalCells,
    required this.isNewHighScore,
    required this.onReplay,
    required this.onHome,
    this.showSecondChance = false,
    this.onSecondChance,
  });

  final int score;
  final GameMode mode;
  final int filledCells;
  final int totalCells;
  final bool isNewHighScore;
  final VoidCallback onReplay;
  final VoidCallback onHome;
  final bool showSecondChance;
  final VoidCallback? onSecondChance;

  static Color modeColor(GameMode mode) => switch (mode) {
        GameMode.classic => kColorClassic,
        GameMode.colorChef => kColorChef,
        GameMode.timeTrial => kColorTimeTrial,
        GameMode.zen => kColorZen,
        GameMode.daily => kCyan,
        GameMode.level => kColorChef,
        GameMode.duel => kColorClassic,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(stringsProvider);
    final color = modeColor(mode);

    final modeLabel = switch (mode) {
      GameMode.classic => l.gameOverModeClassic,
      GameMode.colorChef => l.gameOverModeColorChef,
      GameMode.timeTrial => l.gameOverModeTimeTrial,
      GameMode.zen => l.gameOverModeZen,
      GameMode.daily => l.gameOverModeDaily,
      GameMode.level => 'Seviye',
      GameMode.duel => 'Düello',
    };

    final fillPct =
        totalCells > 0 ? (filledCells / totalCells * 100).round() : 0;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Arkaplan
          const ColoredBox(color: kBgDark, child: SizedBox.expand()),
          // Mod rengiyle üst ışıma
          Positioned(
            top: -140,
            left: -100,
            child: GlowOrb(size: 420, color: color, opacity: 0.10),
          ),
          // Alt karşıt ışıma
          Positioned(
            bottom: -100,
            right: -80,
            child: GlowOrb(size: 300, color: color, opacity: 0.06),
          ),
          // İçerik
          SafeArea(
            child: Column(
              children: [
                // ── Üst boşluk
                const SizedBox(height: 8),
                // ── Mod rozeti
                _ModeBadge(label: modeLabel, color: color)
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 280.ms)
                    .scale(
                      begin: const Offset(0.75, 0.75),
                      duration: 280.ms,
                      curve: Curves.easeOutBack,
                    ),
                // ── Merkez içerik
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Başlık
                      Text(
                        l.gameOverTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                              color: color.withValues(alpha: 0.55),
                              blurRadius: 22,
                            ),
                          ],
                        ),
                      ).animate(delay: 140.ms).fadeIn(duration: 300.ms).slideY(
                            begin: -0.12,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 14),
                      // Parıldayan ayraç
                      _GlowDivider(color: color).animate(delay: 240.ms).scaleX(
                            begin: 0,
                            end: 1,
                            duration: 380.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 48),
                      // Skor sayacı
                      _ScoreCountUp(score: score, color: color),
                      const SizedBox(height: 6),
                      Text(
                        l.gameOverScoreLabel,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ).animate(delay: 360.ms).fadeIn(duration: 280.ms),
                      if (isNewHighScore) ...[
                        const SizedBox(height: 12),
                        _NewRecordBadge(
                                label: l.gameOverNewRecord, color: color)
                            .animate(delay: 420.ms)
                            .fadeIn(duration: 300.ms)
                            .scale(
                              begin: const Offset(0.7, 0.7),
                              duration: 300.ms,
                              curve: Curves.easeOutBack,
                            ),
                      ],
                      const SizedBox(height: 40),
                      // İstatistik
                      _StatRow(
                        label: l.gameOverGridFill,
                        value: '%$fillPct',
                        color: color,
                      ).animate(delay: 460.ms).fadeIn(duration: 280.ms).slideX(
                            begin: 0.12,
                            end: 0,
                            duration: 280.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
                // ── Butonlar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ikinci Sans butonu — Rewarded Ad
                      if (showSecondChance && onSecondChance != null)
                        _SecondChanceButton(
                          color: color,
                          onTap: onSecondChance!,
                        )
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 320.ms)
                            .slideY(
                              begin: 0.18,
                              end: 0,
                              duration: 320.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      if (showSecondChance && onSecondChance != null)
                        const SizedBox(height: 12),
                      _ActionButton(
                        label: l.gameOverReplay,
                        icon: Icons.replay_rounded,
                        accentColor: color,
                        filled: true,
                        onTap: onReplay,
                      ).animate(delay: 540.ms).fadeIn(duration: 320.ms).slideY(
                            begin: 0.18,
                            end: 0,
                            duration: 320.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 12),
                      _ActionButton(
                        label: l.gameOverHome,
                        icon: Icons.home_rounded,
                        accentColor: kMuted,
                        filled: false,
                        onTap: onHome,
                      ).animate(delay: 610.ms).fadeIn(duration: 320.ms).slideY(
                            begin: 0.18,
                            end: 0,
                            duration: 320.ms,
                            curve: Curves.easeOutCubic,
                          ),
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

// ─── Yeni rekor rozeti ───────────────────────────────────────────────────────

class _NewRecordBadge extends StatelessWidget {
  const _NewRecordBadge({required this.label, required this.color});

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

// ─── Score count-up ───────────────────────────────────────────────────────────

class _ScoreCountUp extends StatelessWidget {
  const _ScoreCountUp({required this.score, required this.color});

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

// ─── Mod rozeti ───────────────────────────────────────────────────────────────

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.label, required this.color});

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

// ─── Parıldayan ayraç ────────────────────────────────────────────────────────

class _GlowDivider extends StatelessWidget {
  const _GlowDivider({required this.color});

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

// ─── İstatistik satırı ───────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({
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

// ─── Aksiyon butonu ──────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

// ─── Ikinci Sans butonu — Rewarded Ad ile 3 ekstra hamle ─────────────────

class _SecondChanceButton extends StatefulWidget {
  const _SecondChanceButton({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  State<_SecondChanceButton> createState() => _SecondChanceButtonState();
}

class _SecondChanceButtonState extends State<_SecondChanceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFD700);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
            _pressed ? 0.97 : 1.0, _pressed ? 0.97 : 1.0, 1.0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              accent.withValues(alpha: _pressed ? 0.22 : 0.15),
              widget.color.withValues(alpha: _pressed ? 0.18 : 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: accent.withValues(alpha: _pressed ? 0.80 : 0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline_rounded,
                color: accent, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Reklam Izle',
              style: TextStyle(
                color: accent,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.40)),
              ),
              child: const Text(
                '+3 Hamle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtonState extends State<_ActionButton> {
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
            _pressed ? 0.97 : 1.0, _pressed ? 0.97 : 1.0, 1.0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: widget.filled
              ? widget.accentColor.withValues(alpha: _pressed ? 0.20 : 0.13)
              : Colors.white.withValues(alpha: _pressed ? 0.07 : 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: widget.filled
                ? widget.accentColor.withValues(alpha: _pressed ? 0.70 : 0.50)
                : Colors.white.withValues(alpha: _pressed ? 0.16 : 0.09),
            width: widget.filled ? 1.5 : 1,
          ),
          boxShadow: widget.filled
              ? [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.accentColor, size: 18),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.accentColor,
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
