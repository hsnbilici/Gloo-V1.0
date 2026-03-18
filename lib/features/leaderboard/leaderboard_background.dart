import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../shared/glow_orb.dart';

class LeaderboardBackground extends StatelessWidget {
  const LeaderboardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -100,
          left: -60,
          child: GlowOrb(size: 280, color: kColorClassic, opacity: 0.06),
        ),
        const Positioned(
          bottom: -80,
          right: -50,
          child: GlowOrb(size: 240, color: kCyan, opacity: 0.05),
        ),
      ],
    );
  }
}
