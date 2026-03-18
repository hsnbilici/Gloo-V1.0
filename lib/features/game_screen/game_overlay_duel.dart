import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../providers/pvp_provider.dart';

// ─── Duel HUD: geri sayım + rakip skoru ──────────────────────────────────────

class DuelHud extends StatelessWidget {
  const DuelHud({
    super.key,
    required this.remainingSeconds,
    required this.ref,
  });

  final int remainingSeconds;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final duelState = ref.watch(duelProvider);
    const duelDuration = 120;

    final ratio = (remainingSeconds / duelDuration).clamp(0.0, 1.0);

    final Color barColor;
    final bool isPulsing;
    if (remainingSeconds <= 10) {
      barColor = kColorClassic;
      isPulsing = true;
    } else if (remainingSeconds <= 30) {
      barColor = kColorTimeTrial;
      isPulsing = false;
    } else {
      barColor = kColorClassic;
      isPulsing = false;
    }

    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    final timeLabel = '$mins:${secs.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UIConstants.radiusXs),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    Container(
                      height: 4,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.linear,
                        height: 4,
                        decoration: BoxDecoration(
                          color: barColor,
                          boxShadow: [
                            BoxShadow(
                              color: barColor.withValues(
                                  alpha: isPulsing ? 0.90 : 0.60),
                              blurRadius: isPulsing ? 10 : 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: barColor,
                fontSize: isPulsing ? 13 : 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              child: Text(timeLabel),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              duelState.isBot ? Icons.smart_toy_rounded : Icons.person_rounded,
              color: Colors.white.withValues(alpha: 0.40),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'Rakip: ${duelState.opponentScore}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
