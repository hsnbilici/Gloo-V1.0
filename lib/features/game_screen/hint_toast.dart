import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/ui_constants.dart';

class HintToast extends StatelessWidget {
  const HintToast({super.key, required this.msg});

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(UIConstants.radiusXl),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.40),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 120.ms).slideY(
        begin: 0.3, end: 0, duration: 200.ms, curve: Curves.easeOutCubic);
  }
}
