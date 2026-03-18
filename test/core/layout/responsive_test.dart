import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/layout/responsive.dart';

void main() {
  group('Breakpoint', () {
    test('phone for width < 600', () {
      expect(Breakpoint.fromWidth(375), Breakpoint.phone);
      expect(Breakpoint.fromWidth(599), Breakpoint.phone);
    });

    test('tablet for 600 <= width < 1024', () {
      expect(Breakpoint.fromWidth(600), Breakpoint.tablet);
      expect(Breakpoint.fromWidth(768), Breakpoint.tablet);
      expect(Breakpoint.fromWidth(1023), Breakpoint.tablet);
    });

    test('desktop for width >= 1024', () {
      expect(Breakpoint.fromWidth(1024), Breakpoint.desktop);
      expect(Breakpoint.fromWidth(1440), Breakpoint.desktop);
    });
  });

  group('responsiveColumns', () {
    test('phone returns phone value', () {
      expect(responsiveColumns(375, phone: 2, tablet: 4, desktop: 6), 2);
    });

    test('tablet returns tablet value', () {
      expect(responsiveColumns(768, phone: 2, tablet: 4, desktop: 6), 4);
    });

    test('desktop returns desktop value', () {
      expect(responsiveColumns(1200, phone: 2, tablet: 4, desktop: 6), 6);
    });
  });

  group('responsivePadding', () {
    test('phone returns 24', () {
      expect(responsiveHPadding(375), 24.0);
    });

    test('tablet returns 40', () {
      expect(responsiveHPadding(768), 40.0);
    });

    test('desktop returns 64', () {
      expect(responsiveHPadding(1200), 64.0);
    });
  });

  group('responsiveMaxWidth', () {
    test('phone returns double.infinity', () {
      expect(responsiveMaxWidth(375), double.infinity);
    });

    test('tablet returns 720', () {
      expect(responsiveMaxWidth(768), 720.0);
    });

    test('desktop returns 960', () {
      expect(responsiveMaxWidth(1200), 960.0);
    });
  });
}
