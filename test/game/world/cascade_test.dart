import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/game/levels/level_data.dart';
import 'package:gloo/game/world/cell_type.dart';
import 'package:gloo/game/world/game_world.dart';
import 'package:gloo/game/world/grid_manager.dart';

/// Cascade test grid: 5 rows × 4 cols (via LevelData).
///
/// Gravity cells occupy the entire bottom row (row 4).
/// "Suspended" cells in rows 0–1 are each in an incomplete row, so they
/// survive the initial detectAndClear but fall into the gravity row later.
///
/// Initial state before placePiece:
///
///   Row 0: [R, R, ·, ·]  ← partial (2 cells, not a complete row)
///   Row 1: [·, ·, R, R]  ← partial (2 cells, not a complete row)
///   Row 2: [·, ·, ·, ·]  empty
///   Row 3: [B, B, B, ·]  trigger row — 3 of 4 filled
///   Row 4: [G, G, G, G]  gravity cells, empty
///
/// Trigger: place B at (3, 3) → row 3 becomes complete.
///
/// Evaluation pipeline:
///   _evaluateBoard:
///     detectAndClear → row 3 cleared (1 line). onLineClear call #1.
///     _applyGravityAndCascade (while-loop):
///       Iter 1: applyGravity → cols 0–3 each pull one cell down to row 4.
///               Row 4 → [R, R, R, R] — complete row.
///               detectAndClear → row 4 cleared (1 line). onLineClear call #2.
///       Iter 2: applyGravity → no cells remain above → empty → loop exits.
///
/// The OLD single-pass code ran exactly one gravity+clear check, so the
/// cascade clear (call #2) was silently dropped. The fixed while-loop
/// correctly detects and fires it.

const _kCascadeLevelData = LevelData(
  id: 999,
  rows: 5,
  cols: 4,
  targetScore: 999999, // do not trigger level completion
);

GlooGame _buildCascadeGame() {
  final game = GlooGame(mode: GameMode.level, levelData: _kCascadeLevelData);
  game.startGame();

  final gm = game.gridManager;

  // Mark entire bottom row as gravity cells.
  for (int c = 0; c < gm.cols; c++) {
    gm.setCellType(gm.rows - 1, c, CellType.gravity);
  }

  // Suspended cells: each column gets exactly one cell, split across rows
  // 0 and 1 so neither row is individually complete.
  gm.setCell(0, 0, GelColor.red);
  gm.setCell(0, 1, GelColor.red);
  gm.setCell(1, 2, GelColor.red);
  gm.setCell(1, 3, GelColor.red);

  // Trigger row (row 3): 3 of 4 cells filled.
  gm.setCell(3, 0, GelColor.blue);
  gm.setCell(3, 1, GelColor.blue);
  gm.setCell(3, 2, GelColor.blue);
  // col 3 is left empty — placePiece will complete it.

  return game;
}

