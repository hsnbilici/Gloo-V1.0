import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/game/systems/combo_detector.dart';

void main() {
  // ─── ComboTier ──────────────────────────────────────────────────────────

  group('ComboTier', () {
    test('has 5 values', () {
      expect(ComboTier.values.length, 5);
    });
  });

  // ─── ComboEvent ─────────────────────────────────────────────────────────

  group('ComboEvent', () {
    test('none constant', () {
      expect(ComboEvent.none.size, 0);
      expect(ComboEvent.none.tier, ComboTier.none);
      expect(ComboEvent.none.multiplier, 1.0);
    });
  });

  // ─── ComboDetector ──────────────────────────────────────────────────────

  group('ComboDetector', () {
    late ComboDetector detector;

    setUp(() {
      detector = ComboDetector();
    });

    test('first clear with 1 line returns small tier', () {
      final event = detector.registerClear(1);
      expect(event.tier, ComboTier.small);
      expect(event.size, 1);
      expect(event.multiplier, 1.2);
    });

    test('chain of 2 returns small tier', () {
      final event = detector.registerClear(2);
      expect(event.tier, ComboTier.small);
      expect(event.multiplier, 1.2);
    });

    test('chain of 3 returns medium tier', () {
      final event = detector.registerClear(3);
      expect(event.tier, ComboTier.medium);
      expect(event.multiplier, 1.5);
    });

    test('chain of 5 returns large tier', () {
      final event = detector.registerClear(5);
      expect(event.tier, ComboTier.large);
      expect(event.multiplier, 2.0);
    });

    test('chain of 8+ returns epic tier', () {
      final event = detector.registerClear(8);
      expect(event.tier, ComboTier.epic);
      expect(event.multiplier, 3.0);
    });

    test('rapid consecutive clears accumulate chain', () {
      detector.registerClear(1); // chain = 1
      final event = detector.registerClear(2); // chain = 3 (within 1500ms)
      expect(event.tier, ComboTier.medium);
      expect(event.size, 3);
    });

    test('reset clears chain', () {
      detector.registerClear(5);
      detector.reset();
      final event = detector.registerClear(1);
      expect(event.size, 1);
      expect(event.tier, ComboTier.small);
    });
  });
}
