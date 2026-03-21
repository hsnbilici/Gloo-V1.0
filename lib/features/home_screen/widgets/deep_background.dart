import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';
import '../../shared/glow_orb.dart';

class DeepBackground extends StatelessWidget {
  const DeepBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final isDark = brightness == Brightness.dark;

    // Light temada orb'lar daha soluk olmalı (açık arka plan üzerinde)
    final orbAlpha = isDark ? 1.0 : 0.45;

    return Stack(
      children: [
        Container(color: bgColor),
        // Sol-üst cyan orb
        Positioned(
          top: -130,
          left: -80,
          child: GlowOrb(size: 380, color: kCyan, opacity: 0.09 * orbAlpha),
        ),
        // Sağ-alt coral orb
        Positioned(
          bottom: -100,
          right: -60,
          child: GlowOrb(
              size: 300, color: kColorClassic, opacity: 0.08 * orbAlpha),
        ),
        // Orta-sağ violet orb
        Positioned(
          top: 250,
          right: -50,
          child:
              GlowOrb(size: 220, color: kColorZen, opacity: 0.06 * orbAlpha),
        ),
      ],
    );
  }
}
