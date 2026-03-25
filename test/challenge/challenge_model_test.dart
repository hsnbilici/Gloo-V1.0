import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/models/challenge.dart';
import 'package:gloo/core/models/game_mode.dart';

void main() {
  group('ChallengeType', () {
    test('fromString parses score_battle', () {
      expect(ChallengeType.fromString('score_battle'), ChallengeType.scoreBattle);
    });

    test('fromString parses live_duel', () {
      expect(ChallengeType.fromString('live_duel'), ChallengeType.liveDuel);
    });

    test('fromString defaults to scoreBattle for unknown', () {
      expect(ChallengeType.fromString('unknown'), ChallengeType.scoreBattle);
      expect(ChallengeType.fromString(''), ChallengeType.scoreBattle);
    });

    test('toDbString round-trips all values', () {
      for (final type in ChallengeType.values) {
        expect(ChallengeType.fromString(type.toDbString()), type);
      }
    });

    test('toDbString returns correct strings', () {
      expect(ChallengeType.scoreBattle.toDbString(), 'score_battle');
      expect(ChallengeType.liveDuel.toDbString(), 'live_duel');
    });
  });

  group('ChallengeStatus', () {
    test('fromString parses all 6 values', () {
      expect(ChallengeStatus.fromString('pending'), ChallengeStatus.pending);
      expect(ChallengeStatus.fromString('active'), ChallengeStatus.active);
      expect(ChallengeStatus.fromString('completed'), ChallengeStatus.completed);
      expect(ChallengeStatus.fromString('expired'), ChallengeStatus.expired);
      expect(ChallengeStatus.fromString('declined'), ChallengeStatus.declined);
      expect(ChallengeStatus.fromString('cancelled'), ChallengeStatus.cancelled);
    });

    test('fromString defaults to pending for unknown', () {
      expect(ChallengeStatus.fromString('unknown'), ChallengeStatus.pending);
      expect(ChallengeStatus.fromString(''), ChallengeStatus.pending);
    });
  });

  group('ChallengeOutcome', () {
    test('fromString parses all 3 values', () {
      expect(ChallengeOutcome.fromString('win'), ChallengeOutcome.win);
      expect(ChallengeOutcome.fromString('loss'), ChallengeOutcome.loss);
      expect(ChallengeOutcome.fromString('draw'), ChallengeOutcome.draw);
    });

    test('fromString defaults to draw for unknown', () {
      expect(ChallengeOutcome.fromString('unknown'), ChallengeOutcome.draw);
      expect(ChallengeOutcome.fromString(''), ChallengeOutcome.draw);
    });
  });

  group('Challenge.fromMap', () {
    Map<String, dynamic> _fullMap({
      String? recipientId = 'recipient-1',
      String? recipientUsername = 'rival',
      int? seed = 42,
      int? senderScore = 1500,
      int? recipientScore = 1200,
    }) {
      return {
        'id': 'challenge-1',
        'sender_id': 'sender-1',
        'recipient_id': recipientId,
        'sender_username': 'player1',
        'recipient_username': recipientUsername,
        'mode': 'classic',
        'challenge_type': 'score_battle',
        'seed': seed,
        'wager': 50,
        'sender_score': senderScore,
        'recipient_score': recipientScore,
        'status': 'pending',
        'expires_at': '2026-04-01T12:00:00.000Z',
        'created_at': '2026-03-25T12:00:00.000Z',
      };
    }

    test('parses full map correctly', () {
      final challenge = Challenge.fromMap(_fullMap());

      expect(challenge.id, 'challenge-1');
      expect(challenge.senderId, 'sender-1');
      expect(challenge.recipientId, 'recipient-1');
      expect(challenge.senderUsername, 'player1');
      expect(challenge.recipientUsername, 'rival');
      expect(challenge.mode, GameMode.classic);
      expect(challenge.type, ChallengeType.scoreBattle);
      expect(challenge.seed, 42);
      expect(challenge.wager, 50);
      expect(challenge.senderScore, 1500);
      expect(challenge.recipientScore, 1200);
      expect(challenge.status, ChallengeStatus.pending);
      expect(challenge.expiresAt, DateTime.utc(2026, 4, 1, 12));
      expect(challenge.createdAt, DateTime.utc(2026, 3, 25, 12));
    });

    test('handles null seed', () {
      final challenge = Challenge.fromMap(_fullMap(seed: null));
      expect(challenge.seed, isNull);
    });

    test('handles null recipient fields', () {
      final challenge = Challenge.fromMap(
        _fullMap(recipientId: null, recipientUsername: null),
      );
      expect(challenge.recipientId, isNull);
      expect(challenge.recipientUsername, isNull);
    });

    test('handles null scores', () {
      final challenge = Challenge.fromMap(
        _fullMap(senderScore: null, recipientScore: null),
      );
      expect(challenge.senderScore, isNull);
      expect(challenge.recipientScore, isNull);
    });

    test('parses different game modes', () {
      final map = _fullMap();
      map['mode'] = 'timeTrial';
      final challenge = Challenge.fromMap(map);
      expect(challenge.mode, GameMode.timeTrial);
    });

    test('parses live_duel type', () {
      final map = _fullMap();
      map['challenge_type'] = 'live_duel';
      final challenge = Challenge.fromMap(map);
      expect(challenge.type, ChallengeType.liveDuel);
    });
  });

  group('Challenge getters', () {
    Challenge _makeChallenge({
      required DateTime expiresAt,
      int wager = 0,
    }) {
      return Challenge(
        id: 'test',
        senderId: 'sender',
        senderUsername: 'player',
        mode: GameMode.classic,
        type: ChallengeType.scoreBattle,
        wager: wager,
        status: ChallengeStatus.pending,
        expiresAt: expiresAt,
        createdAt: DateTime.now(),
      );
    }

    test('isExpired returns true for past date', () {
      final challenge = _makeChallenge(
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(challenge.isExpired, isTrue);
    });

    test('isExpired returns false for future date', () {
      final challenge = _makeChallenge(
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(challenge.isExpired, isFalse);
    });

    test('hasWager returns true for wager > 0', () {
      final challenge = _makeChallenge(
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        wager: 50,
      );
      expect(challenge.hasWager, isTrue);
    });

    test('hasWager returns false for wager 0', () {
      final challenge = _makeChallenge(
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        wager: 0,
      );
      expect(challenge.hasWager, isFalse);
    });

    test('timeRemaining returns Duration.zero for expired', () {
      final challenge = _makeChallenge(
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(challenge.timeRemaining, Duration.zero);
    });

    test('timeRemaining returns positive duration for future', () {
      final challenge = _makeChallenge(
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      );
      expect(challenge.timeRemaining.inMinutes, greaterThan(60));
    });
  });

  group('ChallengeResult', () {
    test('fromMap parses win result', () {
      final result = ChallengeResult.fromMap({
        'outcome': 'win',
        'sender_score': 2000,
        'recipient_score': 1500,
        'gel_reward': 100,
      });
      expect(result.outcome, ChallengeOutcome.win);
      expect(result.senderScore, 2000);
      expect(result.recipientScore, 1500);
      expect(result.gelReward, 100);
    });

    test('fromMap parses loss result', () {
      final result = ChallengeResult.fromMap({
        'outcome': 'loss',
        'sender_score': 800,
        'recipient_score': 1500,
        'gel_reward': 0,
      });
      expect(result.outcome, ChallengeOutcome.loss);
      expect(result.senderScore, 800);
      expect(result.recipientScore, 1500);
      expect(result.gelReward, 0);
    });

    test('fromMap parses draw result', () {
      final result = ChallengeResult.fromMap({
        'outcome': 'draw',
        'sender_score': 1500,
        'recipient_score': 1500,
        'gel_reward': 25,
      });
      expect(result.outcome, ChallengeOutcome.draw);
      expect(result.senderScore, 1500);
      expect(result.recipientScore, 1500);
      expect(result.gelReward, 25);
    });
  });
}
