import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/quest_provider.dart';

/// Compact daily quest progress bar shown on the HomeScreen.
class QuestBar extends ConsumerWidget {
  const QuestBar({super.key, required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questAsync = ref.watch(questProvider);
    final l = ref.watch(stringsProvider);

    return questAsync.when(
      data: (state) {
        if (state.dailyQuests.isEmpty) return const SizedBox.shrink();
        final completed =
            state.dailyQuests.where((q) => state.isCompleted(q)).length;
        final total = state.dailyQuests.length;

        final surfaceColor = resolveColor(
          brightness,
          dark: Colors.white.withValues(alpha: 0.04),
          light: kCardBgLight,
        );
        final borderColor = resolveColor(
          brightness,
          dark: Colors.white.withValues(alpha: 0.08),
          light: kCardBorderLight,
        );
        final textColor = resolveColor(
          brightness,
          dark: Colors.white.withValues(alpha: 0.70),
          light: kTextPrimaryLight,
        );
        final mutedColor = resolveColor(
          brightness,
          dark: kMuted,
          light: kTextSecondaryLight,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(UIConstants.radiusMd),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.assignment_rounded,
                color: completed >= total ? kGreen : kGold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l.questsTitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: state.dailyQuests.map((quest) {
                    final done = state.isCompleted(quest);
                    final progress = state.getQuestProgress(quest);
                    final ratio = quest.targetCount > 0
                        ? (progress / quest.targetCount).clamp(0.0, 1.0)
                        : 0.0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: SizedBox(
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.08),
                                  color: done ? kGreen : kGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$completed/$total',
                style: TextStyle(
                  color: completed >= total ? kGreen : mutedColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
