import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/game/pvp/matchmaking.dart';

void main() {
  group('EloSystem — K=32 standard calculation', () {
    test('win vs equal opponent yields +16', () {
      final change = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.win,
      );
      expect(change, equals(16)); // K=32 * (1.0 - 0.5)
    });

    test('loss vs equal opponent yields -16', () {
      final change = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.loss,
      );
      expect(change, equals(-16)); // K=32 * (0.0 - 0.5)
    });

    test('draw vs equal opponent yields 0', () {
      final change = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1000,
        outcome: DuelOutcome.draw,
      );
      expect(change, equals(0)); // K=32 * (0.5 - 0.5)
    });
  });

  group('EloSystem — low-ranked beats high-ranked (large gain)', () {
    test('500 ELO player beating 1500 ELO opponent gets large gain', () {
      final change = EloSystem.calculateChange(
        playerElo: 500,
        opponentElo: 1500,
        outcome: DuelOutcome.win,
      );
      // Expected: ~31 (1000 ELO diff means expected ~0.03, so gain ≈ 32*(1-0.03))
      expect(change, greaterThan(28));
      expect(change, lessThanOrEqualTo(32));
    });

    test('upset win gives larger gain than expected win', () {
      final upsetGain = EloSystem.calculateChange(
        playerElo: 800,
        opponentElo: 1500,
        outcome: DuelOutcome.win,
      );
      final expectedGain = EloSystem.calculateChange(
        playerElo: 1500,
        opponentElo: 800,
        outcome: DuelOutcome.win,
      );
      expect(upsetGain, greaterThan(expectedGain));
    });
  });

  group('EloSystem — high-ranked beats low-ranked (small gain)', () {
    test('1500 ELO player beating 500 ELO opponent gets minimal gain', () {
      final change = EloSystem.calculateChange(
        playerElo: 1500,
        opponentElo: 500,
        outcome: DuelOutcome.win,
      );
      // 1000 ELO diff → expected ≈ 0.997, gain ≈ 32*(1-0.997) ≈ 0.1 → rounds to 0
      expect(change, greaterThanOrEqualTo(0));
      expect(change, lessThan(5));
    });

    test('high-ranked losing to low-ranked loses large amount', () {
      final change = EloSystem.calculateChange(
        playerElo: 1500,
        opponentElo: 500,
        outcome: DuelOutcome.loss,
      );
      expect(change, lessThan(-28));
    });
  });

  group('EloSystem — ELO floor at 0', () {
    test('ELO never goes below 0 after clamping', () {
      // A very low-rated player losing to a high-rated one
      final change = EloSystem.calculateChange(
        playerElo: 10,
        opponentElo: 2000,
        outcome: DuelOutcome.loss,
      );
      // The change itself might be slightly negative
      // But when applied: (10 + change).clamp(0, 9999)
      final newElo = (10 + change).clamp(0, 9999);
      expect(newElo, greaterThanOrEqualTo(0));
    });

    test('zero ELO player losing stays at 0 after clamp', () {
      final change = EloSystem.calculateChange(
        playerElo: 0,
        opponentElo: 1000,
        outcome: DuelOutcome.loss,
      );
      final newElo = (0 + change).clamp(0, 9999);
      expect(newElo, equals(0));
    });
  });

  group('EloSystem — draw scenarios', () {
    test('draw between unequal players adjusts toward balance', () {
      // Lower-rated player draws with higher: positive change
      final lowerChange = EloSystem.calculateChange(
        playerElo: 800,
        opponentElo: 1200,
        outcome: DuelOutcome.draw,
      );
      expect(lowerChange, greaterThan(0));

      // Higher-rated player draws with lower: negative change
      final higherChange = EloSystem.calculateChange(
        playerElo: 1200,
        opponentElo: 800,
        outcome: DuelOutcome.draw,
      );
      expect(higherChange, lessThan(0));
    });
  });

  group('EloSystem — ELO change magnitude bounds', () {
    test('maximum possible gain is 32 (K-factor)', () {
      // Extreme underdog (ELO 0) beating extreme favorite (ELO 3000)
      final change = EloSystem.calculateChange(
        playerElo: 0,
        opponentElo: 3000,
        outcome: DuelOutcome.win,
      );
      expect(change, lessThanOrEqualTo(32));
      expect(change, greaterThan(30)); // very close to 32
    });

    test('maximum possible loss is -32 (K-factor)', () {
      final change = EloSystem.calculateChange(
        playerElo: 3000,
        opponentElo: 0,
        outcome: DuelOutcome.loss,
      );
      expect(change, greaterThanOrEqualTo(-32));
      expect(change, lessThan(-30)); // very close to -32
    });

    test('ELO changes sum to approximately zero for both players', () {
      final winnerChange = EloSystem.calculateChange(
        playerElo: 1200,
        opponentElo: 1000,
        outcome: DuelOutcome.win,
      );
      final loserChange = EloSystem.calculateChange(
        playerElo: 1000,
        opponentElo: 1200,
        outcome: DuelOutcome.loss,
      );
      // Zero-sum: winner gain + loser loss ≈ 0
      expect((winnerChange + loserChange).abs(), lessThanOrEqualTo(1));
    });
  });

  group('EloSystem — gel reward calculation', () {
    test('win reward is highest', () {
      final winReward = EloSystem.calculateGelReward(DuelOutcome.win);
      final drawReward = EloSystem.calculateGelReward(DuelOutcome.draw);
      final lossReward = EloSystem.calculateGelReward(DuelOutcome.loss);

      expect(winReward, greaterThan(drawReward));
      expect(drawReward, greaterThan(lossReward));
    });

    test('loss still gives some reward (consolation)', () {
      expect(EloSystem.calculateGelReward(DuelOutcome.loss), greaterThan(0));
    });
  });

  group('EloLeague — league classification', () {
    test('0-999 ELO is Bronze', () {
      expect(EloLeagueInfo.fromElo(0), equals(EloLeague.bronze));
      expect(EloLeagueInfo.fromElo(999), equals(EloLeague.bronze));
    });

    test('1000-1499 ELO is Silver', () {
      expect(EloLeagueInfo.fromElo(1000), equals(EloLeague.silver));
      expect(EloLeagueInfo.fromElo(1499), equals(EloLeague.silver));
    });

    test('1500-1999 ELO is Gold', () {
      expect(EloLeagueInfo.fromElo(1500), equals(EloLeague.gold));
      expect(EloLeagueInfo.fromElo(1999), equals(EloLeague.gold));
    });

    test('2000-2499 ELO is Diamond', () {
      expect(EloLeagueInfo.fromElo(2000), equals(EloLeague.diamond));
      expect(EloLeagueInfo.fromElo(2499), equals(EloLeague.diamond));
    });

    test('2500+ ELO is Gloo Master', () {
      expect(EloLeagueInfo.fromElo(2500), equals(EloLeague.glooMaster));
      expect(EloLeagueInfo.fromElo(5000), equals(EloLeague.glooMaster));
    });
  });

  group('MatchmakingManager — compatibility', () {
    test('players within 200 ELO range are compatible', () {
      final now = DateTime.now();
      final a = MatchRequest(userId: 'a', elo: 1000, region: 'eu', timestamp: now);
      final b = MatchRequest(userId: 'b', elo: 1150, region: 'eu', timestamp: now);
      expect(MatchmakingManager.isCompatible(a, b), isTrue);
    });

    test('players outside 200 ELO range are not compatible', () {
      final now = DateTime.now();
      final a = MatchRequest(userId: 'a', elo: 1000, region: 'eu', timestamp: now);
      final b = MatchRequest(userId: 'b', elo: 1300, region: 'eu', timestamp: now);
      expect(MatchmakingManager.isCompatible(a, b), isFalse);
    });

    test('range expands after 10 seconds of waiting', () {
      // Create request with timestamp far in the past so waitSeconds > 10
      final longAgo = DateTime.now().subtract(const Duration(seconds: 20));
      final now = DateTime.now();
      final a = MatchRequest(
        userId: 'a',
        elo: 1000,
        region: 'eu',
        timestamp: longAgo,
      );
      final b = MatchRequest(userId: 'b', elo: 1250, region: 'eu', timestamp: now);
      // a.waitSeconds > 10, so range = 200 + 100 = 300
      // ELO diff = 250, which is within 300
      expect(a.waitSeconds, greaterThan(10));
      expect(MatchmakingManager.isCompatible(a, b), isTrue);
    });
  });
}
