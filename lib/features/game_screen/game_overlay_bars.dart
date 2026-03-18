import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

// ─── Doluluk çubuğu (Classic / Daily) ────────────────────────────────────────

class FillBar extends StatelessWidget {
  const FillBar(
      {super.key, required this.filledCells, required this.totalCells});

  final int filledCells;
  final int totalCells;

  @override
  Widget build(BuildContext context) {
    final ratio =
        totalCells > 0 ? (filledCells / totalCells).clamp(0.0, 1.0) : 0.0;

    final Color barColor;
    if (ratio > 0.80) {
      barColor = kColorClassic;
    } else if (ratio > 0.58) {
      barColor = kColorTimeTrial;
    } else {
      barColor = kCyan;
    }

    final pct = (ratio * 100).round();

    return Row(
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
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: barColor,
                      boxShadow: ratio > 0.58
                          ? [
                              BoxShadow(
                                color: barColor.withValues(alpha: 0.7),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$pct%',
          style: TextStyle(
            color: barColor,
            fontSize: MediaQuery.textScalerOf(context).scale(10),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Geri sayım çubuğu (Time Trial) ─────────────────────────────────────────

class CountdownBar extends StatelessWidget {
  const CountdownBar({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  final int remainingSeconds;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final ratio = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final Color barColor;
    final bool isPulsing;
    if (remainingSeconds <= 10) {
      barColor = kColorClassic;
      isPulsing = true;
    } else if (remainingSeconds <= 30) {
      barColor = kColorTimeTrial;
      isPulsing = false;
    } else {
      barColor = kCyan;
      isPulsing = false;
    }

    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    final timeLabel = mins > 0
        ? '$mins:${secs.toString().padLeft(2, '0')}'
        : '$remainingSeconds';

    return Row(
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
            fontSize:
                MediaQuery.textScalerOf(context).scale(isPulsing ? 13 : 10),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          child: Text(timeLabel),
        ),
      ],
    );
  }
}

// ─── Color Chef hedef çubuğu ─────────────────────────────────────────────────

class ChefTargetBar extends StatelessWidget {
  const ChefTargetBar({
    super.key,
    required this.targetColor,
    required this.progress,
    required this.required,
    required this.levelIndex,
  });

  final GelColor? targetColor;
  final int progress;
  final int required;
  final int levelIndex;

  @override
  Widget build(BuildContext context) {
    if (targetColor == null) return const SizedBox.shrink();

    final color = targetColor!.displayColor;
    final ratio = required > 0 ? (progress / required).clamp(0.0, 1.0) : 0.0;
    final levelNumber = levelIndex + 1;

    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 6),
            ],
          ),
        ),
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
                    height: 4, color: Colors.white.withValues(alpha: 0.07)),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  widthFactor: ratio,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.65),
                          blurRadius: 6,
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
        RichText(
          text: TextSpan(
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700),
            children: [
              TextSpan(
                text: '$progress/$required',
                style: TextStyle(color: color, letterSpacing: 0.5),
              ),
              TextSpan(
                text: '  S.$levelNumber',
                style: TextStyle(
                  color: color.withValues(alpha: 0.55),
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
