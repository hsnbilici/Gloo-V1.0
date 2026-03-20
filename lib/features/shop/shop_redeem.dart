import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

// ─── Redeem Code Alanı ───────────────────────────────────────────────────────

class RedeemCodeField extends StatelessWidget {
  const RedeemCodeField({
    super.key,
    required this.controller,
    required this.buttonLabel,
    required this.hintText,
    required this.enabled,
    required this.onRedeem,
  });

  final TextEditingController controller;
  final String buttonLabel;
  final String hintText;
  final bool enabled;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kCyan.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(color: kCyan.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              textCapitalization: TextCapitalization.characters,
              maxLength: 20,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 13,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
                counterText: '',
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            label: buttonLabel,
            button: true,
            enabled: enabled,
            child: GestureDetector(
            onTap: enabled ? onRedeem : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: enabled
                    ? kCyan.withValues(alpha: 0.15)
                    : kCyan.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                border: Border.all(
                  color: enabled
                      ? kCyan.withValues(alpha: 0.50)
                      : kCyan.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  color: enabled ? kCyan : kCyan.withValues(alpha: 0.35),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Toast ────────────────────────────────────────────────────────────────────

class ShopToast extends StatelessWidget {
  const ShopToast({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: kBgDark,
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.50), blurRadius: 20),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.3, end: 0, duration: 200.ms);
  }
}
