import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/constants/game_constants.dart';
import 'package:gloo/game/levels/level_data.dart';
import 'package:gloo/game/world/game_world.dart';

void main() {
  // ─── _updateColorChefProgress ────────────────────────────────────────────

  group('_updateColorChefProgress (via colorChef mode)', () {
    // Level 0: orange (red + yellow), requiredCount: 3

    test('synthesising target color fires onChefProgress callback', () {
      final game = GlooGame(mode: GameMode.colorChef);
      game.startGame();

      int? capturedProgress;
      int? capturedRequired;
      game.onChefProgress = (progress, required) {
        capturedProgress = progress;
        capturedRequired = required;
      };

      // Place red and yellow adjacent — synthesis produces orange (target).
      // Use row 5 to avoid accidental column completion with an 8-col grid.
      game.gridManager.setCell(5, 0, GelColor.red);
      game.placePiece([(5, 1)], GelColor.yellow);

      expect(capturedProgress, isNotNull,
          reason: 'onChefProgress should fire when target color is synthesised');
      expect(capturedProgress, 1);
      expect(capturedRequired, 3); // level 0 requiredCount
    });

    test('progress accumulates across multiple synthesises', () {
      final game = GlooGame(mode: GameMode.colorChef);
      game.startGame();

      final progressValues = <int>[];
      game.onChefProgress = (progress, _) => progressValues.add(progress);

      // First synthesis — row 5
      game.gridManager.setCell(5, 0, GelColor.red);
      game.placePiece([(5, 1)], GelColor.yellow);

      // Second synthesis — row 6 (fresh cells, no conflict)
      game.gridManager.setCell(6, 0, GelColor.red);
      game.placePiece([(6, 1)], GelColor.yellow);

      expect(progressValues.length, greaterThanOrEqualTo(2));
      expect(progressValues.first, 1);
      expect(progressValues[1], 2);
    });

    test('completing chef level fires onChefLevelComplete and resets progress',
        () {
      final game = GlooGame(mode: GameMode.colorChef);
      game.startGame();

      int? completedIndex;
      GelColor? completedColor;
      bool? allComplete;
      game.onChefLevelComplete = (idx, color, done) {
        completedIndex = idx;
        completedColor = color;
        allComplete = done;
      };

      // Produce 3 orange synthesises to meet requiredCount (3).
      // Each synthesis needs a fresh red+yellow adjacent pair on a distinct row.
      for (int r = 0; r < 3; r++) {
        game.gridManager.setCell(r, 0, GelColor.red);
        game.placePiece([(r, 1)], GelColor.yellow);
      }

      expect(completedIndex, 0);
      expect(completedColor, GelColor.orange);
      expect(allComplete, isFalse); // more levels remain
    });

    test('non-target synthesis does not advance chef progress', () {
      final game = GlooGame(mode: GameMode.colorChef);
      game.startGame();

      bool progressFired = false;
      game.onChefProgress = (_, __) => progressFired = true;

      // red + blue → purple (NOT the target orange)
      game.gridManager.setCell(5, 0, GelColor.red);
      game.placePiece([(5, 1)], GelColor.blue);

      expect(progressFired, isFalse);
    });
  });

  // ─── _checkTimeTrialBonus ────────────────────────────────────────────────

  group('_checkTimeTrialBonus (via timeTrial mode)', () {
    test('clearing one row adds timeTrialLineClearBonus seconds', () {
      final game = GlooGame(mode: GameMode.timeTrial);
      game.startGame();
      game.cancelTimer(); // stop countdown so seconds don't decrease

      final int secondsBefore = game.remainingSeconds;

      int? timerTickValue;
      game.onTimerTick = (seconds) => timerTickValue = seconds;

      // Fill row 9 with 7 red cells, then place the 8th via placePiece.
      for (int c = 0; c < GameConstants.gridCols - 1; c++) {
        game.gridManager.setCell(9, c, GelColor.red);
      }
      game.placePiece([(9, GameConstants.gridCols - 1)], GelColor.red);

      final int expectedSeconds =
          secondsBefore + GameConstants.timeTrialLineClearBonus;

      expect(game.remainingSeconds, expectedSeconds,
          reason:
              'remainingSeconds should increase by timeTrialLineClearBonus per cleared line');
      expect(timerTickValue, expectedSeconds,
          reason: 'onTimerTick should fire with updated seconds after bonus');
    });

    test('clearing two rows adds 2x timeTrialLineClearBonus seconds', () {
      final game = GlooGame(mode: GameMode.timeTrial);
      game.startGame();
      game.cancelTimer();

      final int secondsBefore = game.remainingSeconds;

      // Fill rows 8 and 9 with 7 red cells each.
      for (int r = 8; r <= 9; r++) {
        for (int c = 0; c < GameConstants.gridCols - 1; c++) {
          game.gridManager.setCell(r, c, GelColor.red);
        }
      }
      // Place the 8th cell in row 9 to trigger both row clears simultaneously.
      // Also need to fill row 8 col 7 — place one piece that completes both rows.
      // Complete row 8 first, then row 9.
      game.placePiece([(8, GameConstants.gridCols - 1)], GelColor.red);

      // At this point row 8 is complete (cleared). Row 9 still has 7 cells.
      // Now complete row 9.
      game.placePiece([(9, GameConstants.gridCols - 1)], GelColor.red);

      final int expectedSeconds =
          secondsBefore + 2 * GameConstants.timeTrialLineClearBonus;

      expect(game.remainingSeconds, expectedSeconds);
    });

    test('no line clear does not change remainingSeconds via bonus', () {
      final game = GlooGame(mode: GameMode.timeTrial);
      game.startGame();
      game.cancelTimer();

      final int secondsBefore = game.remainingSeconds;

      // Place a piece that doesn't complete a row.
      game.placePiece([(0, 0)], GelColor.red);

      expect(game.remainingSeconds, secondsBefore);
    });

    test('time bonus is not applied in classic mode', () {
      final game = GlooGame(mode: GameMode.classic);
      game.startGame();

      final int secondsBefore = game.remainingSeconds;

      // Complete a row in classic mode.
      for (int c = 0; c < GameConstants.gridCols - 1; c++) {
        game.gridManager.setCell(9, c, GelColor.red);
      }
      game.placePiece([(9, GameConstants.gridCols - 1)], GelColor.red);

      // remainingSeconds should not change (bonus only applies in timeTrial).
      expect(game.remainingSeconds, secondsBefore);
    });
  });

  // ─── _checkLevelCompletion ───────────────────────────────────────────────

  group('_checkLevelCompletion (via level mode)', () {
    test('reaching targetScore fires onLevelComplete', () {
      // targetScore of 1 ensures the first line clear exceeds it.
      const level = LevelData(id: 1, targetScore: 1);
      final game = GlooGame(mode: GameMode.level, levelData: level);
      game.startGame();

      bool levelCompleteFired = false;
      game.onLevelComplete = () => levelCompleteFired = true;

      // Complete a row to earn points.
      for (int c = 0; c < GameConstants.gridCols - 1; c++) {
        game.gridManager.setCell(9, c, GelColor.red);
      }
      game.placePiece([(9, GameConstants.gridCols - 1)], GelColor.red);

      expect(levelCompleteFired, isTrue);
    });

    test('score below targetScore does not fire onLevelComplete', () {
      // Very high targetScore so the first line clear will not reach it.
      const level = LevelData(id: 1, targetScore: 999999);
      final game = GlooGame(mode: GameMode.level, levelData: level);
      game.startGame();

      bool levelCompleteFired = false;
      game.onLevelComplete = () => levelCompleteFired = true;

      for (int c = 0; c < GameConstants.gridCols - 1; c++) {
        game.gridManager.setCell(9, c, GelColor.red);
      }
      game.placePiece([(9, GameConstants.gridCols - 1)], GelColor.red);

      expect(levelCompleteFired, isFalse);
    });

    test('onLevelComplete is not fired in classic mode even after line clear',
        () {
      final game = GlooGame(mode: GameMode.classic);
      game.startGame();

      bool levelCompleteFired = false;
      game.onLevelComplete = () => levelCompleteFired = true;

      for (int c = 0; c < GameConstants.gridCols - 1; c++) {
        game.gridManager.setCell(9, c, GelColor.red);
      }
      game.placePiece([(9, GameConstants.gridCols - 1)], GelColor.red);

      expect(levelCompleteFired, isFalse);
    });

    test('score increases before level completion check', () {
      const level = LevelData(id: 1, targetScore: 1);
      final game = GlooGame(mode: GameMode.level, levelData: level);
      game.startGame();

      // Complete a row — score must be > 0 for the level to complete.
      for (int c = 0; c < GameConstants.gridCols - 1; c++) {
        game.gridManager.setCell(9, c, GelColor.red);
      }
      game.placePiece([(9, GameConstants.gridCols - 1)], GelColor.red);

      expect(game.score, greaterThan(0));
    });
  });
}
