import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';
import '../../shared/glow_orb.dart';

class DeepBackground extends StatelessWidget {
  const DeepBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        // Sol-üst cyan orb
        const Positioned(
          top: -130,
          left: -80,
          child: GlowOrb(size: 380, color: kCyan, opacity: 0.09),
        ),
        // Sağ-alt coral orb
        const Positioned(
          bottom: -100,
          right: -60,
          child: GlowOrb(size: 300, color: kColorClassic, opacity: 0.08),
        ),
        // Orta-sağ violet orb
        const Positioned(
          top: 250,
          right: -50,
          child: GlowOrb(size: 220, color: kColorZen, opacity: 0.06),
        ),
      ],
    );
  }
}
