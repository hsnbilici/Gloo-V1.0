import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
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
    final brightness = Theme.of(context).brightness;
    final textColor = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final inactiveBg = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.03),
      light: kCardBgLight,
    );
    final inactiveBorder = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.07),
      light: kCardBorderLight,
    );
    final inactiveTrack = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.08),
      light: kCardBorderLight,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: value
            ? accentColor.withValues(alpha: 0.06)
            : inactiveBg,
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(
          color: value
              ? accentColor.withValues(alpha: 0.25)
              : inactiveBorder,
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
              style: TextStyle(
                color: textColor,
                fontSize: MediaQuery.textScalerOf(context).scale(14),
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
            inactiveTrackColor: inactiveTrack,
          ),
        ],
      ),
    );
  }
}

// ─── Tema seçim satırı ───────────────────────────────────────────────────────

class ThemeSelectorTile extends StatelessWidget {
  const ThemeSelectorTile({
    super.key,
    required this.currentMode,
    required this.systemLabel,
    required this.lightLabel,
    required this.darkLabel,
    required this.accentColor,
    required this.onTap,
  });

  final ThemeMode currentMode;
  final String systemLabel;
  final String lightLabel;
  final String darkLabel;
  final Color accentColor;
  final VoidCallback onTap;

  String _modeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => systemLabel,
      ThemeMode.light => lightLabel,
      ThemeMode.dark => darkLabel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    return Semantics(
      label: _modeLabel(currentMode),
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(UIConstants.radiusTile),
            border: Border.all(color: accentColor.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(Icons.brightness_6_rounded, color: accentColor, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _modeLabel(currentMode),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: accentColor.withValues(alpha: 0.70),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tema seçim bottom sheet ─────────────────────────────────────────────────

class ThemeSheet extends StatelessWidget {
  const ThemeSheet({
    super.key,
    required this.currentMode,
    required this.systemLabel,
    required this.lightLabel,
    required this.darkLabel,
    required this.onSelect,
  });

  final ThemeMode currentMode;
  final String systemLabel;
  final String lightLabel;
  final String darkLabel;
  final ValueChanged<ThemeMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final options = [
      (ThemeMode.system, Icons.brightness_auto_rounded, systemLabel),
      (ThemeMode.light, Icons.light_mode_rounded, lightLabel),
      (ThemeMode.dark, Icons.dark_mode_rounded, darkLabel),
    ];
    final brightness = Theme.of(context).brightness;
    final sheetBg = resolveColor(brightness, dark: kSurfaceDark, light: kSurfaceLight);
    final handleColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.18),
      light: kCardBorderLight,
    );
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.08),
      light: kCardBorderLight,
    );
    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(UIConstants.radiusXxl)),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(UIConstants.radiusXxs),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...options.map((entry) {
            final (mode, icon, label) = entry;
            final isSelected = mode == currentMode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ThemeModeChip(
                icon: icon,
                label: label,
                isSelected: isSelected,
                onTap: () => onSelect(mode),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Tema seçenek chip'i ──────────────────────────────────────────────────────

class _ThemeModeChip extends StatelessWidget {
  const _ThemeModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final unselectedBg = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.04),
      light: kCardBgLight,
    );
    final unselectedBorder = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.09),
      light: kCardBorderLight,
    );
    final unselectedText = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? kThemeTertiary.withValues(alpha: 0.14)
                : unselectedBg,
            borderRadius: BorderRadius.circular(UIConstants.radiusMd),
            border: Border.all(
              color: isSelected
                  ? kThemeTertiary.withValues(alpha: 0.55)
                  : unselectedBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kThemeTertiary.withValues(alpha: 0.18),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? kThemeTertiary : kMuted,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? kThemeTertiary : unselectedText,
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
    final brightness = Theme.of(context).brightness;
    final surfaceBg = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.03),
      light: kCardBgLight,
    );
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.07),
      light: kCardBorderLight,
    );
    final labelColor = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final valueColor = resolveColor(brightness, dark: kMuted, light: kTextSecondaryLight);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
