import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/models/challenge.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/locale_provider.dart';

/// Card displaying a single challenge (received or sent).
class ChallengeCard extends ConsumerWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.isReceived,
  });

  final Challenge challenge;
  final bool isReceived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(stringsProvider);
    final brightness = Theme.of(context).brightness;

    final surfaceColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.06),
      light: kCardBgLight,
    );
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.1),
      light: kCardBorderLight,
    );
    final textColor = resolveColor(
      brightness,
      dark: Colors.white,
      light: kTextPrimaryLight,
    );
    final challengeAccent = resolveColor(
      brightness,
      dark: kChallengePrimary,
      light: kChallengePrimaryLight,
    );

    final opponentName = isReceived
        ? challenge.senderUsername
        : (challenge.recipientUsername ?? '?');
    final remaining = challenge.timeRemaining;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);

    return Semantics(
      label: isReceived
          ? l.challengeReceivedFrom(opponentName)
          : '${l.challengeSend}: $opponentName',
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusSm),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: avatar + name + mode icon + time
            Row(
              children: [
                _ChallengeAvatar(name: opponentName),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opponentName,
                        style: AppTextStyles.body.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.xxs),
                      Row(
                        children: [
                          Icon(
                            _modeIcon(challenge.mode.name),
                            size: 14,
                            color: kMuted,
                          ),
                          const SizedBox(width: Spacing.xs),
                          if (challenge.status == ChallengeStatus.completed)
                            _StatusChip(
                              label: l.challengeCompleted,
                              color: kGreen,
                            )
                          else if (remaining > Duration.zero)
                            Text(
                              l.challengeTimeRemaining(hours, minutes),
                              style: AppTextStyles.caption.copyWith(
                                color: kMuted,
                              ),
                            )
                          else
                            _StatusChip(
                              label: l.challengeExpired,
                              color: kMuted,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Wager badge
                if (challenge.hasWager) ...[
                  const SizedBox(width: Spacing.sm),
                  _WagerBadge(amount: challenge.wager, brightness: brightness),
                ],
              ],
            ),

            // Completed: score comparison
            if (challenge.status == ChallengeStatus.completed) ...[
              const SizedBox(height: Spacing.sm),
              _ScoreComparison(
                challenge: challenge,
                isReceived: isReceived,
                textColor: textColor,
                brightness: brightness,
              ),
            ],

            // Received pending: accept / decline buttons
            if (isReceived &&
                challenge.status == ChallengeStatus.pending &&
                !challenge.isExpired) ...[
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: l.challengeAccept,
                      button: true,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(challengeProvider.notifier)
                            .acceptChallenge(challenge.id),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: challengeAccent,
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusSm),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l.challengeAccept,
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Semantics(
                      label: l.challengeDecline,
                      button: true,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(challengeProvider.notifier)
                            .declineChallenge(challenge.id),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusSm),
                            border: Border.all(
                              color: kMuted.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l.challengeDecline,
                            style: AppTextStyles.label.copyWith(
                              color: kMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Sent: status chip
            if (!isReceived && challenge.status != ChallengeStatus.completed) ...[
              const SizedBox(height: Spacing.sm),
              _StatusChip(
                label: _statusLabel(challenge.status, l),
                color: _statusColor(challenge.status, brightness),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(ChallengeStatus status, dynamic l) => switch (status) {
    ChallengeStatus.pending => l.challengePending,
    ChallengeStatus.active => l.challengeActive,
    ChallengeStatus.completed => l.challengeCompleted,
    ChallengeStatus.expired => l.challengeExpired,
    ChallengeStatus.declined => l.challengeDeclinedStatus,
    ChallengeStatus.cancelled => l.challengeCancelled,
  };

  Color _statusColor(ChallengeStatus status, Brightness brightness) =>
      switch (status) {
        ChallengeStatus.pending => resolveColor(
          brightness,
          dark: kChallengePrimary,
          light: kChallengePrimaryLight,
        ),
        ChallengeStatus.active => kCyan,
        _ => kMuted,
      };
}

// ─── Helper Widgets ────────────────────────────────────────────────────────

class _ChallengeAvatar extends StatelessWidget {
  const _ChallengeAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: kChallengePrimary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: kChallengePrimary,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _WagerBadge extends StatelessWidget {
  const _WagerBadge({
    required this.amount,
    required this.brightness,
  });

  final int amount;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final badgeColor = resolveColor(
      brightness,
      dark: kAmber,
      light: kAmber,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(UIConstants.radiusXs),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_rounded, size: 12, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            '$amount',
            style: AppTextStyles.caption.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(UIConstants.radiusXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScoreComparison extends StatelessWidget {
  const _ScoreComparison({
    required this.challenge,
    required this.isReceived,
    required this.textColor,
    required this.brightness,
  });

  final Challenge challenge;
  final bool isReceived;
  final Color textColor;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final senderScore = challenge.senderScore ?? 0;
    final recipientScore = challenge.recipientScore ?? 0;
    final senderWon = senderScore > recipientScore;
    final isDraw = senderScore == recipientScore;

    final winColor = resolveColor(
      brightness,
      dark: kChallengeWin,
      light: kChallengeWinLight,
    );
    final loseColor = resolveColor(
      brightness,
      dark: kChallengeLose,
      light: kChallengeLoseLight,
    );

    final senderColor = isDraw ? textColor : (senderWon ? winColor : loseColor);
    final recipientColor =
        isDraw ? textColor : (senderWon ? loseColor : winColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(UIConstants.radiusXs),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            challenge.senderUsername,
            style: AppTextStyles.caption.copyWith(
              color: senderColor,
              fontWeight: senderWon ? FontWeight.w700 : FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            '$senderScore',
            style: AppTextStyles.body.copyWith(
              color: senderColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            child: Text(
              ':',
              style: AppTextStyles.body.copyWith(color: kMuted),
            ),
          ),
          Text(
            '$recipientScore',
            style: AppTextStyles.body.copyWith(
              color: recipientColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: Text(
              challenge.recipientUsername ?? '?',
              style: AppTextStyles.caption.copyWith(
                color: recipientColor,
                fontWeight: !senderWon && !isDraw
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mode Icon Helper ──────────────────────────────────────────────────────

IconData _modeIcon(String mode) => switch (mode) {
  'classic' => Icons.grid_view_rounded,
  'colorChef' => Icons.palette_rounded,
  'timeTrial' => Icons.timer_rounded,
  'zen' => Icons.self_improvement_rounded,
  'daily' => Icons.calendar_today_rounded,
  'level' => Icons.stairs_rounded,
  'duel' => Icons.sports_mma_rounded,
  _ => Icons.games_rounded,
};
