import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/systems/combo_detector.dart';
import 'package:gloo/game/systems/score_system.dart';

void main() {
  late ScoreSystem scoreSystem;

  setUp(() {
    scoreSystem = ScoreSystem();
  });

  // ─── ScoreSystem ───────────────────────────────────────────────────────────

  group('ScoreSystem', () {
    test('initial score is 0', () {
      expect(scoreSystem.score, 0);
      expect(scoreSystem.highScore, 0);
    });

    test('single line clear gives 150 points', () {
      final points = scoreSystem.addLineClear(
        linesCleared: 1,
        combo: ComboEvent.none,
      );
      // 150 * 1.0 = 150
      expect(points, 150);
      expect(scoreSystem.score, 150);
    });

    test('multi line clear: 2 lines = 400', () {
      final points = scoreSystem.addLineClear(
        linesCleared: 2,
        combo: ComboEvent.none,
      );
      // lookup: 2 → 400
      expect(points, 400);
    });

    test('multi line clear: 3 lines = 1000', () {
      final points = scoreSystem.addLineClear(
        linesCleared: 3,
        combo: ComboEvent.none,
      );
      // lookup: 3 → 1000
      expect(points, 1000);
    });

    test('combo multiplier applied', () {
      const combo = ComboEvent(
        size: 3,
        tier: ComboTier.medium,
        multiplier: 1.5,
      );
      final points = scoreSystem.addLineClear(
        linesCleared: 1,
        combo: combo,
      );
      // 150 * 1.5 = 225
      expect(points, 225);
    });

    test('epic combo multiplier', () {
      const combo = ComboEvent(
        size: 8,
        tier: ComboTier.epic,
        multiplier: 3.0,
      );
      final points = scoreSystem.addLineClear(
        linesCleared: 1,
        combo: combo,
      );
      // 150 * 3.0 = 450
      expect(points, 450);
    });

    test('color synthesis bonus added', () {
      final points = scoreSystem.addLineClear(
        linesCleared: 1,
        combo: ComboEvent.none,
        colorSynthesisCount: 2,
      );
      // 150 * 1.0 + 2 * 150 = 450
      expect(points, 450);
    });

    test('combo + synthesis combined', () {
      const combo = ComboEvent(
        size: 2,
        tier: ComboTier.small,
        multiplier: 1.2,
      );
      final points = scoreSystem.addLineClear(
        linesCleared: 1,
        combo: combo,
        colorSynthesisCount: 1,
      );
      // 150 * 1.2 = 180 + 1 * 150 = 330
      expect(points, 330);
    });

    test('score accumulates across calls', () {
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      expect(scoreSystem.score, 300);
    });

    test('high score tracks maximum', () {
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      expect(scoreSystem.highScore, 150);
      scoreSystem.reset();
      expect(scoreSystem.score, 0);
      expect(scoreSystem.highScore, 150);
    });

    test('isNewHighScore is false when score equals high score', () {
      // addLineClear internally updates _highScore when _score > _highScore
      // So after first call: score=150, highScore=150 → false (not strictly greater)
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      expect(scoreSystem.score, 150);
      expect(scoreSystem.highScore, 150);
      expect(scoreSystem.isNewHighScore, isFalse);
    });

    test('isNewHighScore is false when score below initial high', () {
      scoreSystem.setInitialHighScore(500);
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      expect(scoreSystem.score, 150);
      expect(scoreSystem.highScore, 500);
      expect(scoreSystem.isNewHighScore, isFalse);
    });

    test('setInitialHighScore does not overwrite higher value', () {
      scoreSystem.addLineClear(linesCleared: 2, combo: ComboEvent.none);
      // score=400, highScore=400
      scoreSystem.setInitialHighScore(100);
      expect(scoreSystem.highScore, 400);
    });

    test('reset clears score but keeps highScore', () {
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      scoreSystem.reset();
      expect(scoreSystem.score, 0);
      expect(scoreSystem.highScore, 150);
    });
  });

  // ─── ComboDetector ─────────────────────────────────────────────────────────

  group('ComboDetector', () {
    late ComboDetector comboDetector;

    setUp(() {
      comboDetector = ComboDetector();
    });

    test('first clear starts chain', () {
      final event = comboDetector.registerClear(1);
      expect(event.size, 1);
      expect(event.tier, ComboTier.small);
      expect(event.multiplier, 1.2);
    });

    test('rapid clears accumulate chain', () {
      comboDetector.registerClear(1);
      final event = comboDetector.registerClear(1);
      // chain = 2
      expect(event.size, 2);
      expect(event.tier, ComboTier.small);
      expect(event.multiplier, 1.2);
    });

    test('medium tier at chain 3-4', () {
      comboDetector.registerClear(1);
      comboDetector.registerClear(1);
      final event = comboDetector.registerClear(1);
      // chain = 3
      expect(event.tier, ComboTier.medium);
      expect(event.multiplier, 1.5);
    });

    test('large tier at chain 5-7', () {
      comboDetector.registerClear(2);
      comboDetector.registerClear(2);
      final event = comboDetector.registerClear(1);
      // chain = 5
      expect(event.tier, ComboTier.large);
      expect(event.multiplier, 2.0);
    });

    test('epic tier at chain 8+', () {
      comboDetector.registerClear(4);
      final event = comboDetector.registerClear(4);
      // chain = 8
      expect(event.tier, ComboTier.epic);
      expect(event.multiplier, 3.0);
    });

    test('multi-line clear adds to chain', () {
      final event = comboDetector.registerClear(3);
      // chain = 3
      expect(event.size, 3);
      expect(event.tier, ComboTier.medium);
    });

    test('ComboEvent.none has multiplier 1.0', () {
      expect(ComboEvent.none.multiplier, 1.0);
      expect(ComboEvent.none.size, 0);
      expect(ComboEvent.none.tier, ComboTier.none);
    });

    test('reset clears chain', () {
      comboDetector.registerClear(5);
      comboDetector.reset();
      final event = comboDetector.registerClear(1);
      expect(event.size, 1);
      expect(event.tier, ComboTier.small);
    });
  });
}
