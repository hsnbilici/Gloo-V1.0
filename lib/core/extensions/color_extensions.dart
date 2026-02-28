import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

extension GelColorExtension on GelColor {
  /// Jel glow efekti için daha parlak ton
  Color get glowColor => displayColor.withValues(alpha: 0.6);

  /// Seçili durum için yarı şeffaf vurgulama
  Color get selectionOverlay => displayColor.withValues(alpha: 0.25);

  /// Karanlık yüzey için kontrast renk (metin, ikon)
  Color get onDark {
    final hsl = HSLColor.fromColor(displayColor);
    return hsl.withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0)).toColor();
  }
}

extension ColorLerp on Color {
  /// İki renk arasında smooth interpolation — birleşim animasyonu için
  Color lerpTo(Color target, double t) => Color.lerp(this, target, t)!;
}
