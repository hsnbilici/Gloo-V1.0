import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../providers/locale_provider.dart';

// ─── Dil seçim satırı ────────────────────────────────────────────────────────

class LanguageTile extends StatelessWidget {
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

  String get _currentNativeName {
    for (final lang in kLanguageOptions) {
      if (lang.code == currentLocale.languageCode) return lang.nativeName;
    }
    return currentLocale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    return Semantics(
      label: label,
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
              Icon(Icons.language_rounded, color: accentColor, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
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
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                directionalChevronIcon(Directionality.of(context)),
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

class _LangChip extends StatelessWidget {
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
    final unselectedText =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    return Semantics(
      label: nativeName,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color:
                isSelected ? kColorChef.withValues(alpha: 0.14) : unselectedBg,
            borderRadius: BorderRadius.circular(UIConstants.radiusMd),
            border: Border.all(
              color: isSelected
                  ? kColorChef.withValues(alpha: 0.55)
                  : unselectedBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
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
                nativeName,
                style: TextStyle(
                  color: isSelected ? kColorChef : unselectedText,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                code,
                style: TextStyle(
                  color: isSelected
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
    );
  }
}
