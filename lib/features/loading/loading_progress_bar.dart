import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';

class LoadingProgressBar extends StatelessWidget {
  const LoadingProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      width: 200,
      child: Stack(
        children: [
          // Background track
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          // Filled portion
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [kCyan, kGold],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D00E5FF), // kCyan alpha 0.30
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
