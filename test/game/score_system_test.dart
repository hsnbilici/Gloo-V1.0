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

    test('single line clear gives 100 points', () {
      final points = scoreSystem.addLineClear(
        linesCleared: 1,
        combo: ComboEvent.none,
      );
      // 100 * 1.0 = 100
      expect(points, 100);
      expect(scoreSystem.score, 100);
    });

    test('multi line clear: 2 lines = 300', () {
      final points = scoreSystem.addLineClear(
        linesCleared: 2,
        combo: ComboEvent.none,
      );
      // 300 * (2-1) * 1.0 = 300
      expect(points, 300);
    });

    test('multi line clear: 3 lines = 600', () {
      final points = scoreSystem.addLineClear(
        linesCleared: 3,
        combo: ComboEvent.none,
      );
      // 300 * (3-1) * 1.0 = 600
      expect(points, 600);
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
      // 100 * 1.5 = 150
      expect(points, 150);
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
      // 100 * 3.0 = 300
      expect(points, 300);
    });

    test('color synthesis bonus added', () {
      final points = scoreSystem.addLineClear(
        linesCleared: 1,
        combo: ComboEvent.none,
        colorSynthesisCount: 2,
      );
      // 100 * 1.0 + 2 * 50 = 200
      expect(points, 200);
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
      // 100 * 1.2 = 120 + 1 * 50 = 170
      expect(points, 170);
    });

    test('score accumulates across calls', () {
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      expect(scoreSystem.score, 200);
    });

    test('high score tracks maximum', () {
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      expect(scoreSystem.highScore, 100);
      scoreSystem.reset();
      expect(scoreSystem.score, 0);
      expect(scoreSystem.highScore, 100);
    });

    test('isNewHighScore is false when score equals high score', () {
      // addLineClear internally updates _highScore when _score > _highScore
      // So after first call: score=100, highScore=100 → false (not strictly greater)
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      expect(scoreSystem.score, 100);
      expect(scoreSystem.highScore, 100);
      expect(scoreSystem.isNewHighScore, isFalse);
    });

    test('isNewHighScore is false when score below initial high', () {
      scoreSystem.setInitialHighScore(500);
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      expect(scoreSystem.score, 100);
      expect(scoreSystem.highScore, 500);
      expect(scoreSystem.isNewHighScore, isFalse);
    });

    test('setInitialHighScore does not overwrite higher value', () {
      scoreSystem.addLineClear(linesCleared: 2, combo: ComboEvent.none);
      // score=300, highScore=300
      scoreSystem.setInitialHighScore(100);
      expect(scoreSystem.highScore, 300);
    });

    test('reset clears score but keeps highScore', () {
      scoreSystem.addLineClear(linesCleared: 1, combo: ComboEvent.none);
      scoreSystem.reset();
      expect(scoreSystem.score, 0);
      expect(scoreSystem.highScore, 100);
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
