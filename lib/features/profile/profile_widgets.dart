import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/l10n/app_strings.dart';

// ─── Synthesis colors (8 non-primary GelColor values) ────────────────────────

const List<GelColor> _kSynthesisColors = [
  GelColor.orange,
  GelColor.green,
  GelColor.purple,
  GelColor.pink,
  GelColor.lightBlue,
  GelColor.lime,
  GelColor.brown,
  GelColor.maroon,
];

// ─── Helpers ─────────────────────────────────────────────────────────────────

String formatStat(int v) {
  if (v >= 1000) {
    final k = v / 1000;
    // Show one decimal only when meaningful (e.g. 1.2K but 10K)
    return k >= 10 ? '${k.round()}K' : '${k.toStringAsFixed(1)}K';
  }
  return v.toString();
}

Color _avatarColor(String name) {
  if (name.isEmpty) return kCyan;
  var hash = 0;
  for (var i = 0; i < name.length; i++) {
    hash = name.codeUnitAt(i) + ((hash << 5) - hash);
  }
  const palette = [kCyan, kGold, kGreen, kOrange, kPink];
  return palette[hash.abs() % palette.length];
}

IconData modeIcon(String mode) => switch (mode) {
      'classic' => Icons.grid_view_rounded,
      'colorChef' => Icons.palette_rounded,
      'timeTrial' => Icons.timer_rounded,
      'zen' => Icons.self_improvement_rounded,
      'daily' => Icons.calendar_today_rounded,
      'level' => Icons.stairs_rounded,
      'duel' => Icons.sports_mma_rounded,
      _ => Icons.games_rounded,
    };

// ─── ProfileHeader ───────────────────────────────────────────────────────────

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.username,
    required this.friendCode,
    required this.brightness,
    this.onEditTap,
    this.followButton,
    this.isMutual = false,
    this.mutualLabel = 'Mutual',
  });

  final String username;
  final String friendCode;
  final Brightness brightness;

  /// If non-null, an edit icon is shown (own profile).
  final VoidCallback? onEditTap;

  /// If non-null, rendered to the right of the username row (other profile).
  final Widget? followButton;

  final bool isMutual;

  /// Localized label shown in the mutual badge.
  final String mutualLabel;

  @override
  Widget build(BuildContext context) {
    final textColor = resolveColor(brightness,
        dark: Colors.white, light: kTextPrimaryLight);
    final mutedColor = resolveColor(brightness, dark: kMuted, light: kMutedLight);
    final color = _avatarColor(username);
    final letter = username.isEmpty ? '?' : username[0].toUpperCase();

    return Column(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        // Username row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                username.isEmpty ? 'Player' : username,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onEditTap != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onEditTap,
                child: const Icon(Icons.edit_rounded, size: 16, color: kCyan),
              ),
            ],
            if (isMutual) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                ),
                child: Text(
                  mutualLabel,
                  style: const TextStyle(
                    color: kGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (followButton != null) ...[
          const SizedBox(height: Spacing.xs),
          followButton!,
        ],
        const SizedBox(height: 4),
        // Friend code
        Text(
          friendCode.isNotEmpty ? friendCode : '---',
          style: TextStyle(
            color: mutedColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── StatCards ────────────────────────────────────────────────────────────────

class StatCards extends StatelessWidget {
  const StatCards({
    super.key,
    required this.classicBest,
    required this.timeTrialBest,
    required this.elo,
    required this.totalGames,
    required this.linesCleared,
    required this.syntheses,
    required this.brightness,
    required this.labels,
  });

  final int classicBest;
  final int timeTrialBest;
  final int elo;
  final int totalGames;
  final int linesCleared;
  final int syntheses;
  final Brightness brightness;

  /// 6 labels in order: Classic Best, TimeTrial Best, ELO,
  /// Total Games, Lines Cleared, Syntheses.
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == 6, 'StatCards requires exactly 6 labels');

    final surfaceColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.06), light: kCardBgLight);
    final borderColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.1), light: kCardBorderLight);

    final row1 = [
      _StatData(Icons.grid_view_rounded, classicBest, labels[0], kCyan),
      _StatData(Icons.timer_rounded, timeTrialBest, labels[1], kOrange),
      _StatData(Icons.sports_mma_rounded, elo, labels[2], kGold),
    ];
    final row2 = [
      _StatData(Icons.games_rounded, totalGames, labels[3], kMuted),
      _StatData(Icons.horizontal_rule_rounded, linesCleared, labels[4], kGreen),
      _StatData(Icons.auto_awesome_rounded, syntheses, labels[5], kPink),
    ];

    return Column(
      children: [
        _buildRow(row1, surfaceColor, borderColor),
        const SizedBox(height: Spacing.sm),
        _buildRow(row2, surfaceColor, borderColor),
      ],
    );
  }

  Widget _buildRow(
      List<_StatData> items, Color surface, Color border) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: Spacing.sm),
          Expanded(child: _StatCard(data: items[i], surface: surface, border: border)),
        ],
      ],
    );
  }
}

