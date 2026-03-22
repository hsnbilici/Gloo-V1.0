import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../shared/glow_orb.dart';

class SeasonBackground extends StatelessWidget {
  const SeasonBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final isDark = brightness == Brightness.dark;
    final orbAlpha = isDark ? 1.0 : 0.45;

    return ExcludeSemantics(
      child: Stack(
        children: [
          Container(color: bgColor),
          Positioned(
            top: -100,
            left: -50,
            child: GlowOrb(size: 320, color: kGold, opacity: 0.06 * orbAlpha),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: GlowOrb(size: 260, color: kPink, opacity: 0.05 * orbAlpha),
          ),
        ],
      ),
    );
  }
}
