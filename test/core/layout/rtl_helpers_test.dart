import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/layout/rtl_helpers.dart';

void main() {
  group('directionalBackIcon', () {
    test('returns arrow_back in LTR', () {
      expect(directionalBackIcon(TextDirection.ltr), Icons.arrow_back_rounded);
    });

    test('returns arrow_forward in RTL', () {
      expect(
          directionalBackIcon(TextDirection.rtl), Icons.arrow_forward_rounded);
    });
  });

  group('directionalGradientAlignment', () {
    test('LTR: start=centerLeft, end=centerRight', () {
      final (begin, end) = directionalGradientAlignment(TextDirection.ltr);
      expect(begin, Alignment.centerLeft);
      expect(end, Alignment.centerRight);
    });

    test('RTL: start=centerRight, end=centerLeft', () {
      final (begin, end) = directionalGradientAlignment(TextDirection.rtl);
      expect(begin, Alignment.centerRight);
      expect(end, Alignment.centerLeft);
    });
  });
}