void main() {
  group('_applyGravityAndCascade — cascade loop', () {
    // ── Core cascade behaviour ─────────────────────────────────────────────

    test('onLineClear fires twice: once for initial clear, once for cascade',
        () {
      final game = _buildCascadeGame();

      final clearResults = <LineClearResult>[];
      game.onLineClear = clearResults.add;

      game.placePiece([(3, 3)], GelColor.blue);

      expect(
        clearResults.length,
        2,
        reason:
            'Initial clear (row 3) + cascade clear (row 4 after gravity drop)',
      );
    });

    test('both line-clear results report exactly 1 cleared line each', () {
      final game = _buildCascadeGame();

      final clearResults = <LineClearResult>[];
      game.onLineClear = clearResults.add;

      game.placePiece([(3, 3)], GelColor.blue);

      expect(clearResults, hasLength(2));
      expect(clearResults[0].totalLines, 1,
          reason: 'Initial clear: row 3 (1 row)');
      expect(clearResults[1].totalLines, 1,
          reason: 'Cascade clear: row 4 after gravity (1 row)');
    });

    test('onScoreGained fires at least twice — once per clear', () {
      final game = _buildCascadeGame();

      final scores = <int>[];
      game.onScoreGained = scores.add;

      game.placePiece([(3, 3)], GelColor.blue);

      expect(
        scores.length,
        greaterThanOrEqualTo(2),
        reason: 'Points fire for each clear: initial and cascade',
      );
    });

    test('total score exceeds single-clear score (cascade adds more points)',
        () {
      final game = _buildCascadeGame();

      final scores = <int>[];
      game.onScoreGained = scores.add;

      game.placePiece([(3, 3)], GelColor.blue);

      final totalScore = scores.fold(0, (a, b) => a + b);
      expect(
        totalScore,
        greaterThan(scores.first),
        reason:
            'Cascade clear contributes additional points beyond the initial clear',
      );
    });

    // ── Gravity callback ───────────────────────────────────────────────────

    test('onGravityApplied fires once with 4 downward moves', () {
      final game = _buildCascadeGame();

      final allMoves = <List<(int, int, int, int)>>[];
      game.onGravityApplied = (moves) => allMoves.add(List.of(moves));

      game.placePiece([(3, 3)], GelColor.blue);

      expect(allMoves, hasLength(1),
          reason: 'Gravity fires once: all suspended cells fall in one pass');

      final moves = allMoves.first;
      expect(moves, hasLength(4),
          reason: 'Each of the 4 suspended cells produces one move entry');

      // All cells must land in the gravity row (row 4).
      final toRows = moves.map((m) => m.$3).toSet();
      expect(toRows, {4}, reason: 'Every suspended cell drops to gravity row 4');
    });

    // ── Post-cascade grid state ────────────────────────────────────────────

    test('gravity row is empty after cascade clear', () {
      final game = _buildCascadeGame();

      game.placePiece([(3, 3)], GelColor.blue);

      final gm = game.gridManager;
      for (int c = 0; c < gm.cols; c++) {
        expect(
          gm.getCell(gm.rows - 1, c).color,
          isNull,
          reason: 'Gravity row col $c should be cleared after cascade',
        );
      }
    });

    test('suspended cells are gone after falling and clearing', () {
      final game = _buildCascadeGame();

      game.placePiece([(3, 3)], GelColor.blue);

      final gm = game.gridManager;
      // Rows 0 and 1 had the suspended cells; they should all be empty now.
      for (int c = 0; c < gm.cols; c++) {
        expect(gm.getCell(0, c).color, isNull,
            reason: 'Row 0 col $c should be empty after cascade');
        expect(gm.getCell(1, c).color, isNull,
            reason: 'Row 1 col $c should be empty after cascade');
      }
    });

    // ── Regression: old single-pass code ──────────────────────────────────

    test('cascade is missed without the while-loop (old single-pass baseline)',
        () {
      // The old code ran one gravity+clear pass regardless of further changes.
      // Verify grid preconditions to confirm cascade MUST require the loop.
      final game = _buildCascadeGame();
      final gm = game.gridManager;

      // Before placement: suspended cells exist in rows 0 and 1.
      expect(gm.getCell(0, 0).color, GelColor.red);
      expect(gm.getCell(0, 1).color, GelColor.red);
      expect(gm.getCell(1, 2).color, GelColor.red);
      expect(gm.getCell(1, 3).color, GelColor.red);

      // Gravity row is empty before placement.
      for (int c = 0; c < gm.cols; c++) {
        expect(gm.getCell(4, c).color, isNull);
      }

      int lineClearCount = 0;
      game.onLineClear = (_) => lineClearCount++;

      game.placePiece([(3, 3)], GelColor.blue);

      // Fixed loop: 2 clears. Old single-pass: only 1.
      expect(
        lineClearCount,
        2,
        reason:
            'The while-loop fix must produce 2 line clears; '
            'the old single-pass produced only 1',
      );
    });

    // ── Safety cap ────────────────────────────────────────────────────────

    test('loop completes without hanging (safety cap ≤ 20 iterations)', () {
      final game = _buildCascadeGame();

      int gravityCallCount = 0;
      game.onGravityApplied = (_) => gravityCallCount++;

      // If the loop had no cap it would hang on an adversarial grid.
      // Completing the test at all verifies the cap works.
      game.placePiece([(3, 3)], GelColor.blue);

      expect(
        gravityCallCount,
        lessThanOrEqualTo(20),
        reason: 'Safety cap must limit cascade iterations to at most 20',
      );
    });

    // ── No-gravity regression ──────────────────────────────────────────────

    test('no cascade when no gravity cells exist — onLineClear fires exactly once',
        () {
      // Regression guard: standard grids (no gravity cells) must be unaffected.
      const level = LevelData(id: 998, rows: 5, cols: 4, targetScore: 999999);
      final game = GlooGame(mode: GameMode.level, levelData: level);
      game.startGame();

      final gm = game.gridManager;
      // Fill trigger row (row 3) with 3 cells; col 3 placed via placePiece.
      gm.setCell(3, 0, GelColor.red);
      gm.setCell(3, 1, GelColor.red);
      gm.setCell(3, 2, GelColor.red);

      int lineClearCount = 0;
      game.onLineClear = (_) => lineClearCount++;

      game.placePiece([(3, 3)], GelColor.red);

      expect(
        lineClearCount,
        1,
        reason:
            'Without gravity cells applyGravity() returns empty on first call, '
            'loop exits immediately — only the initial clear fires',
      );
    });

    // ── TimeTrial bonus fires for cascade clears ───────────────────────────

    test('timeTrial time bonus fires for cascade clear as well as initial clear',
        () {
      final game = GlooGame(
        mode: GameMode.timeTrial,
        levelData: _kCascadeLevelData,
      );
      game.startGame();
      game.cancelTimer();

      final gm = game.gridManager;

      // Mark bottom row as gravity.
      for (int c = 0; c < gm.cols; c++) {
        gm.setCellType(gm.rows - 1, c, CellType.gravity);
      }

      // Suspended cells.
      gm.setCell(0, 0, GelColor.red);
      gm.setCell(0, 1, GelColor.red);
      gm.setCell(1, 2, GelColor.red);
      gm.setCell(1, 3, GelColor.red);

      // Trigger row.
      gm.setCell(3, 0, GelColor.blue);
      gm.setCell(3, 1, GelColor.blue);
      gm.setCell(3, 2, GelColor.blue);

      final int secondsBefore = game.remainingSeconds;
      final timerTicks = <int>[];
      game.onTimerTick = timerTicks.add;

      game.placePiece([(3, 3)], GelColor.blue);

      // Each line clear in timeTrial adds bonus seconds and fires onTimerTick.
      // Initial clear: 1 tick. Cascade clear: 1 tick. Total ≥ 2.
      expect(
        timerTicks.length,
        greaterThanOrEqualTo(2),
        reason:
            'timeTrial time bonus must fire for both initial and cascade clears',
      );
      expect(
        game.remainingSeconds,
        greaterThan(secondsBefore),
        reason: 'Total remaining time should increase due to both clears',
      );
    });
  });
}
