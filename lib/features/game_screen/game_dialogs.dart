import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import 'chef_level_overlay.dart';
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
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
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

/// Level complete dialog'unu goster.
void showLevelComplete({
  required BuildContext context,
  required int score,
  required int levelId,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 380),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => LevelCompleteOverlay(
        score: score,
        levelId: levelId,
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
