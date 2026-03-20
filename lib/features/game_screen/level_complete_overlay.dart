import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

class LevelCompleteOverlay extends StatelessWidget {
  const LevelCompleteOverlay({
    super.key,
    required this.score,
    required this.levelId,
    required this.onNextLevel,
    required this.onLevelList,
    required this.onHome,
    required this.nextLevelLabel,
    required this.levelListLabel,
    required this.mainMenuLabel,
    required this.levelLabel,
    required this.completedLabel,
  });

  final int score;
  final int levelId;
  final VoidCallback onNextLevel;
  final VoidCallback onLevelList;
  final VoidCallback onHome;
  final String nextLevelLabel;
  final String levelListLabel;
  final String mainMenuLabel;
  final String levelLabel;
  final String completedLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBgDark.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$levelLabel $levelId',
              style: const TextStyle(
                color: kMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              completedLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                color: kColorChef,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 200.ms),
            const SizedBox(height: 16),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: score),
              duration: AnimationDurations.levelComplete,
              curve: Curves.easeOutCubic,
              builder: (_, val, __) => Text(
                '$val',
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: kColorChef.withValues(alpha: 0.5),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: onNextLevel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorChef,
                  foregroundColor: kBgDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  ),
                ),
                child: Text(
                  nextLevelLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 220,
              child: OutlinedButton(
                onPressed: onLevelList,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kMuted,
                  side: BorderSide(color: kMuted.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  ),
                ),
                child: Text(
                  levelListLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
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
    );
  }
}
