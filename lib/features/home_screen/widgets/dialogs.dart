import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';
import '../../../core/constants/ui_constants.dart';

class ColorblindPromptDialog extends StatelessWidget {
  const ColorblindPromptDialog({
    super.key,
    required this.title,
    required this.message,
    required this.enableLabel,
    required this.skipLabel,
    required this.onEnable,
    required this.onSkip,
  });

  final String title;
  final String message;
  final String enableLabel;
  final String skipLabel;
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dialogBg = resolveColor(brightness, dark: kBgDark, light: kSurfaceLight);
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.10),
      light: kCardBorderLight,
    );
    final titleColor = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final messageColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.60),
      light: kTextSecondaryLight,
    );
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 48,
              spreadRadius: 8,
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
                color: kColorTimeTrial.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border:
                    Border.all(color: kColorTimeTrial.withValues(alpha: 0.30)),
              ),
              child: const Icon(
                Icons.visibility_rounded,
                color: kColorTimeTrial,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: messageColor,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            DialogBtn(
              label: enableLabel,
              color: kColorTimeTrial,
              filled: true,
              onTap: onEnable,
            ),
            const SizedBox(height: 10),
            DialogBtn(
              label: skipLabel,
              color: kMuted,
              filled: false,
              onTap: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}

class AgeGateDialog extends StatelessWidget {
  const AgeGateDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.under13Label,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String under13Label;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dialogBg = resolveColor(brightness, dark: kBgDark, light: kSurfaceLight);
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.10),
      light: kCardBorderLight,
    );
    final titleColor = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final messageColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.60),
      light: kTextSecondaryLight,
    );
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 48,
              spreadRadius: 8,
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
                color: kCoral.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: kCoral.withValues(alpha: 0.30)),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: kCoral,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: messageColor,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            DialogBtn(
              label: confirmLabel,
              color: kCyan,
              filled: true,
              onTap: () => Navigator.of(context).pop(false), // not a child
            ),
            const SizedBox(height: 10),
            DialogBtn(
              label: under13Label,
              color: kMuted,
              filled: false,
              onTap: () => Navigator.of(context).pop(true), // is a child
            ),
          ],
        ),
      ),
    );
  }
}

class ConsentDialog extends StatelessWidget {
  const ConsentDialog({
    super.key,
    required this.title,
    required this.message,
    required this.acceptLabel,
    required this.declineLabel,
  });

  final String title;
  final String message;
  final String acceptLabel;
  final String declineLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dialogBg = resolveColor(brightness, dark: kBgDark, light: kSurfaceLight);
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.10),
      light: kCardBorderLight,
    );
    final titleColor = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final messageColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.60),
      light: kTextSecondaryLight,
    );
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 48,
              spreadRadius: 8,
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
                Icons.analytics_outlined,
                color: kCyan,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: messageColor,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            DialogBtn(
              label: acceptLabel,
              color: kCyan,
              filled: true,
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 10),
            DialogBtn(
              label: declineLabel,
              color: kMuted,
              filled: false,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogBtn extends StatelessWidget {
  const DialogBtn({
    super.key,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: filled
                ? color.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.08),
            width: filled ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: filled ? color : color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
