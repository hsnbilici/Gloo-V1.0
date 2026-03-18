import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

class ModeTabs extends StatelessWidget {
  const ModeTabs({
    super.key,
    required this.controller,
    required this.classicLabel,
    required this.timeTrialLabel,
  });

  final TabController controller;
  final String classicLabel;
  final String timeTrialLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
        unselectedLabelColor: kMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: classicLabel),
          Tab(text: timeTrialLabel),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? kCyan.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusSm),
          border: Border.all(
            color: isSelected
                ? kCyan.withValues(alpha: 0.40)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? kCyan : kMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class UserRankBanner extends StatelessWidget {
  const UserRankBanner({super.key, required this.rank, required this.label});

  final int rank;
  final String label;

  @override
  Widget build(BuildContext context) {
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
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreRow extends StatelessWidget {
  const ScoreRow({
    super.key,
    required this.rank,
    required this.username,
    required this.score,
  });

  final int rank;
  final String username;
  final int score;

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
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: rank <= 3
            ? _rankColor.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(
          color: rank <= 3
              ? _rankColor.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
        ),
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
                    style: const TextStyle(
                      color: kMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                color: rank <= 3
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.80),
                fontSize: 14,
                fontWeight: rank <= 3 ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatScore(score),
            style: TextStyle(
              color: rank <= 3 ? _rankColor : kMuted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
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
