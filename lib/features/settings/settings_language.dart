import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../providers/locale_provider.dart';

// ─── Dil seçim satırı ────────────────────────────────────────────────────────

class LanguageTile extends StatefulWidget {
  const LanguageTile({
    super.key,
    required this.label,
    required this.currentLocale,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final Locale currentLocale;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<LanguageTile> {
  bool _hovered = false;

  String get _currentNativeName {
    for (final lang in kLanguageOptions) {
      if (lang.code == widget.currentLocale.languageCode) return lang.nativeName;
    }
    return widget.currentLocale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    return Semantics(
      label: widget.label,
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
                Icon(Icons.language_rounded,
                    color: widget.accentColor, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  _currentNativeName,
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
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

// ─── Dil seçim bottom sheet ──────────────────────────────────────────────────

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({
    super.key,
    required this.currentLocale,
    required this.onSelect,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onSelect;

  @override
  Widget build(BuildContext context) {
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.0,
            ),
            itemCount: kLanguageOptions.length,
            itemBuilder: (context, i) {
              final lang = kLanguageOptions[i];
              final isSelected = lang.code == currentLocale.languageCode;
              return _LangChip(
                code: lang.code.toUpperCase(),
                nativeName: lang.nativeName,
                isSelected: isSelected,
                onTap: () => onSelect(Locale(lang.code)),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Dil chip'i ──────────────────────────────────────────────────────────────

class _LangChip extends StatefulWidget {
  const _LangChip({
    required this.code,
    required this.nativeName,
    required this.isSelected,
    required this.onTap,
  });

  final String code;
  final String nativeName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_LangChip> createState() => _LangChipState();
}

class _LangChipState extends State<_LangChip> {
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
      label: widget.nativeName,
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
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? kColorChef.withValues(alpha: 0.14)
                  : unselectedBg,
              borderRadius: BorderRadius.circular(UIConstants.radiusMd),
              border: Border.all(
                color: widget.isSelected
                    ? kColorChef.withValues(alpha: 0.55)
                    : unselectedBorder,
                width: widget.isSelected ? 1.5 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: kColorChef.withValues(alpha: 0.18),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.nativeName,
                  style: TextStyle(
                    color:
                        widget.isSelected ? kColorChef : unselectedText,
                    fontSize: 12,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.code,
                  style: TextStyle(
                    color: widget.isSelected
                        ? kColorChef.withValues(alpha: 0.75)
                        : kMuted.withValues(alpha: 0.60),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
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
