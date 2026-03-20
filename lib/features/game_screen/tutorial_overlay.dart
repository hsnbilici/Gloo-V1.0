import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

/// 3-step tutorial overlay shown during first game.
/// Each step advances on user action (onSlotTap, onCellTap, onCellTap).
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    super.key,
    required this.step,
    required this.message,
    required this.onDismiss,
    this.dismissLabel,
    this.pointDown = false,
  });

  final int step;
  final String message;
  final VoidCallback onDismiss;
  final String? dismissLabel;
  final bool pointDown;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: pointDown ? 200 : null,
      top: pointDown ? null : 100,
      child: IgnorePointer(
        ignoring: dismissLabel == null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!pointDown)
              Icon(Icons.arrow_upward_rounded,
                      color: kCyan.withValues(alpha: 0.6), size: 28)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .slideY(begin: 0, end: -0.3, duration: 600.ms),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: kSurfaceDark.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: kCyan.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: kCyan.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  if (dismissLabel != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: kCyan.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusSm),
                          border:
                              Border.all(color: kCyan.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          dismissLabel!,
                          style: const TextStyle(
                            color: kCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: pointDown ? 0.1 : -0.1,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
                ),
            if (pointDown)
              Icon(Icons.arrow_downward_rounded,
                      color: kCyan.withValues(alpha: 0.6), size: 28)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .slideY(begin: 0, end: 0.3, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
