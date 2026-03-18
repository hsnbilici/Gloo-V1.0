import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../home_screen/widgets/dialogs.dart';

class SharePromptDialog extends StatelessWidget {
  const SharePromptDialog({
    super.key,
    required this.title,
    required this.message,
    required this.shareLabel,
    required this.skipLabel,
    required this.onShare,
    required this.onSkip,
  });

  final String title;
  final String message;
  final String shareLabel;
  final String skipLabel;
  final VoidCallback onShare;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kSurfaceDark,
          borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
          border: Border.all(color: kCyan.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: kCyan.withValues(alpha: 0.18),
              blurRadius: 40,
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
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: kCyan.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: kCyan.withValues(alpha: 0.30)),
              ),
              child: const Icon(
                Icons.ios_share_rounded,
                color: kCyan,
                size: 26,
              ),
            ).animate().scale(
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
                color: kCyan,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: DialogBtn(
                    label: skipLabel,
                    color: kMuted,
                    filled: false,
                    onTap: onSkip,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DialogBtn(
                    label: shareLabel,
                    color: kCyan,
                    filled: true,
                    onTap: onShare,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
