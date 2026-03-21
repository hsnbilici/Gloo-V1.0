import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/utils/motion_utils.dart';

/// 3-step tutorial overlay shown during first game.
/// Each step advances on user action (onSlotTap, onCellTap, onCellTap).
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    super.key,
    required this.step,
    required this.message,
    required this.onDismiss,
    this.dismissLabel,
    this.skipLabel,
    this.pointDown = false,
  });

  final int step;
  final String message;
  final VoidCallback onDismiss;
  final String? dismissLabel;
  final String? skipLabel;
  final bool pointDown;

  @override
  Widget build(BuildContext context) {
    final rm = shouldReduceMotion(context);
    return Positioned(
      left: 24,
      right: 24,
      bottom: pointDown ? 200 : null,
      top: pointDown ? null : 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Skip butonu — tum adimlarda gorunur
          if (skipLabel != null && dismissLabel == null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Semantics(
                label: skipLabel,
                button: true,
                child: GestureDetector(
                  onTap: onDismiss,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      skipLabel!,
                      style: TextStyle(
                        color: kMuted.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!pointDown)
            Icon(Icons.arrow_upward_rounded,
                    color: kCyan.withValues(alpha: 0.6), size: 28)
                .animateOrSkip(reduceMotion: rm)
                .slideY(begin: 0, end: -0.3, duration: 600.ms),
          IgnorePointer(
            ignoring: dismissLabel == null,
            child: Container(
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
            ).animateOrSkip(reduceMotion: rm).fadeIn(duration: 300.ms).slideY(
                  begin: pointDown ? 0.1 : -0.1,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
          if (pointDown)
            Icon(Icons.arrow_downward_rounded,
                    color: kCyan.withValues(alpha: 0.6), size: 28)
                .animateOrSkip(reduceMotion: rm, delay: null)
                .slideY(begin: 0, end: 0.3, duration: 600.ms),
        ],
      ),
    );
  }
}
