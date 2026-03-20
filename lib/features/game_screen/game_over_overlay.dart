import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../shared/glow_orb.dart';
import '../../core/models/game_mode.dart';
import '../../providers/locale_provider.dart';
import 'game_over_buttons.dart';
import 'game_over_widgets.dart';

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
    this.secondChanceLabel,
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
  final String? secondChanceLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(stringsProvider);
    final color = kModeColors[mode]!;

    final modeLabel = switch (mode) {
      GameMode.classic => l.gameOverModeClassic,
      GameMode.colorChef => l.gameOverModeColorChef,
      GameMode.timeTrial => l.gameOverModeTimeTrial,
      GameMode.zen => l.gameOverModeZen,
      GameMode.daily => l.gameOverModeDaily,
      GameMode.level => l.levelLabel,
      GameMode.duel => l.duelLabel,
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
                GameOverModeBadge(label: modeLabel, color: color)
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.noScaling,
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
                      GlowDivider(color: color).animate(delay: 240.ms).scaleX(
                            begin: 0,
                            end: 1,
                            duration: 380.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 48),
                      // Skor sayacı
                      ScoreCountUp(score: score, color: color),
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
                        NewRecordBadge(label: l.gameOverNewRecord, color: color)
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
                      GameOverStatRow(
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
                        SecondChanceButton(
                          color: color,
                          onTap: onSecondChance!,
                          watchAdLabel: l.watchAdLabel,
                          secondChanceLabel:
                              secondChanceLabel ?? l.secondChanceMoves,
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
                      ActionButton(
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
                      ActionButton(
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
