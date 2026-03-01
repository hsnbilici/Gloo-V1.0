import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/data/remote/dto/daily_puzzle.dart';
import 'package:gloo/data/remote/dto/leaderboard_entry.dart';
import 'package:gloo/data/remote/dto/meta_state.dart';
import 'package:gloo/data/remote/dto/pvp_match.dart';
import 'package:gloo/data/remote/dto/redeem_result.dart';
import 'package:gloo/data/remote/dto/broadcast_score.dart';
import 'package:gloo/data/remote/dto/broadcast_obstacle.dart';
import 'package:gloo/data/remote/dto/broadcast_game_over.dart';

void main() {
  // ─────────────────────────────────────────────────────────
  // 1. DailyPuzzle
  // ─────────────────────────────────────────────────────────
  group('DailyPuzzle', () {
    test('fromMap with valid full data', () {
      final map = <String, dynamic>{
        'id': 'dp-001',
        'date': '2026-03-01',
        'user_id': 'user-42',
        'completed': true,
        'score': 1500,
        'completed_at': '2026-03-01T14:30:00Z',
      };

      final result = DailyPuzzle.fromMap(map);

      expect(result.id, 'dp-001');
      expect(result.date, '2026-03-01');
      expect(result.userId, 'user-42');
      expect(result.completed, true);
      expect(result.score, 1500);
      expect(result.completedAt, DateTime.utc(2026, 3, 1, 14, 30));
    });

    test('fromMap with all null optional fields', () {
      final map = <String, dynamic>{
        'id': null,
        'date': '2026-03-01',
        'user_id': null,
        'completed': null,
        'score': null,
        'completed_at': null,
      };

      final result = DailyPuzzle.fromMap(map);

      expect(result.id, isNull);
      expect(result.date, '2026-03-01');
      expect(result.userId, isNull);
      expect(result.completed, false);
      expect(result.score, isNull);
      expect(result.completedAt, isNull);
    });

    test('fromMap with missing keys uses defaults', () {
      final map = <String, dynamic>{};

      final result = DailyPuzzle.fromMap(map);

      expect(result.id, isNull);
      expect(result.date, '');
      expect(result.userId, isNull);
      expect(result.completed, false);
      expect(result.score, isNull);
      expect(result.completedAt, isNull);
    });

    test('fromMap with invalid completed_at does not crash', () {
      final map = <String, dynamic>{
        'date': '2026-03-01',
        'completed_at': 'not-a-date',
      };

      final result = DailyPuzzle.fromMap(map);

      // DateTime.tryParse returns null for invalid strings
      expect(result.completedAt, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────
  // 2. LeaderboardEntry
  // ─────────────────────────────────────────────────────────
  group('LeaderboardEntry', () {
    test('fromMap with valid full data', () {
      final map = <String, dynamic>{
        'id': 'lb-001',
        'user_id': 'user-7',
        'mode': 'classic',
        'score': 9999,
        'created_at': '2026-02-28T10:00:00Z',
        'username': 'GlooMaster',
      };

      final result = LeaderboardEntry.fromMap(map);

      expect(result.id, 'lb-001');
      expect(result.userId, 'user-7');
      expect(result.mode, 'classic');
      expect(result.score, 9999);
      expect(result.createdAt, DateTime.utc(2026, 2, 28, 10));
      expect(result.username, 'GlooMaster');
    });

    test('fromMap with missing keys falls back to defaults', () {
      final map = <String, dynamic>{};

      final result = LeaderboardEntry.fromMap(map);

      expect(result.id, '');
      expect(result.userId, '');
      expect(result.mode, '');
      expect(result.score, 0);
      expect(result.createdAt, isNull);
      expect(result.username, 'Player');
    });

    test('fromMap with null values falls back to defaults', () {
      final map = <String, dynamic>{
        'id': null,
        'user_id': null,
        'mode': null,
        'score': null,
        'created_at': null,
        'username': null,
      };

      final result = LeaderboardEntry.fromMap(map);

      expect(result.id, '');
      expect(result.userId, '');
      expect(result.mode, '');
      expect(result.score, 0);
      expect(result.createdAt, isNull);
      expect(result.username, 'Player');
    });

    test('fromMap with invalid created_at string', () {
      final map = <String, dynamic>{
        'id': 'lb-002',
        'user_id': 'u1',
        'mode': 'zen',
        'score': 100,
        'created_at': 'garbage',
        'username': 'Tester',
      };

      final result = LeaderboardEntry.fromMap(map);

      expect(result.createdAt, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────
  // 3. MetaState
  // ─────────────────────────────────────────────────────────
  group('MetaState', () {
    test('fromMap with valid full data', () {
      final island = <String, dynamic>{'level': 3};
      final character = <String, dynamic>{'skin': 'blue'};
      final seasonPass = <String, dynamic>{'tier': 5};
      final quest = <String, dynamic>{'q1': true};

      final map = <String, dynamic>{
        'user_id': 'user-99',
        'island_state': island,
        'character_state': character,
        'season_pass_state': seasonPass,
        'quest_progress': quest,
        'quest_date': '2026-03-01',
        'gel_energy': 500,
        'total_earned_energy': 2000,
        'updated_at': '2026-03-01T12:00:00Z',
      };

      final result = MetaState.fromMap(map);

      expect(result.userId, 'user-99');
      expect(result.islandState, island);
      expect(result.characterState, character);
      expect(result.seasonPassState, seasonPass);
      expect(result.questProgress, quest);
      expect(result.questDate, '2026-03-01');
      expect(result.gelEnergy, 500);
      expect(result.totalEarnedEnergy, 2000);
      expect(result.updatedAt, DateTime.utc(2026, 3, 1, 12));
    });

    test('fromMap with all null optional fields', () {
      final map = <String, dynamic>{
        'user_id': 'user-1',
      };

      final result = MetaState.fromMap(map);

      expect(result.userId, 'user-1');
      expect(result.islandState, isNull);
      expect(result.characterState, isNull);
      expect(result.seasonPassState, isNull);
      expect(result.questProgress, isNull);
      expect(result.questDate, isNull);
      expect(result.gelEnergy, isNull);
      expect(result.totalEarnedEnergy, isNull);
      expect(result.updatedAt, isNull);
    });

    test('fromMap with empty map defaults userId to empty string', () {
      final map = <String, dynamic>{};

      final result = MetaState.fromMap(map);

      expect(result.userId, '');
    });

    test('fromMap with invalid updated_at string', () {
      final map = <String, dynamic>{
        'user_id': 'u1',
        'updated_at': '???',
      };

      final result = MetaState.fromMap(map);

      expect(result.updatedAt, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────
  // 4. PvpMatch
  // ─────────────────────────────────────────────────────────
  group('PvpMatch', () {
    test('fromMap with valid full data', () {
      final map = <String, dynamic>{
        'id': 'match-001',
        'player1_id': 'p1',
        'player2_id': 'p2',
        'seed': 123456,
        'status': 'completed',
        'player1_score': 800,
        'player2_score': 750,
        'winner_id': 'p1',
        'created_at': '2026-03-01T15:00:00Z',
      };

      final result = PvpMatch.fromMap(map);

      expect(result.id, 'match-001');
      expect(result.player1Id, 'p1');
      expect(result.player2Id, 'p2');
      expect(result.seed, 123456);
      expect(result.status, 'completed');
      expect(result.player1Score, 800);
      expect(result.player2Score, 750);
      expect(result.winnerId, 'p1');
      expect(result.createdAt, DateTime.utc(2026, 3, 1, 15));
    });

    test('fromMap with missing keys falls back to defaults', () {
      final map = <String, dynamic>{};

      final result = PvpMatch.fromMap(map);

      expect(result.id, '');
      expect(result.player1Id, '');
      expect(result.player2Id, isNull);
      expect(result.seed, 0);
      expect(result.status, 'unknown');
      expect(result.player1Score, isNull);
      expect(result.player2Score, isNull);
      expect(result.winnerId, isNull);
      expect(result.createdAt, isNull);
    });

    test('fromMap with null values on required fields', () {
      final map = <String, dynamic>{
        'id': null,
        'player1_id': null,
        'seed': null,
        'status': null,
      };

      final result = PvpMatch.fromMap(map);

      expect(result.id, '');
      expect(result.player1Id, '');
      expect(result.seed, 0);
      expect(result.status, 'unknown');
    });

    test('fromMap with invalid created_at string', () {
      final map = <String, dynamic>{
        'id': 'x',
        'player1_id': 'y',
        'seed': 1,
        'status': 'active',
        'created_at': 'bad-date',
      };

      final result = PvpMatch.fromMap(map);

      expect(result.createdAt, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────
  // 5. RedeemResult (sealed class)
  // ─────────────────────────────────────────────────────────
  group('RedeemResult', () {
    test('success variant holds product IDs', () {
      const result = RedeemResult.success(['gloo_plus', 'remove_ads']);

      expect(result, isA<RedeemSuccess>());
      expect((result as RedeemSuccess).productIds, ['gloo_plus', 'remove_ads']);
    });

    test('success variant with empty product list', () {
      const result = RedeemResult.success([]);

      expect(result, isA<RedeemSuccess>());
      expect((result as RedeemSuccess).productIds, isEmpty);
    });

    test('alreadyRedeemed is singleton', () {
      const a = RedeemResult.alreadyRedeemed;
      const b = RedeemResult.alreadyRedeemed;

      expect(a, isA<RedeemAlreadyRedeemed>());
      expect(identical(a, b), isTrue);
    });

    test('error is singleton', () {
      const a = RedeemResult.error;
      const b = RedeemResult.error;

      expect(a, isA<RedeemError>());
      expect(identical(a, b), isTrue);
    });

    test('pattern matching covers all variants', () {
      final variants = <RedeemResult>[
        const RedeemResult.success(['x']),
        RedeemResult.alreadyRedeemed,
        RedeemResult.error,
      ];

      final labels = <String>[];
      for (final r in variants) {
        switch (r) {
          case RedeemSuccess():
            labels.add('success');
          case RedeemAlreadyRedeemed():
            labels.add('already');
          case RedeemError():
            labels.add('error');
        }
      }

      expect(labels, ['success', 'already', 'error']);
    });
  });

  // ─────────────────────────────────────────────────────────
  // 6. BroadcastScore
  // ─────────────────────────────────────────────────────────
  group('BroadcastScore', () {
    test('fromMap with valid data', () {
      final map = <String, dynamic>{
        'user_id': 'u1',
        'score': 420,
        'timestamp': '2026-03-01T10:00:00Z',
      };

      final result = BroadcastScore.fromMap(map);

      expect(result.userId, 'u1');
      expect(result.score, 420);
      expect(result.timestamp, '2026-03-01T10:00:00Z');
    });

    test('fromMap with missing keys falls back to defaults', () {
      final map = <String, dynamic>{};

      final result = BroadcastScore.fromMap(map);

      expect(result.userId, isNull);
      expect(result.score, 0);
      expect(result.timestamp, '');
    });

    test('fromMap with null values', () {
      final map = <String, dynamic>{
        'user_id': null,
        'score': null,
        'timestamp': null,
      };

      final result = BroadcastScore.fromMap(map);

      expect(result.userId, isNull);
      expect(result.score, 0);
      expect(result.timestamp, '');
    });

    test('toMap and fromMap roundtrip', () {
      const original = BroadcastScore(
        userId: 'roundtrip-user',
        score: 777,
        timestamp: '2026-03-01T08:00:00Z',
      );

      final reconstructed = BroadcastScore.fromMap(original.toMap());

      expect(reconstructed.userId, original.userId);
      expect(reconstructed.score, original.score);
      expect(reconstructed.timestamp, original.timestamp);
    });

    test('toMap and fromMap roundtrip with null userId', () {
      const original = BroadcastScore(
        userId: null,
        score: 0,
        timestamp: '',
      );

      final reconstructed = BroadcastScore.fromMap(original.toMap());

      expect(reconstructed.userId, isNull);
      expect(reconstructed.score, 0);
      expect(reconstructed.timestamp, '');
    });
  });

  // ─────────────────────────────────────────────────────────
  // 7. BroadcastObstacle
  // ─────────────────────────────────────────────────────────
  group('BroadcastObstacle', () {
    test('fromMap with valid data', () {
      final map = <String, dynamic>{
        'user_id': 'attacker-1',
        'type': 'stone',
        'count': 3,
        'area_size': 4,
      };

      final result = BroadcastObstacle.fromMap(map);

      expect(result.userId, 'attacker-1');
      expect(result.type, 'stone');
      expect(result.count, 3);
      expect(result.areaSize, 4);
    });

    test('fromMap with missing keys uses defaults', () {
      final map = <String, dynamic>{};

      final result = BroadcastObstacle.fromMap(map);

      expect(result.userId, isNull);
      expect(result.type, 'ice');
      expect(result.count, 1);
      expect(result.areaSize, isNull);
    });

    test('fromMap with null optional areaSize', () {
      final map = <String, dynamic>{
        'user_id': 'u1',
        'type': 'ice',
        'count': 2,
        'area_size': null,
      };

      final result = BroadcastObstacle.fromMap(map);

      expect(result.areaSize, isNull);
    });

    test('toMap and fromMap roundtrip', () {
      const original = BroadcastObstacle(
        userId: 'obs-user',
        type: 'stone',
        count: 5,
        areaSize: 9,
      );

      final reconstructed = BroadcastObstacle.fromMap(original.toMap());

      expect(reconstructed.userId, original.userId);
      expect(reconstructed.type, original.type);
      expect(reconstructed.count, original.count);
      expect(reconstructed.areaSize, original.areaSize);
    });

    test('toMap and fromMap roundtrip with null areaSize', () {
      const original = BroadcastObstacle(
        userId: null,
        type: 'ice',
        count: 1,
      );

      final reconstructed = BroadcastObstacle.fromMap(original.toMap());

      expect(reconstructed.userId, isNull);
      expect(reconstructed.type, 'ice');
      expect(reconstructed.count, 1);
      expect(reconstructed.areaSize, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────
  // 8. BroadcastGameOver
  // ─────────────────────────────────────────────────────────
  group('BroadcastGameOver', () {
    test('fromMap with valid data', () {
      final map = <String, dynamic>{
        'user_id': 'loser-1',
        'score': 350,
      };

      final result = BroadcastGameOver.fromMap(map);

      expect(result.userId, 'loser-1');
      expect(result.score, 350);
    });

    test('fromMap with missing keys uses defaults', () {
      final map = <String, dynamic>{};

      final result = BroadcastGameOver.fromMap(map);

      expect(result.userId, isNull);
      expect(result.score, 0);
    });

    test('fromMap with null values', () {
      final map = <String, dynamic>{
        'user_id': null,
        'score': null,
      };

      final result = BroadcastGameOver.fromMap(map);

      expect(result.userId, isNull);
      expect(result.score, 0);
    });

    test('toMap and fromMap roundtrip', () {
      const original = BroadcastGameOver(
        userId: 'go-user',
        score: 999,
      );

      final reconstructed = BroadcastGameOver.fromMap(original.toMap());

      expect(reconstructed.userId, original.userId);
      expect(reconstructed.score, original.score);
    });

    test('toMap and fromMap roundtrip with null userId', () {
      const original = BroadcastGameOver(
        userId: null,
        score: 0,
      );

      final reconstructed = BroadcastGameOver.fromMap(original.toMap());

      expect(reconstructed.userId, isNull);
      expect(reconstructed.score, 0);
    });
  });
}
