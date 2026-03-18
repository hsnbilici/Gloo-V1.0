import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../shared/glow_orb.dart';

class SeasonBackground extends StatelessWidget {
  const SeasonBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -100,
          left: -50,
          child: GlowOrb(size: 320, color: kGold, opacity: 0.06),
        ),
        const Positioned(
          bottom: -80,
          right: -40,
          child: GlowOrb(size: 260, color: Color(0xFFFF69B4), opacity: 0.05),
        ),
      ],
    );
  }
}
