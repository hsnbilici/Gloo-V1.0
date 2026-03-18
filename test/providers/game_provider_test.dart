import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('initial state', () {
      final state = container.read(gameProvider(GameMode.classic));
      expect(state.score, 0);
      expect(state.status, GameStatus.idle);
      expect(state.mode, GameMode.classic);
    });

    test('updateScore changes score', () {
      container.read(gameProvider(GameMode.classic).notifier).updateScore(500);
      expect(container.read(gameProvider(GameMode.classic)).score, 500);
    });

    test('updateFill changes filledCells', () {
      container.read(gameProvider(GameMode.classic).notifier).updateFill(40);
      expect(container.read(gameProvider(GameMode.classic)).filledCells, 40);
    });

    test('updateStatus changes status', () {
      container
          .read(gameProvider(GameMode.classic).notifier)
          .updateStatus(GameStatus.playing);
      expect(container.read(gameProvider(GameMode.classic)).status,
          GameStatus.playing);
    });

    test('updateRemainingSeconds changes seconds', () {
      container
          .read(gameProvider(GameMode.classic).notifier)
          .updateRemainingSeconds(60);
      expect(
          container.read(gameProvider(GameMode.classic)).remainingSeconds, 60);
    });

    test('updateChef changes progress and required', () {
      container.read(gameProvider(GameMode.classic).notifier).updateChef(3, 5);
      final state = container.read(gameProvider(GameMode.classic));
      expect(state.chefProgress, 3);
      expect(state.chefRequired, 5);
    });

    test('updateGelOzu changes gelOzu', () {
      container.read(gameProvider(GameMode.classic).notifier).updateGelOzu(100);
      expect(container.read(gameProvider(GameMode.classic)).gelOzu, 100);
    });

    test('updateMovesUsed changes movesUsed', () {
      container
          .read(gameProvider(GameMode.classic).notifier)
          .updateMovesUsed(8);
      expect(container.read(gameProvider(GameMode.classic)).movesUsed, 8);
    });

    test('updateLevel changes level and target', () {
      container
          .read(gameProvider(GameMode.classic).notifier)
          .updateLevel(10, 2000);
      final state = container.read(gameProvider(GameMode.classic));
      expect(state.currentLevel, 10);
      expect(state.levelTargetScore, 2000);
    });

    test('updateElo changes elo', () {
      container.read(gameProvider(GameMode.classic).notifier).updateElo(1350);
      expect(container.read(gameProvider(GameMode.classic)).elo, 1350);
    });

    test('reset returns to initial state', () {
      final notifier = container.read(gameProvider(GameMode.classic).notifier);
      notifier.updateScore(500);
      notifier.updateFill(40);
      notifier.updateStatus(GameStatus.playing);
      notifier.updateGelOzu(100);
      notifier.updateMovesUsed(5);

      notifier.reset();
      final state = container.read(gameProvider(GameMode.classic));
      expect(state.score, 0);
      expect(state.status, GameStatus.idle);
      expect(state.filledCells, 0);
      expect(state.gelOzu, 0);
      expect(state.movesUsed, 0);
      // mode is preserved after reset
      expect(state.mode, GameMode.classic);
    });

    test('different modes start independently', () {
      container.read(gameProvider(GameMode.classic).notifier).updateScore(1000);
      expect(container.read(gameProvider(GameMode.timeTrial)).score, 0);
    });
  });
}
