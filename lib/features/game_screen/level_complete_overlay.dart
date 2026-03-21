import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/utils/motion_utils.dart';

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
    this.targetScore,
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
  final int? targetScore;

  /// Skorun hedef skora oranina gore yildiz sayisi hesaplar.
  /// 1 yildiz: seviye gecildi, 2: 1.5x, 3: 2x
  int _starCount() {
    if (targetScore == null || targetScore! <= 0) return 3;
    final ratio = score / targetScore!;
    if (ratio >= 2.0) return 3;
    if (ratio >= 1.5) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final rm = shouldReduceMotion(context);
    final stars = _starCount();

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
                .animateOrSkip(reduceMotion: rm)
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 200.ms),
            const SizedBox(height: 12),
            // Yildiz satiri
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final earned = i < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    earned ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: i == 1 ? 40 : 32,
                    color: earned ? kGold : kMuted.withValues(alpha: 0.3),
                  )
                      .animateOrSkip(
                          reduceMotion: rm, delay: (200 + i * 120).ms)
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 250.ms),
                );
              }),
            ),
            const SizedBox(height: 12),
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
