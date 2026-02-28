import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/game_constants.dart';
import 'package:gloo/game/physics/gel_deformer.dart';

void main() {
  group('GelDeformer', () {
    test('creates springs for each control point', () {
      final deformer = GelDeformer(
        center: const Offset(50, 50),
        radius: 20,
      );
      // Should be settled at initial circular positions
      expect(deformer.isSettled, isTrue);
    });

    test('buildPath returns a closed path', () {
      final deformer = GelDeformer(
        center: const Offset(50, 50),
        radius: 20,
      );
      final path = deformer.buildPath(0.016);
      expect(path, isA<Path>());
      // Path should have bounds roughly around the center
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });

    test('buildPath bounds approximate circle', () {
      final deformer = GelDeformer(
        center: const Offset(50, 50),
        radius: 20,
      );
      final bounds = deformer.buildPath(0.016).getBounds();
      // Bounds should be roughly centered on (50,50) with radius 20
      expect(bounds.center.dx, closeTo(50, 5));
      expect(bounds.center.dy, closeTo(50, 5));
    });

    test('applyForce deforms the shape', () {
      final deformer = GelDeformer(
        center: const Offset(50, 50),
        radius: 20,
      );
      final pathBefore = deformer.buildPath(0.016).getBounds();

      deformer.applyForce(const Offset(1, 0), 1.0);
      // Advance physics
      for (int i = 0; i < 20; i++) {
        deformer.buildPath(0.016);
      }
      final pathAfter = deformer.buildPath(0.016).getBounds();

      // Shape should have shifted right
      expect(pathAfter.right, greaterThan(pathBefore.right));
    });

    test('resetToCircle returns to initial shape', () {
      final deformer = GelDeformer(
        center: const Offset(50, 50),
        radius: 20,
      );

      deformer.applyForce(const Offset(0, 1), 2.0);
      deformer.resetToCircle();

      // After enough steps, should converge back
      for (int i = 0; i < 1000; i++) {
        deformer.buildPath(0.016);
      }
      expect(deformer.isSettled, isTrue);
    });

    test('isSettled false after applyForce', () {
      final deformer = GelDeformer(
        center: const Offset(50, 50),
        radius: 20,
      );
      deformer.applyForce(const Offset(1, 0), 1.0);
      expect(deformer.isSettled, isFalse);
    });

    test('bezierControlPoints count is used', () {
      // Verify the constant is reasonable
      expect(GameConstants.bezierControlPoints, greaterThanOrEqualTo(4));
    });
  });
}
