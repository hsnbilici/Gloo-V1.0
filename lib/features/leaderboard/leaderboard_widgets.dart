import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/l10n/app_strings.dart';

class ModeTabs extends StatelessWidget {
  const ModeTabs({
    super.key,
    required this.controller,
    required this.classicLabel,
    required this.timeTrialLabel,
    this.pvpLabel,
    this.friendsLabel,
  });

  final TabController controller;
  final String classicLabel;
  final String timeTrialLabel;
  final String? pvpLabel;
  final String? friendsLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.04),
        light: kCardBgLight);
    final borderClr = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.08),
        light: kCardBorderLight);
    final unselectedClr = resolveColor(brightness,
        dark: kMuted, light: kMutedLight);

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: borderClr),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: kCyan.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(UIConstants.radiusMd),
          border: Border.all(color: kCyan.withValues(alpha: 0.40)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelColor: kCyan,
        unselectedLabelColor: unselectedClr,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: classicLabel),
          Tab(text: timeTrialLabel),
          if (pvpLabel != null) Tab(text: pvpLabel!),
          if (friendsLabel != null) Tab(text: friendsLabel!),
        ],
      ),
    );
  }
}

class FilterRow extends StatelessWidget {
  const FilterRow({
    super.key,
    required this.weeklyLabel,
    required this.allTimeLabel,
    required this.isWeekly,
    required this.onChanged,
  });

  final String weeklyLabel;
  final String allTimeLabel;
  final bool isWeekly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LeaderboardFilterChip(
          label: weeklyLabel,
          isSelected: isWeekly,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 8),
        LeaderboardFilterChip(
          label: allTimeLabel,
          isSelected: !isWeekly,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class LeaderboardFilterChip extends StatelessWidget {
  const LeaderboardFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final unselectedBg = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.03),
        light: kCardBgLight);
    final unselectedBorder = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.08),
        light: kCardBorderLight);
    final unselectedText = resolveColor(brightness,
        dark: kMuted, light: kMutedLight);

    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? kCyan.withValues(alpha: 0.12)
                : unselectedBg,
            borderRadius: BorderRadius.circular(UIConstants.radiusSm),
            border: Border.all(
              color: isSelected
                  ? kCyan.withValues(alpha: 0.40)
                  : unselectedBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? kCyan : unselectedText,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class UserRankBanner extends StatelessWidget {
  const UserRankBanner({
    super.key,
    required this.rank,
    required this.label,
    this.score,
    this.isPvp = false,
    this.strings,
  });

  final int rank;
  final String label;
  final int? score;
  final bool isPvp;
  final AppStrings? strings;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.70),
        light: kTextSecondaryLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kCyan.withValues(alpha: 0.10),
            kCyan.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(color: kCyan.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kCyan.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: kCyan.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: kCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (score != null)
            Text(
              isPvp
                  ? (strings?.eloDisplay(score!) ?? '${score!} ELO')
                  : _formatScore(score!),
              style: const TextStyle(
                color: kCyan,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }

  String _formatScore(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}

class ScoreRow extends StatelessWidget {
  const ScoreRow({
    super.key,
    required this.rank,
    required this.username,
    required this.score,
    this.isCurrentUser = false,
    this.isPvp = false,
    this.strings,
  });

  final int rank;
  final String username;
  final int score;
  final bool isCurrentUser;
  final bool isPvp;
  final AppStrings? strings;

  Color get _rankColor {
    if (rank == 1) return kGold;
    if (rank == 2) return kSilver;
    if (rank == 3) return kBronze;
    return kMuted;
  }

  IconData? get _rankIcon {
    if (rank <= 3) return Icons.emoji_events_rounded;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final defaultTextColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.80),
        light: kTextPrimaryLight);
    final topTextColor = resolveColor(brightness,
        dark: Colors.white, light: kTextPrimaryLight);
    final defaultBg = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.03),
        light: kCardBgLight);
    final defaultBorder = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.06),
        light: kCardBorderLight);
    final mutedColor = resolveColor(brightness,
        dark: kMuted, light: kMutedLight);

    final Color bgColor;
    final Color borderColor;
    if (isCurrentUser) {
      bgColor = kCyan.withValues(alpha: 0.08);
      borderColor = kCyan.withValues(alpha: 0.30);
    } else if (rank <= 3) {
      bgColor = _rankColor.withValues(alpha: 0.06);
      borderColor = _rankColor.withValues(alpha: 0.22);
    } else {
      bgColor = defaultBg;
      borderColor = defaultBorder;
    }

    final scoreText = isPvp
        ? (strings?.eloDisplay(score) ?? '$score ELO')
        : _formatScore(score);

    return Semantics(
      label: '#$rank $username $scoreText',
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: _rankIcon != null
                  ? Icon(_rankIcon, color: _rankColor, size: 18)
                  : Text(
                      '$rank',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      username,
                      style: TextStyle(
                        color: isCurrentUser
                            ? kCyan
                            : rank <= 3
                                ? topTextColor
                                : defaultTextColor,
                        fontSize: 14,
                        fontWeight: (rank <= 3 || isCurrentUser)
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrentUser)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: kCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: kCyan,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              scoreText,
              style: TextStyle(
                color: isCurrentUser
                    ? kCyan
                    : rank <= 3
                        ? _rankColor
                        : mutedColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatScore(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}
