import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/utils/motion_utils.dart';
import '../../game/meta/resource_manager.dart';

class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.quest,
    required this.progress,
    required this.accentColor,
    required this.delay,
  });

  final Quest quest;
  final int progress;
  final Color accentColor;
  final Duration delay;

  IconData get _questIcon => switch (quest.type) {
        QuestType.clearLines => Icons.horizontal_rule_rounded,
        QuestType.makeSyntheses => Icons.merge_type_rounded,
        QuestType.reachCombo => Icons.flash_on_rounded,
        QuestType.completeDailyPuzzle => Icons.calendar_today_rounded,
        QuestType.playGames => Icons.sports_esports_rounded,
        QuestType.useColorSynthesis => Icons.palette_rounded,
        QuestType.reachScore => Icons.emoji_events_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= quest.targetCount;
    final ratio = quest.targetCount > 0
        ? (progress / quest.targetCount).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isComplete
              ? accentColor.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusMd),
          border: Border.all(
            color: isComplete
                ? accentColor.withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isComplete ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                border: Border.all(
                  color:
                      accentColor.withValues(alpha: isComplete ? 0.35 : 0.15),
                ),
              ),
              child: Icon(
                isComplete ? Icons.check_rounded : _questIcon,
                color: isComplete
                    ? accentColor
                    : accentColor.withValues(alpha: 0.60),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isComplete
                          ? Colors.white.withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.80),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration:
                          isComplete ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white.withValues(alpha: 0.30),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor,
                                    accentColor.withValues(alpha: 0.70),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$progress / ${quest.targetCount}',
                    style: TextStyle(
                      color: isComplete
                          ? accentColor.withValues(alpha: 0.60)
                          : Colors.white.withValues(alpha: 0.35),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                RewardChip(
                  icon: Icons.star_rounded,
                  label: '${quest.xpReward}',
                  color: kGold,
                ),
                const SizedBox(height: 3),
                RewardChip(
                  icon: Icons.water_drop_rounded,
                  label: '${quest.gelReward}',
                  color: kGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animateOrSkip(reduceMotion: shouldReduceMotion(context), delay: delay)
        .fadeIn(duration: 200.ms)
        .slideX(begin: 0.06, end: 0, duration: 200.ms);
  }
}

class RewardChip extends StatelessWidget {
  const RewardChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(UIConstants.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class XpBadge extends StatelessWidget {
  const XpBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(UIConstants.radiusSm),
        border: Border.all(
          color: kGold.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: kGold, size: 12),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: kGold,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
