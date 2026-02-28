import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/extensions/color_extensions.dart';

void main() {
  group('GelColorExtension', () {
    test('glowColor has alpha 0.6', () {
      for (final color in GelColor.values) {
        final glow = color.glowColor;
        expect(glow.a, closeTo(0.6, 0.01),
            reason: '${color.name}.glowColor alpha should be 0.6');
      }
    });

    test('selectionOverlay has alpha 0.25', () {
      for (final color in GelColor.values) {
        final overlay = color.selectionOverlay;
        expect(overlay.a, closeTo(0.25, 0.01),
            reason: '${color.name}.selectionOverlay alpha should be 0.25');
      }
    });

    test('onDark is lighter than displayColor', () {
      for (final color in GelColor.values) {
        final onDarkHsl = HSLColor.fromColor(color.onDark);
        final displayHsl = HSLColor.fromColor(color.displayColor);
        expect(onDarkHsl.lightness, greaterThanOrEqualTo(displayHsl.lightness),
            reason: '${color.name}.onDark should be at least as light');
      }
    });

    test('onDark lightness increase is clamped to 1.0', () {
      for (final color in GelColor.values) {
        final onDarkHsl = HSLColor.fromColor(color.onDark);
        expect(onDarkHsl.lightness, lessThanOrEqualTo(1.0));
      }
    });
  });

  group('ColorLerp', () {
    test('lerpTo at 0.0 returns original color', () {
      const a = Color(0xFFFF0000);
      const b = Color(0xFF0000FF);
      final result = a.lerpTo(b, 0.0);
      expect(result, a);
    });

    test('lerpTo at 1.0 returns target color', () {
      const a = Color(0xFFFF0000);
      const b = Color(0xFF0000FF);
      final result = a.lerpTo(b, 1.0);
      expect(result, b);
    });

    test('lerpTo at 0.5 returns midpoint', () {
      const a = Color(0xFFFF0000);
      const b = Color(0xFF0000FF);
      final result = a.lerpTo(b, 0.5);
      // Midpoint of red and blue channels
      expect((result.r * 255).round(), closeTo(128, 2));
      expect((result.b * 255).round(), closeTo(128, 2));
    });
  });
}