class _StatData {
  const _StatData(this.icon, this.value, this.label, this.color);
  final IconData icon;
  final int value;
  final String label;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.data,
    required this.surface,
    required this.border,
  });

  final _StatData data;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(data.icon, size: 16, color: data.color),
          const SizedBox(height: 4),
          Text(
            formatStat(data.value),
            style: TextStyle(
              color: data.color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: TextStyle(
              color: data.color.withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── CollectionMini ──────────────────────────────────────────────────────────

class CollectionMini extends StatelessWidget {
  const CollectionMini({
    super.key,
    required this.discoveredColors,
  });

  /// Set of GelColor.name strings that the player has discovered.
  final Set<String> discoveredColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _kSynthesisColors.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _colorDot(_kSynthesisColors[i]),
        ],
      ],
    );
  }

  Widget _colorDot(GelColor gel) {
    final discovered = discoveredColors.contains(gel.name);
    final color = discovered
        ? gel.displayColor
        : kMuted.withValues(alpha: 0.15);
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: discovered
            ? Border.all(color: gel.displayColor.withValues(alpha: 0.4))
            : null,
      ),
    );
  }
}

// ─── ActivityList ────────────────────────────────────────────────────────────

class ActivityList extends StatelessWidget {
  const ActivityList({
    super.key,
    required this.scores,
    required this.emptyText,
    required this.brightness,
    required this.strings,
  });

  final List<ActivityItem> scores;
  final String emptyText;
  final Brightness brightness;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
        child: Center(
          child: Text(
            emptyText,
            style: TextStyle(
              color: resolveColor(brightness, dark: kMuted, light: kMutedLight),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final textColor = resolveColor(brightness,
        dark: Colors.white, light: kTextPrimaryLight);
    final mutedColor = resolveColor(brightness, dark: kMuted, light: kMutedLight);

    return Column(
      children: [
        for (final item in scores)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(modeIcon(item.mode), size: 16, color: mutedColor),
                const SizedBox(width: 8),
                Text(
                  formatStat(item.score),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  _relativeTime(item.playedAt, strings),
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _relativeTime(DateTime? dt, AppStrings l) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l.timeNow;
    if (diff.inMinutes < 60) return l.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l.timeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l.timeDaysAgo(diff.inDays);
    return l.timeWeeksAgo((diff.inDays / 7).floor());
  }
}

class ActivityItem {
  const ActivityItem({required this.mode, required this.score, this.playedAt});
  final String mode;
  final int score;
  final DateTime? playedAt;
}

// ─── ProfileBackButton ────────────────────────────────────────────────────────

class ProfileBackButton extends StatelessWidget {
  const ProfileBackButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color surfaceColor;
  final Color borderColor;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: semanticsLabel,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(UIConstants.radiusSm),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ),
      ),
    );
  }
}
