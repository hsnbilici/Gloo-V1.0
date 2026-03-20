import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/game_mode.dart';
import '../../viral/share_manager.dart';

class CalendarCard extends StatelessWidget {
  const CalendarCard({
    super.key,
    required this.accent,
    required this.dateLabel,
  });

  final Color accent;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = now.day.toString();

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.14),
            accent.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.30), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: accent.withValues(alpha: 0.50),
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: TextStyle(
              color: accent,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              height: 1,
              shadows: [
                Shadow(color: accent.withValues(alpha: 0.5), blurRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class PlayState extends StatelessWidget {
  const PlayState({super.key, required this.l, required this.accent});

  final AppStrings l;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _dateLabel(DateTime.now()),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.50),
            fontSize: 13,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        ActionBtn(
          label: l.dailyPlayButton.toString(),
          color: accent,
          filled: true,
          onTap: () => context.go('/game/${GameMode.daily.name}'),
        ),
      ],
    );
  }

  String _dateLabel(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }
}

class CompletedState extends StatelessWidget {
  const CompletedState({
    super.key,
    required this.l,
    required this.score,
    required this.accent,
    required this.dateLabel,
  });

  final AppStrings l;
  final int score;
  final Color accent;
  final String dateLabel;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kColorChef.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kColorChef.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: kColorChef.withValues(alpha: 0.10),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: kColorChef,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                l.dailyCompleted.toString().toUpperCase(),
                style: const TextStyle(
                  color: kColorChef,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l.dailyScore.toString().toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.40),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _fmt(score),
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: [
              Shadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ActionBtn(
          label: l.dailyShareResult.toString(),
          color: accent,
          filled: false,
          icon: Icons.share_rounded,
          onTap: () {
            ShareManager().shareDailyResult(
              score: score,
              dateLabel: dateLabel,
              l: l,
            );
          },
        ),
      ],
    );
  }
}

class ActionBtn extends StatelessWidget {
  const ActionBtn({
    super.key,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: filled
                ? color.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.12),
            width: filled ? 1.5 : 1,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
