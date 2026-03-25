import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/models/game_mode.dart';
import 'chef_level_overlay.dart';
import 'game_over_overlay.dart';
import 'level_complete_overlay.dart';

/// Chef level complete dialog'unu goster.
void showChefLevelComplete({
  required BuildContext context,
  required int completedIndex,
  required GelColor targetColor,
  required bool allComplete,
  required VoidCallback onContinue,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 360),
      transitionBuilder: fadeScaleTransition,
      pageBuilder: (ctx, _, __) => ChefLevelOverlay(
        completedLevelIndex: completedIndex,
        targetColor: targetColor,
        isAllComplete: allComplete,
        onContinue: () {
          Navigator.of(ctx).pop();
          onContinue();
        },
        onHome: () {
          Navigator.of(ctx).pop();
          context.go('/');
        },
      ),
    );
  });
}

/// Game over dialog'unu goster.
void showGameOver({
  required BuildContext context,
  required int score,
  required GameMode mode,
  required int filledCells,
  required int totalCells,
  required bool isNewHighScore,
  required bool showSecondChance,
  required VoidCallback? onSecondChance,
  required VoidCallback onReplay,
  required VoidCallback onHome,
  String? secondChanceLabel,
  int linesCleared = 0,
  int synthesisCount = 0,
  int maxCombo = 0,
  VoidCallback? onWatchAdBomb,
  VoidCallback? onChallenge,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 380),
      transitionBuilder: fadeScaleTransition,
      pageBuilder: (ctx, _, __) => GameOverOverlay(
        score: score,
        mode: mode,
        filledCells: filledCells,
        totalCells: totalCells,
        isNewHighScore: isNewHighScore,
        showSecondChance: showSecondChance,
        onSecondChance: onSecondChance,
        secondChanceLabel: secondChanceLabel,
        linesCleared: linesCleared,
        synthesisCount: synthesisCount,
        maxCombo: maxCombo,
        onWatchAdBomb: onWatchAdBomb,
        onChallenge: onChallenge != null
            ? () {
                Navigator.of(ctx).pop();
                onChallenge();
              }
            : null,
        onReplay: () {
          Navigator.of(ctx).pop();
          onReplay();
        },
        onHome: () {
          Navigator.of(ctx).pop();
          onHome();
        },
      ),
    );
  });
}

/// Level complete dialog'unu goster.
void showLevelComplete({
  required BuildContext context,
  required int score,
  required int levelId,
  required String nextLevelLabel,
  required String levelListLabel,
  required String mainMenuLabel,
  required String levelLabel,
  required String completedLabel,
  int? targetScore,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 380),
      transitionBuilder: fadeScaleTransition,
      pageBuilder: (ctx, _, __) => LevelCompleteOverlay(
        score: score,
        levelId: levelId,
        targetScore: targetScore,
        nextLevelLabel: nextLevelLabel,
        levelListLabel: levelListLabel,
        mainMenuLabel: mainMenuLabel,
        levelLabel: levelLabel,
        completedLabel: completedLabel,
        onNextLevel: () {
          Navigator.of(ctx).pop();
          final nextId = levelId + 1;
          context.go('/game/level/$nextId');
        },
        onLevelList: () {
          Navigator.of(ctx).pop();
          context.go('/levels');
        },
        onHome: () {
          Navigator.of(ctx).pop();
          context.go('/');
        },
      ),
    );
  });
}
