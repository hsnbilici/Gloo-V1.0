import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/rtl_helpers.dart';

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
    final textColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
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
        color: value ? accentColor.withValues(alpha: 0.06) : inactiveBg,
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(
          color: value ? accentColor.withValues(alpha: 0.25) : inactiveBorder,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class ThemeSelectorTile extends StatefulWidget {
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

  @override
  State<ThemeSelectorTile> createState() => _ThemeSelectorTileState();
}

class _ThemeSelectorTileState extends State<ThemeSelectorTile> {
  bool _hovered = false;

  String _modeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => widget.systemLabel,
      ThemeMode.light => widget.lightLabel,
      ThemeMode.dark => widget.darkLabel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    return Semantics(
      label: _modeLabel(widget.currentMode),
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.accentColor
                  .withValues(alpha: _hovered ? 0.09 : 0.05),
              borderRadius: BorderRadius.circular(UIConstants.radiusTile),
              border: Border.all(
                  color: widget.accentColor
                      .withValues(alpha: _hovered ? 0.35 : 0.22)),
            ),
            child: Row(
              children: [
                Icon(Icons.brightness_6_rounded,
                    color: widget.accentColor, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _modeLabel(widget.currentMode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  directionalChevronIcon(Directionality.of(context)),
                  color: widget.accentColor.withValues(alpha: 0.70),
                  size: 18,
                ),
              ],
            ),
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
      (ThemeMode.light, Icons.light_mode_rounded, lightLabel),
      (ThemeMode.dark, Icons.dark_mode_rounded, darkLabel),
    ];
    final brightness = Theme.of(context).brightness;
    final sheetBg =
        resolveColor(brightness, dark: kSurfaceDark, light: kSurfaceLight);
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

class _ThemeModeChip extends StatefulWidget {
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
  State<_ThemeModeChip> createState() => _ThemeModeChipState();
}

class _ThemeModeChipState extends State<_ThemeModeChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final unselectedBg = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: _hovered ? 0.07 : 0.04),
      light: kCardBgLight,
    );
    final unselectedBorder = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: _hovered ? 0.15 : 0.09),
      light: kCardBorderLight,
    );
    final unselectedText =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          // AnimatedContainer kept intentionally: animates isSelected (selection
          // state transition), not just hover. Hover changes are blended within
          // the same 180ms transition.
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? kThemeTertiary.withValues(alpha: 0.14)
                  : unselectedBg,
              borderRadius: BorderRadius.circular(UIConstants.radiusMd),
              border: Border.all(
                color: widget.isSelected
                    ? kThemeTertiary.withValues(alpha: 0.55)
                    : unselectedBorder,
                width: widget.isSelected ? 1.5 : 1,
              ),
              boxShadow: widget.isSelected
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
                  widget.icon,
                  color: widget.isSelected ? kThemeTertiary : kMuted,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: TextStyle(
                    color:
                        widget.isSelected ? kThemeTertiary : unselectedText,
                    fontSize: 14,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
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
    final labelColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final valueColor =
        resolveColor(brightness, dark: kMuted, light: kTextSecondaryLight);
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
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
