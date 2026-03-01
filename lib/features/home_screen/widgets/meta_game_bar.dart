import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/ui_constants.dart';

class MetaGameBar extends StatelessWidget {
  const MetaGameBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MetaItem(
            icon: Icons.terrain_rounded,
            label: 'Ada',
            color: const Color(0xFF3CFF8B),
            onTap: () => context.push('/island'),
          ),
          Container(
              width: 1,
              height: 28,
              color: Colors.white.withValues(alpha: 0.06)),
          MetaItem(
            icon: Icons.person_rounded,
            label: 'Karakter',
            color: const Color(0xFFB080FF),
            onTap: () => context.push('/character'),
          ),
          Container(
              width: 1,
              height: 28,
              color: Colors.white.withValues(alpha: 0.06)),
          MetaItem(
            icon: Icons.military_tech_rounded,
            label: 'Sezon',
            color: const Color(0xFFFFD700),
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
    return GestureDetector(
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
    );
  }
}
