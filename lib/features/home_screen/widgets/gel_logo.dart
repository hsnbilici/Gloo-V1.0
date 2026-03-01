import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';

class GelLogo extends StatelessWidget {
  const GelLogo({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              height: 1,
            ),
            children: [
              TextSpan(
                text: 'Gl',
                style: TextStyle(
                  color: kCyan,
                  shadows: [
                    Shadow(color: kCyan.withValues(alpha: 0.8), blurRadius: 18),
                    Shadow(color: kCyan.withValues(alpha: 0.3), blurRadius: 45),
                  ],
                ),
              ),
              TextSpan(
                text: 'oo',
                style: TextStyle(
                  color: kColorClassic,
                  shadows: [
                    Shadow(
                        color: kColorClassic.withValues(alpha: 0.8),
                        blurRadius: 18),
                    Shadow(
                        color: kColorClassic.withValues(alpha: 0.3),
                        blurRadius: 45),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 28, height: 1, color: kMuted.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: kMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.5,
              ),
            ),
            const SizedBox(width: 10),
            Container(
                width: 28, height: 1, color: kMuted.withValues(alpha: 0.4)),
          ],
        ),
      ],
    );
  }
}
