import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';
import '../../../core/constants/ui_constants.dart';

class MetaGameBar extends StatelessWidget {
  const MetaGameBar({
    super.key,
    required this.islandLabel,
    required this.characterLabel,
    required this.seasonLabel,
  });

  final String islandLabel;
  final String characterLabel;
  final String seasonLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final containerColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.03),
      light: Colors.black.withValues(alpha: 0.03),
    );
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.06),
      light: kCardBorderLight,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MetaItem(
            icon: Icons.terrain_rounded,
            label: islandLabel,
            color: kGreen,
            onTap: () => context.push('/island'),
          ),
          Container(width: 1, height: 28, color: borderColor),
          MetaItem(
            icon: Icons.person_rounded,
            label: characterLabel,
            color: kLavender,
            onTap: () => context.push('/character'),
          ),
          Container(width: 1, height: 28, color: borderColor),
          MetaItem(
            icon: Icons.military_tech_rounded,
            label: seasonLabel,
            color: kGold,
            onTap: () => context.push('/season-pass'),
          ),
        ],
      ),
    );
  }
}

class MetaItem extends StatelessWidget {
  const MetaItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color.withValues(alpha: 0.80),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
