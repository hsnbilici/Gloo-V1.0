import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';

// ─── Zen ambiyans göstergesi (skor yerine) ───────────────────────────────────

class ZenScoreIndicator extends StatelessWidget {
  const ZenScoreIndicator(
      {super.key, required this.color, required this.score});

  final Color color;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HUZUR',
          style: TextStyle(
            color: color.withValues(alpha: 0.60),
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        Row(
          children: [
            Icon(Icons.self_improvement_rounded, color: color, size: 22),
            const SizedBox(width: 4),
            Text(
              _format(score),
              style: TextStyle(
                color: color.withValues(alpha: 0.75),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _format(int s) {
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}K';
    return s.toString();
  }
}

// ─── Zen ambiyans çubuğu ─────────────────────────────────────────────────────

class ZenAmbienceBar extends StatelessWidget {
  const ZenAmbienceBar({
    super.key,
    required this.filledCells,
    required this.totalCells,
    required this.color,
  });

  final int filledCells;
  final int totalCells;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio =
        totalCells > 0 ? (filledCells / totalCells).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        Icon(Icons.water_drop_outlined,
            color: color.withValues(alpha: 0.55), size: 12),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UIConstants.radiusXs),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Container(
                    height: 3, color: Colors.white.withValues(alpha: 0.05)),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.55),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 4,
                        ),
                      ],
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
