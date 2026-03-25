import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../data/remote/friend_repository.dart';
import '../../../providers/friend_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/user_provider.dart';

/// Compact weekly rival comparison card shown on HomeScreen below QuestBar.
///
/// Hidden when: Supabase not configured, no score data, or data is null.
/// Tappable → navigates to /leaderboard.
class WeeklyRivalCard extends ConsumerStatefulWidget {
  const WeeklyRivalCard({super.key, required this.brightness});

  final Brightness brightness;

  @override
  ConsumerState<WeeklyRivalCard> createState() => _WeeklyRivalCardState();
}

class _WeeklyRivalCardState extends ConsumerState<WeeklyRivalCard> {
  Future<FriendsRankData?>? _rankFuture;

  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    // Provider'dan sonra yükle — initState'te valueOrNull null olabilir
    if (!_loaded) {
      final repo = ref.read(localRepositoryProvider).valueOrNull;
      if (repo != null) {
        _loaded = true;
        final modeStr = repo.getLastPlayedMode() ?? 'classic';
        _rankFuture = ref.read(friendRepositoryProvider).getFriendsRank(
              mode: modeStr,
              weekly: true,
            );
      }
    }
    if (_rankFuture == null) return const SizedBox.shrink();

    return FutureBuilder<FriendsRankData?>(
      future: _rankFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (!snapshot.hasData || data == null) return const SizedBox.shrink();
        if (data.total <= 1 || data.myScore <= 0) return const SizedBox.shrink();

        final l = ref.read(stringsProvider);
        final brightness = widget.brightness;

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
        final mutedColor = resolveColor(
          brightness,
          dark: kMuted,
          light: kTextSecondaryLight,
        );

        final hasRival = data.rivalName != null &&
            data.rivalScore != null &&
            data.rivalScore! > data.myScore;
        final diff = hasRival ? data.rivalScore! - data.myScore : 0;

        final semanticsLabel = hasRival
            ? '${l.weeklyRivalTitle}: #${data.rank} / ${data.total}. '
                '${l.weeklyRivalAhead(data.rivalName!, diff)}'
            : '${l.weeklyRivalTitle}: #${data.rank} / ${data.total}';

        return Semantics(
          label: semanticsLabel,
          button: true,
          child: GestureDetector(
            onTap: () => context.push('/leaderboard'),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: kGold, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${l.weeklyRivalTitle}: #${data.rank} / ${data.total}',
                    style: const TextStyle(
                      color: kGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hasRival) ...[
                    const Spacer(),
                    Icon(Icons.trending_up_rounded,
                        color: mutedColor, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l.weeklyRivalAhead(data.rivalName!, diff),
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
