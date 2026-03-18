import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/pvp/matchmaking.dart';
import '../../providers/locale_provider.dart';

// ─── Lig Rozeti ──────────────────────────────────────────────────────────────

class LeagueBadge extends ConsumerWidget {
  const LeagueBadge({super.key, required this.elo, required this.league});

  final int elo;
  final EloLeague league;

  Color get _leagueColor => switch (league) {
        EloLeague.bronze => kBronze,
        EloLeague.silver => kSilver,
        EloLeague.gold => kGold,
        EloLeague.diamond => kDiamondBlue,
        EloLeague.glooMaster => kGlooMaster,
      };

  IconData get _leagueIcon => switch (league) {
        EloLeague.bronze => Icons.shield_rounded,
        EloLeague.silver => Icons.shield_rounded,
        EloLeague.gold => Icons.shield_rounded,
        EloLeague.diamond => Icons.diamond_rounded,
        EloLeague.glooMaster => Icons.stars_rounded,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(stringsProvider);
    final color = _leagueColor;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.50), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(_leagueIcon, color: color, size: 36),
        ),
        const SizedBox(height: 12),
        Text(
          league.leagueName(l),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$elo ELO',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Istatistik chip ─────────────────────────────────────────────────────────

class PvpStatChip extends StatelessWidget {
  const PvpStatChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
