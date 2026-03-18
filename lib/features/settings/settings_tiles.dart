import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

// ─── Toggle satırı ───────────────────────────────────────────────────────────

class SettingsToggleTile extends StatelessWidget {
  const SettingsToggleTile({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.accentColor,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final Color accentColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: value
            ? accentColor.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(
          color: value
              ? accentColor.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? accentColor : kMuted,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.3),
            inactiveThumbColor: kMuted,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
          ),
        ],
      ),
    );
  }
}

// ─── Bilgi satırı ────────────────────────────────────────────────────────────

class SettingsInfoTile extends StatelessWidget {
  const SettingsInfoTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: kMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
