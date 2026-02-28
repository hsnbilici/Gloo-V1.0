import 'package:flutter/material.dart';

/// Radyal degrade ile oluşturulan dairesel parıltı efekti.
/// home_screen ve game_over_overlay tarafından paylaşılır.
class GlowOrb extends StatelessWidget {
  const GlowOrb({
    super.key,
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
