import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../providers/locale_provider.dart';
import '../../../game/meta/quests.dart';
import '../../../providers/quest_provider.dart';
import '../../../providers/user_provider.dart';

/// Compact combined daily-puzzle shortcut + quest progress bar shown on the
/// HomeScreen. Replaces the standalone DailyBanner to reduce info layers.
class QuestBar extends ConsumerStatefulWidget {
  const QuestBar({super.key, required this.brightness});

  final Brightness brightness;

  @override
  ConsumerState<QuestBar> createState() => _QuestBarState();
}

class _QuestBarState extends ConsumerState<QuestBar> {
  bool _expanded = false;

  Brightness get brightness => widget.brightness;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final questAsync = ref.watch(questProvider);
    final l = ref.watch(stringsProvider);
    final repoAsync = ref.watch(localRepositoryProvider);
    final dailyCompleted = repoAsync.valueOrNull?.isDailyCompleted() ?? false;
    final dailyScore = repoAsync.valueOrNull?.getDailyScore() ?? 0;

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
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(UIConstants.radiusMd),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Daily puzzle shortcut + quest progress row ────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: tappable daily puzzle shortcut
                  Semantics(
                    label: l.dailyTitle,
                    button: true,
                    child: GestureDetector(
                      onTap: () => context.push('/daily'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: borderColor,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              dailyCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.calendar_today_rounded,
                              color: dailyCompleted ? kColorChef : kCyan,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              dailyCompleted
                                  ? _fmtScore(dailyScore)
                                  : l.dailyTitle,
                              style: TextStyle(
                                color: dailyCompleted ? kColorChef : kCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Right: quest progress bars + counter (tappable to expand)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                        children: [
                          Icon(
                            Icons.assignment_rounded,
                            color: completed >= total ? kGreen : kGold,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Row(
                              children: state.dailyQuests.map((quest) {
                                final done = state.isCompleted(quest);
                                final progress =
                                    state.getQuestProgress(quest);
                                final ratio = quest.targetCount > 0
                                    ? (progress / quest.targetCount)
                                        .clamp(0.0, 1.0)
                                    : 0.0;
                                return Expanded(
                                  child: Tooltip(
                                    message: done
                                        ? '${quest.description} ✓'
                                        : '${quest.description} ($progress/${quest.targetCount})',
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(2),
                                        child: SizedBox(
                                          height: 4,
                                          child: LinearProgressIndicator(
                                            value: ratio,
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.08),
                                            color: done ? kGreen : kGold,
                                          ),
                                        ),
                                      ),
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
                          Icon(
                            _expanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: mutedColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                ],
              ),
              // ── Expanded quest details ─────────────────────────────────────
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      for (final quest in state.dailyQuests) ...[
                        _QuestDetailRow(
                          quest: quest,
                          progress: state.getQuestProgress(quest),
                          done: state.isCompleted(quest),
                          accentColor: kGold,
                          textColor: textColor,
                          mutedColor: mutedColor,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // ── Weekly row ───────────────────────────────────────────────
              if (state.weeklyQuests.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _WeeklyRow(
                    state: state,
                    mutedColor: mutedColor,
                    textColor: textColor,
                    weeklyLabel: l.weeklyQuestsTitle,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Single quest detail row — description + progress counter.
class _QuestDetailRow extends StatelessWidget {
  const _QuestDetailRow({
    required this.quest,
    required this.progress,
    required this.done,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
  });

  final Quest quest;
  final int progress;
  final bool done;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: done ? kGreen : accentColor,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              quest.description,
              style: TextStyle(
                color: done ? mutedColor : textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            done
                ? '✓'
                : '${progress.clamp(0, quest.targetCount)}/${quest.targetCount}',
            style: TextStyle(
              color: done ? kGreen : mutedColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          // Ödül
          const SizedBox(width: 6),
          Text(
            '+${quest.gelReward}',
            style: TextStyle(
              color: kCyan.withValues(alpha: done ? 0.4 : 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Weekly quest progress row — rendered below the daily row when weekly
/// quests are present. Uses kOrange accent to visually distinguish.
class _WeeklyRow extends StatelessWidget {
  const _WeeklyRow({
    required this.state,
    required this.mutedColor,
    required this.textColor,
    required this.weeklyLabel,
  });

  final QuestProgress state;
  final Color mutedColor;
  final Color textColor;
  final String weeklyLabel;

  @override
  Widget build(BuildContext context) {
    final completedWeekly =
        state.weeklyQuests.where((q) => state.isCompleted(q)).length;
    final totalWeekly = state.weeklyQuests.length;

    return Row(
      children: [
        Icon(
          Icons.date_range_rounded,
          color: completedWeekly >= totalWeekly ? kGreen : kOrange,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          weeklyLabel,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: state.weeklyQuests.map((quest) {
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
                            color: done ? kGreen : kOrange,
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
          '$completedWeekly/$totalWeekly',
          style: TextStyle(
            color: completedWeekly >= totalWeekly ? kGreen : mutedColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

String _fmtScore(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toString();
}
