import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/constants/color_constants_light.dart';

void main() {
  test('resolveColor returns dark color in dark mode', () {
    expect(
      resolveColor(Brightness.dark, dark: kBgDark, light: kBgLight),
      kBgDark,
    );
  });

  test('resolveColor returns light color in light mode', () {
    expect(
      resolveColor(Brightness.light, dark: kBgDark, light: kBgLight),
      kBgLight,
    );
  });

  test('all dark constants have light counterparts', () {
    expect(kBgLight, isNotNull);
    expect(kSurfaceLight, isNotNull);
    expect(kMutedLight, isNotNull);
  });
}
