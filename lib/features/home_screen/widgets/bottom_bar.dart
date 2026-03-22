import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../audio/sound_bank.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';
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
    final brightness = Theme.of(context).brightness;
    final containerColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.04),
      light: Colors.black.withValues(alpha: 0.04),
    );
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.08),
      light: kCardBorderLight,
    );
    final dividerColor = borderColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomItem(
            icon: Icons.leaderboard_rounded,
            label: leaderboardLabel,
            onTap: () => context.push('/leaderboard'),
          ),
          Container(width: 1, height: 30, color: dividerColor),
          BottomItem(
            icon: Icons.auto_awesome_mosaic_rounded,
            label: collectionLabel,
            onTap: () => context.push('/collection'),
          ),
          Container(width: 1, height: 30, color: dividerColor),
          BottomItem(
            icon: Icons.storefront_rounded,
            label: shopLabel,
            onTap: () => context.push('/shop'),
          ),
          Container(width: 1, height: 30, color: dividerColor),
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

class BottomItem extends StatefulWidget {
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
  State<BottomItem> createState() => _BottomItemState();
}

class _BottomItemState extends State<BottomItem> {
  bool _pressed = false;
  bool _hovered = false;
  final _soundBank = SoundBank();

  void _updateState({bool? pressed, bool? hovered}) {
    final newPressed = pressed ?? _pressed;
    final newHovered = hovered ?? _hovered;
    if (newPressed == _pressed && newHovered == _hovered) return;
    setState(() {
      _pressed = newPressed;
      _hovered = newHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final active = _pressed || _hovered;
    final iconColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: active ? 0.90 : 0.60),
      light: active ? kTextPrimaryLight : kTextSecondaryLight,
    );
    final textColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: active ? 1.0 : 0.70),
      light: kTextPrimaryLight,
    );

    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        onEnter: (_) => _updateState(hovered: true),
        onExit: (_) => _updateState(hovered: false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _updateState(pressed: true),
          onTapUp: (_) {
            _updateState(pressed: false);
            _soundBank.onButtonTap();
            widget.onTap();
          },
          onTapCancel: () => _updateState(pressed: false),
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: Container(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _hovered && !_pressed
                    ? resolveColor(brightness,
                        dark: Colors.white.withValues(alpha: 0.06),
                        light: Colors.black.withValues(alpha: 0.04))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: iconColor, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
