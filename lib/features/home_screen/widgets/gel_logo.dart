import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';

class GelLogo extends StatelessWidget {
  const GelLogo({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final cyanColor = resolveColor(brightness, dark: kCyan, light: kCyanLight);
    final classicColor = resolveColor(
        brightness, dark: kColorClassic, light: kColorClassicLight);
    final mutedColor =
        resolveColor(brightness, dark: kMuted, light: kMutedLight);

    // Light temada neon glow gereksiz — gölgeleri azalt
    final shadowAlpha1 = isDark ? 0.8 : 0.25;
    final shadowAlpha2 = isDark ? 0.3 : 0.10;

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
                  color: cyanColor,
                  shadows: [
                    Shadow(
                        color: cyanColor.withValues(alpha: shadowAlpha1),
                        blurRadius: 18),
                    Shadow(
                        color: cyanColor.withValues(alpha: shadowAlpha2),
                        blurRadius: 45),
                  ],
                ),
              ),
              TextSpan(
                text: 'oo',
                style: TextStyle(
                  color: classicColor,
                  shadows: [
                    Shadow(
                        color: classicColor.withValues(alpha: shadowAlpha1),
                        blurRadius: 18),
                    Shadow(
                        color: classicColor.withValues(alpha: shadowAlpha2),
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
                width: 28,
                height: 1,
                color: mutedColor.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Text(
              subtitle,
              style: TextStyle(
                color: mutedColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.5,
              ),
            ),
            const SizedBox(width: 10),
            Container(
                width: 28,
                height: 1,
                color: mutedColor.withValues(alpha: 0.4)),
          ],
        ),
      ],
    );
  }
}
