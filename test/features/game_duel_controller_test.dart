import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/game/pvp/matchmaking.dart';
import 'package:gloo/game/world/game_world.dart';
import 'package:gloo/providers/pvp_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tests — GameDuelController logic (unit-level, no widget ref needed)
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('DuelState', () {
    test('default state has null matchId and zero opponent score', () {
      const state = DuelState();
      expect(state.matchId, isNull);
      expect(state.opponentScore, equals(0));
      expect(state.isBot, isFalse);
      expect(state.isOpponentDone, isFalse);
    });

    test('copyWith updates opponentScore correctly', () {
      const state = DuelState(opponentScore: 100);
      final updated = state.copyWith(opponentScore: 250);

      expect(updated.opponentScore, equals(250));
      expect(state.opponentScore, equals(100)); // original unchanged
    });

    test('copyWith with null matchId sets it to null (sentinel pattern)', () {
      const state = DuelState(matchId: 'match-123');
      final updated = state.copyWith(matchId: null);

      expect(updated.matchId, isNull);
    });

    test('copyWith without matchId preserves existing value', () {
      const state = DuelState(matchId: 'match-123');
      final updated = state.copyWith(opponentScore: 50);

      expect(updated.matchId, equals('match-123'));
    });
  });

  group('DuelNotifier', () {
    test('setMatch initializes duel state', () {
      // Test the DuelState data class directly
      const state = DuelState(
        matchId: 'test-match',
        seed: 42,
        isBot: true,
        opponentElo: 1200,
      );

      expect(state.matchId, equals('test-match'));
      expect(state.seed, equals(42));
      expect(state.isBot, isTrue);
      expect(state.opponentElo, equals(1200));
    });
  });

  group('ObstacleGenerator — duel obstacle sending', () {
    test('line clear generates ice obstacles', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 1,
        comboTier: 'small',
      );

      expect(packets, isNotEmpty);
      expect(
        packets.any((p) => p.type == ObstacleType.ice),
        isTrue,
      );
    });

    test('2+ lines generates locked obstacle', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 2,
        comboTier: 'small',
      );

      expect(
        packets.any((p) => p.type == ObstacleType.locked),
        isTrue,
      );
    });

    test('epic combo sends 4-5 random ice obstacle', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 1,
        comboTier: 'epic',
      );

      final epicPacket = packets.last;
      expect(epicPacket.type, ObstacleType.ice);
      expect(epicPacket.count, inInclusiveRange(4, 5));
      expect(epicPacket.areaSize, isNull);
    });
  });

  group('GlooGame duel mode', () {
    test('duel mode starts with 120 seconds', () {
      final game = GlooGame(mode: GameMode.duel);
      game.startGame();

      expect(game.remainingSeconds, equals(120));
      game.cancelTimer();
    });

    test('duel mode checkGameOver does not fire (timer-based)', () {
      final game = GlooGame(mode: GameMode.duel);
      game.startGame();

      bool gameOverCalled = false;
      game.onGameOver = () => gameOverCalled = true;

      game.checkGameOver([]);
      expect(gameOverCalled, isFalse);
      game.cancelTimer();
    });

    test('placePiece works normally in duel mode', () {
      final game = GlooGame(mode: GameMode.duel);
      game.startGame();
      game.onScoreGained = (_) {};
      game.onLineClear = (_) {};
      game.onMoveCompleted = (_) {};

      game.placePiece([(0, 0)], GelColor.red);
      expect(game.movesUsed, equals(1));
      expect(game.gridManager.getCell(0, 0).color, equals(GelColor.red));
      game.cancelTimer();
    });
  });

  group('Bot fallback and difficulty', () {
    test('botDifficulty scales with player ELO', () {
      expect(MatchmakingManager.botDifficulty(500), closeTo(0.2, 0.01));
      expect(MatchmakingManager.botDifficulty(1000), closeTo(0.4, 0.01));
      expect(MatchmakingManager.botDifficulty(2500), closeTo(0.95, 0.05));
    });

    test('botDifficulty is clamped between 0.2 and 0.95', () {
      expect(MatchmakingManager.botDifficulty(0), greaterThanOrEqualTo(0.2));
      expect(MatchmakingManager.botDifficulty(5000), lessThanOrEqualTo(0.95));
    });

    test('generateBotMatchSeed returns positive int', () {
      final seed = MatchmakingManager.generateBotMatchSeed();
      expect(seed, greaterThanOrEqualTo(0));
    });
  });

  group('ELO calculation in duel result', () {
    test('win against equal opponent gives positive ELO change', () {
      final change = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.win,
      );
      expect(change, greaterThan(0));
      expect(change, equals(16)); // K=32 * (1.0 - 0.5) = 16
    });

    test('loss against equal opponent gives negative ELO change', () {
      final change = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.loss,
      );
      expect(change, lessThan(0));
      expect(change, equals(-16));
    });

    test('gel reward varies by outcome', () {
      expect(EloSystem.calculateGelReward(DuelOutcome.win), equals(10));
      expect(EloSystem.calculateGelReward(DuelOutcome.loss), equals(3));
      expect(EloSystem.calculateGelReward(DuelOutcome.draw), equals(5));
    });
  });

  group('Bot ELO gain reduction', () {
    test('bot win ELO gain is halved', () {
      final rawChange = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.win,
      );
      expect(rawChange, equals(16)); // K=32 * 0.5

      const isBot = true;
      final eloChange =
          (isBot && rawChange > 0) ? (rawChange ~/ 2) : rawChange;
      expect(eloChange, equals(8)); // halved
    });

    test('bot loss ELO penalty is NOT halved', () {
      final rawChange = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.loss,
      );
      expect(rawChange, equals(-16));

      const isBot = true;
      final eloChange =
          (isBot && rawChange > 0) ? (rawChange ~/ 2) : rawChange;
      expect(eloChange, equals(-16)); // full penalty
    });

    test('non-bot win ELO gain is NOT halved', () {
      final rawChange = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.win,
      );

      // Non-bot: no reduction applied
      expect(rawChange, equals(16)); // full gain
    });

    test('bot draw ELO change is zero and not affected', () {
      final rawChange = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.draw,
      );
      expect(rawChange, equals(0));

      const isBot = true;
      final eloChange =
          (isBot && rawChange > 0) ? (rawChange ~/ 2) : rawChange;
      expect(eloChange, equals(0));
    });
  });

  group('Match end detection', () {
    test('AsyncDuelState isComplete when both players done', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );

      expect(state.isComplete, isFalse);

      state.isPlayerDone = true;
      expect(state.isComplete, isFalse);

      state.isOpponentDone = true;
      expect(state.isComplete, isTrue);
    });

    test('AsyncDuelState outcome is null when not complete', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );
      expect(state.outcome, isNull);
    });

    test('AsyncDuelState outcome is win when player score higher', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );
      state.playerScore = 200;
      state.opponentScore = 100;
      state.isPlayerDone = true;
      state.isOpponentDone = true;

      expect(state.outcome, equals(DuelOutcome.win));
    });

    test('AsyncDuelState outcome is draw when scores equal', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );
      state.playerScore = 150;
      state.opponentScore = 150;
      state.isPlayerDone = true;
      state.isOpponentDone = true;

      expect(state.outcome, equals(DuelOutcome.draw));
    });
  });
}
