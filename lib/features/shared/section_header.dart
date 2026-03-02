import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';

/// Bolum basligi widget'i.
///
/// Iki gorunum destekler:
/// - **Varsayilan (accent bar):** Renkli dikey cubuk + baslik metni.
///   `shop_screen` ve `settings_screen` tarafindan kullanilir.
/// - **Icon + cizgi:** Ikon + baslik + yatay ayirici cizgi.
///   `quest_overlay` tarafindan kullanilir ([icon] ve [showDivider] verildiginde).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.color,
    this.icon,
    this.showDivider = false,
    this.padding,
  });

  /// Baslik metni (genellikle buyuk harf).
  final String title;

  /// Aksan rengi: cubuk/ikon/metin/cizgi icin kullanilir.
  final Color color;

  /// Verilirse accent bar yerine ikon gosterilir.
  final IconData? icon;

  /// `true` ise metnin saginda yatay ayirici cizgi cizilir.
  /// Genellikle [icon] ile birlikte kullanilir.
  final bool showDivider;

  /// Dis padding. Verilmezse [icon] olmayan varyant icin
  /// `EdgeInsets.only(top: 28, bottom: 10)`, [icon] varyanti icin `EdgeInsets.zero` kullanilir.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        (icon != null
            ? EdgeInsets.zero
            : const EdgeInsets.only(top: 28, bottom: 10));

    return Padding(
      padding: effectivePadding,
      child: icon != null ? _buildIconVariant() : _buildBarVariant(),
    );
  }

  Widget _buildBarVariant() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(UIConstants.radiusXxs),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIconVariant() {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        if (showDivider) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: color.withValues(alpha: 0.15),
            ),
          ),
        ],
      ],
    );
  }
}
