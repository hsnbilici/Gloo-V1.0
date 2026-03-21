import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/utils/motion_utils.dart';
import '../../home_screen/widgets/dialogs.dart';

class StreakRewardDialog extends StatelessWidget {
  const StreakRewardDialog({
    super.key,
    required this.streakDay,
    required this.reward,
    required this.title,
    required this.claimLabel,
    required this.onClaim,
  });

  final int streakDay;
  final int reward;
  final String title;
  final String claimLabel;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final rm = shouldReduceMotion(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: kSurfaceDark,
          borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
          border: Border.all(color: kOrangeVivid.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: kOrangeVivid.withValues(alpha: 0.25),
              blurRadius: 48,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 52),
            ).animateOrSkip(reduceMotion: rm).scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kOrangeVivid,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$streakDay 🔥  +$reward',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            )
                .animateOrSkip(reduceMotion: rm, delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 300.ms),
            const SizedBox(height: 24),
            DialogBtn(
              label: claimLabel,
              color: kOrangeVivid,
              filled: true,
              onTap: onClaim,
            ),
          ],
        ),
      ),
    );
  }
}
