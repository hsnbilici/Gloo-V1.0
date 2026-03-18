import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/world/game_world.dart';
import '../../providers/game_provider.dart';
import '../../providers/locale_provider.dart';
import 'game_overlay_bars.dart';
import 'game_overlay_duel.dart';
import 'game_overlay_pause.dart';
import 'game_overlay_zen.dart';

class GameOverlay extends ConsumerWidget {
  const GameOverlay({super.key, required this.game, required this.mode});

  final GlooGame game;
  final GameMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider(mode));
    final l = ref.watch(stringsProvider);

    final modeLabel = switch (mode) {
      GameMode.classic => l.modeLabelClassic,
      GameMode.colorChef => l.modeLabelColorChef,
      GameMode.timeTrial => l.modeLabelTimeTrial,
      GameMode.zen => l.modeLabelZen,
      GameMode.daily => l.modeLabelDaily,
      GameMode.level => l.levelLabel,
      GameMode.duel => l.duelLabel,
    };
    final modeColor = kModeColors[mode]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (mode == GameMode.zen)
                ZenScoreIndicator(color: modeColor, score: gameState.score)
              else
                _ScoreDisplay(score: gameState.score, label: l.scoreLabel),
              _ModeLabel(label: modeLabel, color: modeColor),
              _PauseButton(
                semanticLabel: l.pauseTitle,
                onTap: () {
                  game.pauseGame();
                  _showPauseDialog(
                      context, game, l.pauseTitle, l.pauseResume, l.pauseHome);
                },
              ),
            ],
          ),
        ),
        if (mode == GameMode.classic || mode == GameMode.daily)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: FillBar(
              filledCells: gameState.filledCells,
              totalCells: game.gridManager.totalCells,
            ),
          ),
        if (mode == GameMode.timeTrial)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: CountdownBar(
              remainingSeconds: gameState.remainingSeconds,
              totalSeconds: GameConstants.timeTrialDuration,
            ),
          ),
        if (mode == GameMode.colorChef)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: ChefTargetBar(
              targetColor: game.currentChefLevel?.targetColor,
              progress: gameState.chefProgress,
              required: gameState.chefRequired,
              levelIndex: game.chefLevelIndex,
            ),
          ),
        if (mode == GameMode.zen)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: ZenAmbienceBar(
              filledCells: gameState.filledCells,
              totalCells: game.gridManager.totalCells,
              color: modeColor,
            ),
          ),
        if (mode == GameMode.duel)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: DuelHud(
              remainingSeconds: gameState.remainingSeconds,
              ref: ref,
            ),
          ),
      ],
    );
  }

  void _showPauseDialog(
    BuildContext context,
    GlooGame game,
    String title,
    String resumeLabel,
    String homeLabel,
  ) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: fadeScaleTransition,
      pageBuilder: (ctx, _, __) => PauseDialog(
        title: title,
        resumeLabel: resumeLabel,
        homeLabel: homeLabel,
        onResume: () {
          Navigator.pop(ctx);
          game.resumeGame();
        },
        onHome: () {
          Navigator.pop(ctx);
          context.go('/');
        },
      ),
    );
  }
}

// ─── Skor ────────────────────────────────────────────────────────────────────

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.score, required this.label});

  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kMuted,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          _format(score),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1,
            shadows: [
              Shadow(color: Color(0x4400E5FF), blurRadius: 12),
            ],
          ),
        ),
      ],
    );
  }

  String _format(int s) {
    if (s >= 1000000) return '${(s / 1000000).toStringAsFixed(1)}M';
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}K';
    return s.toString();
  }
}

// ─── Mod etiketi ─────────────────────────────────────────────────────────────

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Duraklat butonu ─────────────────────────────────────────────────────────

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onTap, required this.semanticLabel});
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(UIConstants.radiusSm),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Icon(
            Icons.pause_rounded,
            color: Colors.white.withValues(alpha: 0.90),
            size: 20,
          ),
        ),
      ),
    );
  }
}
