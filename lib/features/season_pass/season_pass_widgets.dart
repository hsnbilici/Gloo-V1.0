import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/meta/season_pass.dart';

class XpProgressBar extends StatelessWidget {
  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.currentTier,
    required this.tiers,
  });

  final int currentXp;
  final int currentTier;
  final List<SeasonTier> tiers;

  @override
  Widget build(BuildContext context) {
    int accumulated = 0;
    int nextXp = 0;
    int prevAccumulated = 0;
    for (final tier in tiers) {
      accumulated += tier.xpRequired;
      if (tier.tier == currentTier + 1) {
        nextXp = accumulated;
        prevAccumulated = accumulated - tier.xpRequired;
        break;
      }
    }
    if (nextXp == 0) nextXp = accumulated;

    final progress = nextXp > prevAccumulated
        ? ((currentXp - prevAccumulated) / (nextXp - prevAccumulated))
            .clamp(0.0, 1.0)
        : 1.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currentXp XP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Sonraki: $nextXp XP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kGold, kOrange],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TierCard extends StatelessWidget {
  const TierCard({
    super.key,
    required this.tier,
    required this.isUnlocked,
    required this.isCurrent,
    required this.claimedFree,
    required this.claimedPremium,
  });

  final SeasonTier tier;
  final bool isUnlocked;
  final bool isCurrent;
  final bool claimedFree;
  final bool claimedPremium;

  IconData _rewardIcon(SeasonRewardType type) => switch (type) {
        SeasonRewardType.gelOzu => Icons.water_drop_rounded,
        SeasonRewardType.costume => Icons.checkroom_rounded,
        SeasonRewardType.decoration => Icons.auto_awesome_rounded,
        SeasonRewardType.energy => Icons.bolt_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final borderColor = isCurrent
        ? kGold
        : isUnlocked
            ? kGreen.withValues(alpha: 0.40)
            : Colors.white.withValues(alpha: 0.08);

    return Container(
      width: 80,
      margin: const EdgeInsetsDirectional.only(end: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? kGold.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent
                  ? kGold.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Text(
                '${tier.tier}',
                style: TextStyle(
                  color: isCurrent
                      ? kGold
                      : isUnlocked
                          ? Colors.white
                          : kMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'UCRETSIZ',
                    style: TextStyle(
                      color: kCyan.withValues(alpha: 0.50),
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        _rewardIcon(tier.freeReward.type),
                        color: claimedFree
                            ? kCyan.withValues(alpha: 0.35)
                            : isUnlocked
                                ? kCyan
                                : kMuted,
                        size: 20,
                      ),
                      if (claimedFree)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: kGreen,
                          size: 14,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tier.freeReward.amount}',
                    style: TextStyle(
                      color: isUnlocked
                          ? Colors.white.withValues(alpha: 0.80)
                          : kMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          Expanded(
            child: Center(
              child: tier.premiumReward != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: kPink.withValues(alpha: 0.50),
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              _rewardIcon(tier.premiumReward!.type),
                              color: claimedPremium
                                  ? kPink.withValues(alpha: 0.35)
                                  : isUnlocked
                                      ? kPink
                                      : kMuted.withValues(alpha: 0.40),
                              size: 20,
                            ),
                            if (claimedPremium)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: kGreen,
                                size: 14,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tier.premiumReward!.amount}',
                          style: TextStyle(
                            color: isUnlocked
                                ? Colors.white.withValues(alpha: 0.60)
                                : kMuted.withValues(alpha: 0.30),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
