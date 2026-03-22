import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/utils/motion_utils.dart';
import '../../game/pvp/matchmaking.dart';

// ─── Duello Sonuc Overlay ────────────────────────────────────────────────────

class DuelResultOverlay extends StatelessWidget {
  const DuelResultOverlay({
    super.key,
    required this.result,
    required this.playerElo,
    required this.onHome,
    required this.onRematch,
    required this.playAgainLabel,
    required this.mainMenuLabel,
    required this.l,
  });

  final DuelResult result;
  final int playerElo;
  final VoidCallback onHome;
  final VoidCallback onRematch;
  final String playAgainLabel;
  final String mainMenuLabel;
  final AppStrings l;

  static const _kLoss = kRed;
  static const _kDraw = kYellow;

  Color get _outcomeColor => switch (result.outcome) {
        DuelOutcome.win => kGreen,
        DuelOutcome.loss => _kLoss,
        DuelOutcome.draw => _kDraw,
      };

  String get _outcomeLabel => switch (result.outcome) {
        DuelOutcome.win => l.duelOutcomeWin,
        DuelOutcome.loss => l.duelOutcomeLoss,
        DuelOutcome.draw => l.duelOutcomeDraw,
      };

  IconData get _outcomeIcon => switch (result.outcome) {
        DuelOutcome.win => Icons.emoji_events_rounded,
        DuelOutcome.loss => Icons.sentiment_dissatisfied_rounded,
        DuelOutcome.draw => Icons.handshake_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final rm = shouldReduceMotion(context);
    final color = _outcomeColor;
    final eloChangeStr =
        result.eloChange >= 0 ? '+${result.eloChange}' : '${result.eloChange}';

    return Material(
      color: kBgDark.withValues(alpha: 0.95),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Sonuc ikonu
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border:
                    Border.all(color: color.withValues(alpha: 0.45), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.30),
                    blurRadius: 32,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Icon(_outcomeIcon, color: color, size: 42),
            )
                .animateOrSkip(reduceMotion: rm, delay: 100.ms)
                .scale(
                  begin: const Offset(0.3, 0.3),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 200.ms),
            const SizedBox(height: 20),
            // Sonuc yazisi
            Text(
              _outcomeLabel,
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
                shadows: [
                  Shadow(color: color.withValues(alpha: 0.6), blurRadius: 18),
                ],
              ),
            )
                .animateOrSkip(reduceMotion: rm, delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.1, end: 0, duration: 300.ms),
            const SizedBox(height: 32),
            // Skor karsilastirma
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ScoreColumn(
                  label: l.duelYou,
                  score: result.playerScore,
                  color: color,
                  isWinner: result.outcome == DuelOutcome.win,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l.duelVs,
                    style: const TextStyle(
                      color: kMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                _ScoreColumn(
                  label: l.duelOpponent,
                  score: result.opponentScore,
                  color: kMuted,
                  isWinner: result.outcome == DuelOutcome.loss,
                ),
              ],
            )
                .animateOrSkip(reduceMotion: rm, delay: 350.ms)
                .fadeIn(duration: 350.ms),
            const SizedBox(height: 28),
            // ELO degisimi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l.rankLabel}: $eloChangeStr',
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '($playerElo)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.50),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                .animateOrSkip(reduceMotion: rm, delay: 450.ms)
                .fadeIn(duration: 300.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 8),
            // Jel Ozu odulu
            Text(
              l.duelGelReward(result.gelReward),
              style: TextStyle(
                color: kGold.withValues(alpha: 0.80),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            )
                .animateOrSkip(reduceMotion: rm, delay: 500.ms)
                .fadeIn(duration: 250.ms),
            const Spacer(flex: 2),
            // Butonlar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRematch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.withValues(alpha: 0.15),
                        foregroundColor: color,
                        side: BorderSide(color: color.withValues(alpha: 0.50)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusTile),
                        ),
                      ),
                      child: Text(
                        playAgainLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onHome,
                    child: Text(
                      mainMenuLabel,
                      style: const TextStyle(
                        color: kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({
    required this.label,
    required this.score,
    required this.color,
    required this.isWinner,
  });

  final String label;
  final int score;
  final Color color;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$score',
          style: TextStyle(
            color: isWinner ? color : Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            shadows: isWinner
                ? [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 16)]
                : null,
          ),
        ),
      ],
    );
  }
}
