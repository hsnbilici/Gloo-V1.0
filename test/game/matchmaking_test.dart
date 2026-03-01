import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/game/pvp/matchmaking.dart';

void main() {
  // ─── EloLeague ──────────────────────────────────────────────────────────

  group('EloLeague', () {
    test('fromElo returns bronze for 0-999', () {
      expect(EloLeagueInfo.fromElo(0), EloLeague.bronze);
      expect(EloLeagueInfo.fromElo(500), EloLeague.bronze);
      expect(EloLeagueInfo.fromElo(999), EloLeague.bronze);
    });

    test('fromElo returns silver for 1000-1499', () {
      expect(EloLeagueInfo.fromElo(1000), EloLeague.silver);
      expect(EloLeagueInfo.fromElo(1250), EloLeague.silver);
      expect(EloLeagueInfo.fromElo(1499), EloLeague.silver);
    });

    test('fromElo returns gold for 1500-1999', () {
      expect(EloLeagueInfo.fromElo(1500), EloLeague.gold);
      expect(EloLeagueInfo.fromElo(1750), EloLeague.gold);
      expect(EloLeagueInfo.fromElo(1999), EloLeague.gold);
    });

    test('fromElo returns diamond for 2000-2499', () {
      expect(EloLeagueInfo.fromElo(2000), EloLeague.diamond);
      expect(EloLeagueInfo.fromElo(2499), EloLeague.diamond);
    });

    test('fromElo returns glooMaster for 2500+', () {
      expect(EloLeagueInfo.fromElo(2500), EloLeague.glooMaster);
      expect(EloLeagueInfo.fromElo(3000), EloLeague.glooMaster);
    });

    test('displayName returns correct string', () {
      expect(EloLeague.bronze.displayName, 'Bronz');
      expect(EloLeague.silver.displayName, 'Gümüş');
      expect(EloLeague.gold.displayName, 'Altın');
      expect(EloLeague.diamond.displayName, 'Elmas');
      expect(EloLeague.glooMaster.displayName, 'Gloo Master');
    });

    test('minElo returns correct thresholds', () {
      expect(EloLeague.bronze.minElo, 0);
      expect(EloLeague.silver.minElo, 1000);
      expect(EloLeague.gold.minElo, 1500);
      expect(EloLeague.diamond.minElo, 2000);
      expect(EloLeague.glooMaster.minElo, 2500);
    });
  });

  // ─── EloSystem ──────────────────────────────────────────────────────────

  group('EloSystem', () {
    test('initialElo is 1000', () {
      expect(EloSystem.initialElo, 1000);
    });

    test('kFactor is 32', () {
      expect(EloSystem.kFactor, 32);
    });

    test('win against equal opponent gives positive change', () {
      final change = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.win,
      );
      expect(change, greaterThan(0));
      expect(change, 16); // K * (1 - 0.5) = 32 * 0.5 = 16
    });

    test('loss against equal opponent gives negative change', () {
      final change = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.loss,
      );
      expect(change, lessThan(0));
      expect(change, -16);
    });

    test('draw against equal opponent gives 0 change', () {
      final change = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.draw,
      );
      expect(change, 0);
    });

    test('win against stronger opponent gives larger change', () {
      final changeVsEqual = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.win,
      );
      final changeVsStronger = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1500,
        outcome: DuelOutcome.win,
      );
      expect(changeVsStronger, greaterThan(changeVsEqual));
    });

    test('win against weaker opponent gives smaller change', () {
      final changeVsEqual = EloSystem.calculateChange(
        playerElo: 1500,
        opponentElo: 1500,
        outcome: DuelOutcome.win,
      );
      final changeVsWeaker = EloSystem.calculateChange(
        playerElo: 1500,
        opponentElo: 1000,
        outcome: DuelOutcome.win,
      );
      expect(changeVsWeaker, lessThan(changeVsEqual));
    });

    test('changes are symmetric for zero-sum', () {
      final playerChange = EloSystem.calculateChange(
        playerElo: 1200,
        opponentElo: 1000,
        outcome: DuelOutcome.win,
      );
      final opponentChange = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1200,
        outcome: DuelOutcome.loss,
      );
      // Sum should approximately equal 0 (may have rounding difference of 1)
      expect((playerChange + opponentChange).abs(), lessThanOrEqualTo(1));
    });
  });

  // ─── EloSystem.calculateGelReward ───────────────────────────────────────

  group('EloSystem.calculateGelReward', () {
    test('win rewards 10', () {
      expect(EloSystem.calculateGelReward(DuelOutcome.win), 10);
    });

    test('loss rewards 3', () {
      expect(EloSystem.calculateGelReward(DuelOutcome.loss), 3);
    });

    test('draw rewards 5', () {
      expect(EloSystem.calculateGelReward(DuelOutcome.draw), 5);
    });
  });

  // ─── ObstacleGenerator ──────────────────────────────────────────────────

  group('ObstacleGenerator.fromLineClear', () {
    test('1 line clear generates 1 ice packet', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 1,
        comboTier: 'none',
      );
      expect(packets.length, 1);
      expect(packets[0].type, ObstacleType.ice);
      expect(packets[0].count, 1);
    });

    test('2+ lines generate ice + locked packet', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 3,
        comboTier: 'none',
      );
      expect(packets.length, 2);
      expect(packets[0].type, ObstacleType.ice);
      expect(packets[0].count, 3);
      expect(packets[1].type, ObstacleType.locked);
      expect(packets[1].count, 1);
    });

    test('medium combo adds ice + stone', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 1,
        comboTier: 'medium',
      );
      // 1 ice (base) + 2 ice (combo) + 1 stone (combo)
      expect(packets.length, 3);
      expect(packets[1].type, ObstacleType.ice);
      expect(packets[1].count, 2);
      expect(packets[2].type, ObstacleType.stone);
      expect(packets[2].count, 1);
    });

    test('large combo adds ice + stone', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 1,
        comboTier: 'large',
      );
      expect(packets.length, 3);
    });

    test('epic combo adds 3x3 ice area', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 1,
        comboTier: 'epic',
      );
      // 1 ice (base) + 9 ice with areaSize=3
      expect(packets.length, 2);
      final epicPacket = packets.last;
      expect(epicPacket.type, ObstacleType.ice);
      expect(epicPacket.count, 9);
      expect(epicPacket.areaSize, 3);
    });
  });

  // ─── MatchmakingManager ─────────────────────────────────────────────────

  group('MatchmakingManager', () {
    test('maxWaitSeconds is 30', () {
      expect(MatchmakingManager.maxWaitSeconds, 30);
    });

    test('eloRange is 200', () {
      expect(MatchmakingManager.eloRange, 200);
    });

    group('isCompatible', () {
      test('returns true for same ELO players', () {
        final a = MatchRequest(
          userId: 'a',
          elo: 1000,
          region: 'eu',
          timestamp: DateTime.now(),
        );
        final b = MatchRequest(
          userId: 'b',
          elo: 1000,
          region: 'eu',
          timestamp: DateTime.now(),
        );
        expect(MatchmakingManager.isCompatible(a, b), isTrue);
      });

      test('returns true within ELO range', () {
        final a = MatchRequest(
          userId: 'a',
          elo: 1000,
          region: 'eu',
          timestamp: DateTime.now(),
        );
        final b = MatchRequest(
          userId: 'b',
          elo: 1200,
          region: 'eu',
          timestamp: DateTime.now(),
        );
        expect(MatchmakingManager.isCompatible(a, b), isTrue);
      });

      test('returns false when ELO difference exceeds range', () {
        final a = MatchRequest(
          userId: 'a',
          elo: 1000,
          region: 'eu',
          timestamp: DateTime.now(),
        );
        final b = MatchRequest(
          userId: 'b',
          elo: 1500,
          region: 'eu',
          timestamp: DateTime.now(),
        );
        expect(MatchmakingManager.isCompatible(a, b), isFalse);
      });

      test('expands range after 10 seconds wait', () {
        final a = MatchRequest(
          userId: 'a',
          elo: 1000,
          region: 'eu',
          timestamp: DateTime.now().subtract(const Duration(seconds: 15)),
        );
        final b = MatchRequest(
          userId: 'b',
          elo: 1290,
          region: 'eu',
          timestamp: DateTime.now(),
        );
        // a waited > 10s → range = 200 + 100 = 300; diff = 290 < 300
        expect(MatchmakingManager.isCompatible(a, b), isTrue);
      });

      test('expands range when both waited 10+ seconds', () {
        final a = MatchRequest(
          userId: 'a',
          elo: 1000,
          region: 'eu',
          timestamp: DateTime.now().subtract(const Duration(seconds: 15)),
        );
        final b = MatchRequest(
          userId: 'b',
          elo: 1400,
          region: 'eu',
          timestamp: DateTime.now().subtract(const Duration(seconds: 15)),
        );
        // Both waited > 10s → range = 200 + 100 + 100 = 400
        expect(MatchmakingManager.isCompatible(a, b), isTrue);
      });
    });

    test('generateBotMatchSeed returns value in 32-bit range', () {
      final seed = MatchmakingManager.generateBotMatchSeed();
      expect(seed, greaterThanOrEqualTo(0));
      expect(seed, lessThan(1 << 32));
    });

    test('generateBotMatchSeed returns different values', () {
      final seeds = List.generate(10, (_) => MatchmakingManager.generateBotMatchSeed());
      // Secure random ile 10 cagri arasinda en az 2 farkli deger olmali
      expect(seeds.toSet().length, greaterThan(1));
    });

    group('botDifficulty', () {
      test('clamps to minimum 0.2', () {
        expect(MatchmakingManager.botDifficulty(0), 0.2);
      });

      test('returns 0.4 for 1000 ELO', () {
        expect(MatchmakingManager.botDifficulty(1000), 0.4);
      });

      test('clamps to maximum 0.95', () {
        expect(MatchmakingManager.botDifficulty(5000), 0.95);
      });

      test('returns 1.0 for 2500 ELO (clamped to 0.95)', () {
        final diff = MatchmakingManager.botDifficulty(2500);
        expect(diff, 0.95); // 2500/2500 = 1.0 → clamped
      });
    });
  });

  // ─── MatchRequest ───────────────────────────────────────────────────────

  group('MatchRequest', () {
    test('waitSeconds returns correct elapsed time', () {
      final request = MatchRequest(
        userId: 'a',
        elo: 1000,
        region: 'eu',
        timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
      );
      // waitSeconds should be approximately 5 (allow 1s tolerance)
      expect(request.waitSeconds, greaterThanOrEqualTo(4));
      expect(request.waitSeconds, lessThanOrEqualTo(6));
    });
  });

  // ─── AsyncDuelState ─────────────────────────────────────────────────────

  group('AsyncDuelState', () {
    test('isComplete is false initially', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );
      expect(state.isComplete, isFalse);
    });

    test('isComplete is true when both players done', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );
      state.playerScore = 500;
      state.opponentScore = 300;
      state.isPlayerDone = true;
      state.isOpponentDone = true;
      expect(state.isComplete, isTrue);
    });

    test('outcome is null when not complete', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );
      expect(state.outcome, isNull);
    });

    test('outcome is win when player score higher', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );
      state.playerScore = 500;
      state.opponentScore = 300;
      state.isPlayerDone = true;
      state.isOpponentDone = true;
      expect(state.outcome, DuelOutcome.win);
    });

    test('outcome is loss when opponent score higher', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );
      state.playerScore = 200;
      state.opponentScore = 500;
      state.isPlayerDone = true;
      state.isOpponentDone = true;
      expect(state.outcome, DuelOutcome.loss);
    });

    test('outcome is draw when scores equal', () {
      final state = AsyncDuelState(
        matchId: 'test',
        seed: 42,
        durationSeconds: 120,
      );
      state.playerScore = 400;
      state.opponentScore = 400;
      state.isPlayerDone = true;
      state.isOpponentDone = true;
      expect(state.outcome, DuelOutcome.draw);
    });
  });

  // ─── MatchResult ────────────────────────────────────────────────────────

  group('MatchResult', () {
    test('stores all fields correctly', () {
      const result = MatchResult(
        matchId: 'abc',
        player1Id: 'p1',
        player2Id: 'p2',
        seed: 12345,
        isBot: false,
      );
      expect(result.matchId, 'abc');
      expect(result.player1Id, 'p1');
      expect(result.player2Id, 'p2');
      expect(result.seed, 12345);
      expect(result.isBot, isFalse);
    });
  });

  // ─── DuelResult ─────────────────────────────────────────────────────────

  group('DuelResult', () {
    test('stores all fields correctly', () {
      const result = DuelResult(
        outcome: DuelOutcome.win,
        playerScore: 1000,
        opponentScore: 800,
        eloChange: 16,
        gelReward: 10,
      );
      expect(result.outcome, DuelOutcome.win);
      expect(result.playerScore, 1000);
      expect(result.opponentScore, 800);
      expect(result.eloChange, 16);
      expect(result.gelReward, 10);
    });
  });
}
