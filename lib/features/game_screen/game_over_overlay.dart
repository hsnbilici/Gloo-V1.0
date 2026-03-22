import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/utils/motion_utils.dart';
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
    this.linesCleared = 0,
    this.synthesisCount = 0,
    this.maxCombo = 0,
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
  final int linesCleared;
  final int synthesisCount;
  final int maxCombo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(stringsProvider);
    final rm = shouldReduceMotion(context);
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
                    .animateOrSkip(reduceMotion: rm, delay: 80.ms)
                    .fadeIn(duration: 280.ms)
                    .scale(
                      begin: const Offset(0.75, 0.75),
                      duration: 280.ms,
                      curve: Curves.easeOutBack,
                    ),
                // ── Merkez içerik
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 140.ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(
                            begin: -0.12,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 14),
                      // Parıldayan ayraç
                      GlowDivider(color: color)
                          .animateOrSkip(reduceMotion: rm, delay: 240.ms)
                          .scaleX(
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
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 360.ms)
                          .fadeIn(duration: 280.ms),
                      if (isNewHighScore) ...[
                        const SizedBox(height: 12),
                        NewRecordBadge(label: l.gameOverNewRecord, color: color)
                            .animateOrSkip(reduceMotion: rm, delay: 420.ms)
                            .fadeIn(duration: 300.ms)
                            .scale(
                              begin: const Offset(0.7, 0.7),
                              duration: 300.ms,
                              curve: Curves.easeOutBack,
                            ),
                      ],
                      const SizedBox(height: 40),
                      // İstatistikler
                      GameOverStatRow(
                        label: l.gameOverGridFill,
                        value: '%$fillPct',
                        color: color,
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 460.ms)
                          .fadeIn(duration: 280.ms)
                          .slideX(
                            begin: 0.12,
                            end: 0,
                            duration: 280.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 6),
                      GameOverStatRow(
                        label: l.gameOverLinesCleared,
                        value: '$linesCleared',
                        color: color,
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 500.ms)
                          .fadeIn(duration: 280.ms)
                          .slideX(
                            begin: 0.12,
                            end: 0,
                            duration: 280.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 6),
                      GameOverStatRow(
                        label: l.gameOverSyntheses,
                        value: '$synthesisCount',
                        color: color,
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 540.ms)
                          .fadeIn(duration: 280.ms)
                          .slideX(
                            begin: 0.12,
                            end: 0,
                            duration: 280.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 6),
                      GameOverStatRow(
                        label: l.gameOverMaxCombo,
                        value: '${maxCombo}x',
                        color: color,
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 580.ms)
                          .fadeIn(duration: 280.ms)
                          .slideX(
                            begin: 0.12,
                            end: 0,
                            duration: 280.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      // İpucu
                      if (synthesisCount == 0 || maxCombo == 0) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: 260,
                          child: Text(
                            synthesisCount == 0
                                ? l.gameOverTipSynthesis
                                : l.gameOverTipCombo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kMuted.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        )
                            .animateOrSkip(reduceMotion: rm, delay: 650.ms)
                            .fadeIn(duration: 300.ms),
                      ],
                    ],
                  ),
                    ),
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
                            .animateOrSkip(reduceMotion: rm, delay: 500.ms)
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
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 540.ms)
                          .fadeIn(duration: 320.ms)
                          .slideY(
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
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 610.ms)
                          .fadeIn(duration: 320.ms)
                          .slideY(
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
