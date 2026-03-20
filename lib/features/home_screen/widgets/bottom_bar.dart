import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/ui_constants.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.leaderboardLabel,
    required this.shopLabel,
    required this.settingsLabel,
    required this.collectionLabel,
  });

  final String leaderboardLabel;
  final String shopLabel;
  final String settingsLabel;
  final String collectionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomItem(
            icon: Icons.leaderboard_rounded,
            label: leaderboardLabel,
            onTap: () => context.push('/leaderboard'),
          ),
          Container(
              width: 1,
              height: 30,
              color: Colors.white.withValues(alpha: 0.08)),
          BottomItem(
            icon: Icons.collections_bookmark_rounded,
            label: collectionLabel,
            onTap: () => context.push('/collection'),
          ),
          Container(
              width: 1,
              height: 30,
              color: Colors.white.withValues(alpha: 0.08)),
          BottomItem(
            icon: Icons.storefront_rounded,
            label: shopLabel,
            onTap: () => context.push('/shop'),
          ),
          Container(
              width: 1,
              height: 30,
              color: Colors.white.withValues(alpha: 0.08)),
          BottomItem(
            icon: Icons.settings_rounded,
            label: settingsLabel,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class BottomItem extends StatelessWidget {
  const BottomItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: Colors.white.withValues(alpha: 0.60), size: 22),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
