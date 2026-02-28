import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/game/physics/spring_physics.dart';

void main() {
  // ─── SpringPhysics ──────────────────────────────────────────────────────

  group('SpringPhysics', () {
    test('initial position equals initialValue', () {
      final spring = SpringPhysics(initialValue: 5.0);
      expect(spring.position, 5.0);
    });

    test('target equals initialValue on construction', () {
      final spring = SpringPhysics(initialValue: 3.0);
      expect(spring.target, 3.0);
    });

    test('isSettled when position equals target', () {
      final spring = SpringPhysics(initialValue: 0.0);
      expect(spring.isSettled, isTrue);
    });

    test('isSettled false after setTarget', () {
      final spring = SpringPhysics(initialValue: 0.0);
      spring.setTarget(10.0);
      expect(spring.isSettled, isFalse);
    });

    test('update moves position toward target', () {
      final spring = SpringPhysics(initialValue: 0.0);
      spring.setTarget(10.0);
      spring.update(0.016); // ~1 frame
      expect(spring.position, greaterThan(0.0));
    });

    test('update converges to target over many steps', () {
      final spring = SpringPhysics(initialValue: 0.0);
      spring.setTarget(5.0);
      for (int i = 0; i < 1000; i++) {
        spring.update(0.016);
      }
      expect(spring.position, closeTo(5.0, 0.01));
      expect(spring.isSettled, isTrue);
    });

    test('snapTo immediately sets position and target', () {
      final spring = SpringPhysics(initialValue: 0.0);
      spring.setTarget(10.0);
      spring.update(0.016);
      spring.snapTo(7.0);
      expect(spring.position, 7.0);
      expect(spring.target, 7.0);
      expect(spring.isSettled, isTrue);
    });

    test('update returns position when settled', () {
      final spring = SpringPhysics(initialValue: 2.0);
      final result = spring.update(0.016);
      expect(result, 2.0);
    });

    test('custom stiffness/damping/mass', () {
      final spring = SpringPhysics(
        stiffness: 1200.0,
        damping: 20.0,
        mass: 2.0,
        initialValue: 0.0,
      );
      spring.setTarget(10.0);
      spring.update(0.016);
      expect(spring.position, greaterThan(0.0));
    });

    test('spring oscillates past target then returns', () {
      final spring = SpringPhysics(
        stiffness: 800.0,
        damping: 5.0, // low damping = more oscillation
        initialValue: 0.0,
      );
      spring.setTarget(10.0);

      double maxPos = 0.0;
      for (int i = 0; i < 500; i++) {
        spring.update(0.016);
        if (spring.position > maxPos) maxPos = spring.position;
      }
      // With low damping, should overshoot target
      expect(maxPos, greaterThan(10.0));
    });
  });

  // ─── Spring2D ───────────────────────────────────────────────────────────

  group('Spring2D', () {
    test('initial position', () {
      final spring = Spring2D(initialX: 1.0, initialY: 2.0);
      expect(spring.x.position, 1.0);
      expect(spring.y.position, 2.0);
    });

    test('isSettled when both axes settled', () {
      final spring = Spring2D(initialX: 0.0, initialY: 0.0);
      expect(spring.isSettled, isTrue);
    });

    test('isSettled false when one axis not settled', () {
      final spring = Spring2D(initialX: 0.0, initialY: 0.0);
      spring.x.setTarget(10.0);
      expect(spring.isSettled, isFalse);
    });

    test('setTarget sets both axes', () {
      final spring = Spring2D();
      spring.setTarget(5.0, 3.0);
      expect(spring.x.target, 5.0);
      expect(spring.y.target, 3.0);
    });

    test('update returns tuple of positions', () {
      final spring = Spring2D(initialX: 0.0, initialY: 0.0);
      spring.setTarget(10.0, 5.0);
      final (x, y) = spring.update(0.016);
      expect(x, greaterThan(0.0));
      expect(y, greaterThan(0.0));
    });

    test('converges to target', () {
      final spring = Spring2D(initialX: 0.0, initialY: 0.0);
      spring.setTarget(5.0, 3.0);
      for (int i = 0; i < 1000; i++) {
        spring.update(0.016);
      }
      expect(spring.x.position, closeTo(5.0, 0.01));
      expect(spring.y.position, closeTo(3.0, 0.01));
      expect(spring.isSettled, isTrue);
    });
  });
}
