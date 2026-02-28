import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/game_constants.dart';
import 'package:gloo/game/world/game_world.dart';
import 'package:gloo/providers/game_provider.dart';

void main() {
  // ─── GameState ──────────────────────────────────────────────────────────

  group('GameState', () {
    test('default values for classic', () {
      const state = GameState(
        score: 0,
        status: GameStatus.idle,
        mode: GameMode.classic,
      );
      expect(state.score, 0);
      expect(state.status, GameStatus.idle);
      expect(state.mode, GameMode.classic);
      expect(state.filledCells, 0);
      expect(state.remainingSeconds, GameConstants.timeTrialDuration);
      expect(state.chefProgress, 0);
      expect(state.chefRequired, 3);
      expect(state.gelOzu, 0);
      expect(state.movesUsed, 0);
      expect(state.currentLevel, 0);
      expect(state.levelTargetScore, 0);
      expect(state.elo, 1000);
    });

    test('copyWith updates only specified fields', () {
      const state = GameState(
        score: 100,
        status: GameStatus.playing,
        mode: GameMode.classic,
      );
      final updated = state.copyWith(score: 500);
      expect(updated.score, 500);
      expect(updated.status, GameStatus.playing);
      expect(updated.mode, GameMode.classic);
    });

    test('copyWith can update all fields', () {
      const state = GameState(
        score: 0,
        status: GameStatus.idle,
        mode: GameMode.classic,
      );
      final updated = state.copyWith(
        score: 1000,
        status: GameStatus.playing,
        mode: GameMode.timeTrial,
        filledCells: 40,
        remainingSeconds: 60,
        chefProgress: 2,
        chefRequired: 5,
        gelOzu: 50,
        movesUsed: 10,
        currentLevel: 5,
        levelTargetScore: 500,
        elo: 1200,
      );
      expect(updated.score, 1000);
      expect(updated.status, GameStatus.playing);
      expect(updated.mode, GameMode.timeTrial);
      expect(updated.filledCells, 40);
      expect(updated.remainingSeconds, 60);
      expect(updated.chefProgress, 2);
      expect(updated.chefRequired, 5);
      expect(updated.gelOzu, 50);
      expect(updated.movesUsed, 10);
      expect(updated.currentLevel, 5);
      expect(updated.levelTargetScore, 500);
      expect(updated.elo, 1200);
    });
  });

  // ─── GameNotifier ───────────────────────────────────────────────────────

  group('GameNotifier', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier(GameMode.classic);
    });

    test('initial state', () {
      expect(notifier.state.score, 0);
      expect(notifier.state.status, GameStatus.idle);
      expect(notifier.state.mode, GameMode.classic);
    });

    test('updateScore changes score', () {
      notifier.updateScore(500);
      expect(notifier.state.score, 500);
    });

    test('updateFill changes filledCells', () {
      notifier.updateFill(40);
      expect(notifier.state.filledCells, 40);
    });

    test('updateStatus changes status', () {
      notifier.updateStatus(GameStatus.playing);
      expect(notifier.state.status, GameStatus.playing);
    });

    test('updateRemainingSeconds changes seconds', () {
      notifier.updateRemainingSeconds(60);
      expect(notifier.state.remainingSeconds, 60);
    });

    test('updateChef changes progress and required', () {
      notifier.updateChef(3, 5);
      expect(notifier.state.chefProgress, 3);
      expect(notifier.state.chefRequired, 5);
    });

    test('updateGelOzu changes gelOzu', () {
      notifier.updateGelOzu(100);
      expect(notifier.state.gelOzu, 100);
    });

    test('updateMovesUsed changes movesUsed', () {
      notifier.updateMovesUsed(8);
      expect(notifier.state.movesUsed, 8);
    });

    test('updateLevel changes level and target', () {
      notifier.updateLevel(10, 2000);
      expect(notifier.state.currentLevel, 10);
      expect(notifier.state.levelTargetScore, 2000);
    });

    test('updateElo changes elo', () {
      notifier.updateElo(1350);
      expect(notifier.state.elo, 1350);
    });

    test('reset returns to initial state', () {
      notifier.updateScore(500);
      notifier.updateFill(40);
      notifier.updateStatus(GameStatus.playing);
      notifier.updateGelOzu(100);
      notifier.updateMovesUsed(5);

      notifier.reset();
      expect(notifier.state.score, 0);
      expect(notifier.state.status, GameStatus.idle);
      expect(notifier.state.filledCells, 0);
      expect(notifier.state.gelOzu, 0);
      expect(notifier.state.movesUsed, 0);
      // mode is preserved after reset
      expect(notifier.state.mode, GameMode.classic);
    });

    test('different modes start independently', () {
      final classicNotifier = GameNotifier(GameMode.classic);
      final timeTrialNotifier = GameNotifier(GameMode.timeTrial);
      classicNotifier.updateScore(1000);
      expect(timeTrialNotifier.state.score, 0);
    });
  });
}
