import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../shared/glow_orb.dart';

class CharBackground extends StatelessWidget {
  const CharBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -100,
          right: -50,
          child: GlowOrb(size: 320, color: kLavender, opacity: 0.07),
        ),
        const Positioned(
          bottom: -80,
          left: -60,
          child: GlowOrb(size: 260, color: kGreen, opacity: 0.05),
        ),
      ],
    );
  }
}
