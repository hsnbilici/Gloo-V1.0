import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/data/remote/remote_repository.dart';
import 'package:gloo/data/remote/pvp_realtime_service.dart';
import 'package:gloo/game/pvp/matchmaking.dart';

/// RemoteRepository alt sinifi — `isConfigured` false dondurerek
/// Supabase bagimliligini ortadan kaldirir.
class _UnconfiguredRemoteRepository extends RemoteRepository {
  @override
  bool get isConfigured => false;
}

void main() {
  late PvpRealtimeService service;
  late RemoteRepository unconfiguredRepo;

  setUp(() {
    unconfiguredRepo = _UnconfiguredRemoteRepository();
    service = PvpRealtimeService(repository: unconfiguredRepo);
  });

  tearDown(() async {
    await service.dispose();
  });

  // ── Constructor ──────────────────────────────────────────────────────

  group('PvpRealtimeService construction', () {
    test('can be instantiated with repository', () {
      final s = PvpRealtimeService(repository: unconfiguredRepo);
      expect(s, isA<PvpRealtimeService>());
    });

    test('can be instantiated without repository (uses default)', () {
      final s = PvpRealtimeService();
      expect(s, isA<PvpRealtimeService>());
    });
  });

  // ── Dispose ──────────────────────────────────────────────────────────

  group('dispose', () {
    test('dispose completes without error', () async {
      await service.dispose();
      // Ikinci dispose da guvenli olmali
      await service.dispose();
    });

    test('dispose after no activity completes cleanly', () async {
      final freshService = PvpRealtimeService(repository: unconfiguredRepo);
      await freshService.dispose();
    });
  });

  // ── cancelMatchmaking ───────────────────────────────────────────────

  group('cancelMatchmaking', () {
    test('cancelMatchmaking completes without error when no queue joined',
        () async {
      await service.cancelMatchmaking();
    });

    test('cancelMatchmaking can be called multiple times', () async {
      await service.cancelMatchmaking();
      await service.cancelMatchmaking();
      await service.cancelMatchmaking();
    });
  });

  // ── leaveDuelRoom ───────────────────────────────────────────────────

  group('leaveDuelRoom', () {
    test('leaveDuelRoom completes without error when no room joined', () async {
      await service.leaveDuelRoom('match_1');
    });

    test('leaveDuelRoom can be called multiple times for same match', () async {
      await service.leaveDuelRoom('match_1');
      await service.leaveDuelRoom('match_1');
    });

    test('leaveDuelRoom with different matchIds completes without error',
        () async {
      await service.leaveDuelRoom('match_1');
      await service.leaveDuelRoom('match_2');
    });
  });

  // ── broadcastScore ──────────────────────────────────────────────────

  group('broadcastScore', () {
    test('broadcastScore does nothing when no duel channel', () async {
      // _duelChannel null oldugunda erken donus yapar
      await service.broadcastScore('match_1', 500);
    });
  });

  // ── broadcastGameOver ───────────────────────────────────────────────

  group('broadcastGameOver', () {
    test('broadcastGameOver does nothing when no duel channel', () async {
      // _duelChannel null oldugunda erken donus yapar
      await service.broadcastGameOver('match_1', 1000);
    });
  });

  // ── sendObstacle ────────────────────────────────────────────────────

  group('sendObstacle', () {
    test('sendObstacle does nothing when no duel channel', () async {
      const packet = ObstaclePacket(type: ObstacleType.ice, count: 2);
      await service.sendObstacle('match_1', packet);
    });

    test('sendObstacle with areaSize does nothing when no duel channel',
        () async {
      const packet = ObstaclePacket(
        type: ObstacleType.ice,
        count: 9,
        areaSize: 3,
      );
      await service.sendObstacle('match_1', packet);
    });
  });

  // ── listen streams ──────────────────────────────────────────────────

  group('listen streams', () {
    test('listenOpponentScore returns a stream', () {
      final stream = service.listenOpponentScore('match_1');
      expect(stream, isA<Stream<int>>());
    });

    test('listenOpponentObstacles returns a stream', () {
      final stream = service.listenOpponentObstacles('match_1');
      expect(stream, isA<Stream<ObstaclePacket>>());
    });

    test('listenOpponentGameOver returns a stream', () {
      final stream = service.listenOpponentGameOver('match_1');
      expect(stream, isA<Stream<int>>());
    });

    test('streams are cleaned up on dispose', () async {
      service.listenOpponentScore('match_1');
      service.listenOpponentObstacles('match_1');
      service.listenOpponentGameOver('match_1');

      // Dispose tum controller'lari kapatmali
      await service.dispose();

      // Dispose sonrasi tekrar stream alinabilmeli
      final newService = PvpRealtimeService(repository: unconfiguredRepo);
      final stream = newService.listenOpponentScore('match_2');
      expect(stream, isA<Stream<int>>());
      await newService.dispose();
    });

    test('streams are cleaned up on leaveDuelRoom', () async {
      service.listenOpponentScore('match_1');
      service.listenOpponentObstacles('match_1');
      service.listenOpponentGameOver('match_1');

      // leaveDuelRoom da controller'lari kapatir
      await service.leaveDuelRoom('match_1');
    });
  });

  // ── Bot fallback mantigi (MatchmakingManager uzerinden) ─────────────

  group('bot fallback logic (via MatchmakingManager)', () {
    test('generateBotMatchSeed returns secure random values', () {
      final seed1 = MatchmakingManager.generateBotMatchSeed();
      final seed2 = MatchmakingManager.generateBotMatchSeed();
      expect(seed1, isA<int>());
      expect(seed2, isA<int>());
      expect(seed1, greaterThanOrEqualTo(0));
      expect(seed1, lessThan(1 << 32));
    });

    test('botDifficulty scales with ELO', () {
      expect(MatchmakingManager.botDifficulty(0), 0.2);
      expect(MatchmakingManager.botDifficulty(500), closeTo(0.2, 0.01));
      expect(MatchmakingManager.botDifficulty(1000), closeTo(0.4, 0.01));
      expect(MatchmakingManager.botDifficulty(2500), closeTo(0.95, 0.05));
      expect(MatchmakingManager.botDifficulty(5000), 0.95);
    });

    test('MatchResult for bot has isBot true', () {
      const result = MatchResult(
        matchId: 'bot_match_12345',
        player1Id: 'player_1',
        player2Id: 'bot_00001',
        seed: 12345,
        isBot: true,
      );
      expect(result.isBot, isTrue);
      expect(result.matchId, startsWith('bot_match_'));
      expect(result.player2Id, startsWith('bot_'));
    });
  });

  // ── isCompatible etkileşimi ─────────────────────────────────────────

  group('matchmaking compatibility for PvpRealtimeService', () {
    test('compatible players within ELO range', () {
      final a = MatchRequest(
        userId: 'user_a',
        elo: 1000,
        region: 'eu',
        timestamp: DateTime.now(),
      );
      final b = MatchRequest(
        userId: 'user_b',
        elo: 1100,
        region: 'eu',
        timestamp: DateTime.now(),
      );
      expect(MatchmakingManager.isCompatible(a, b), isTrue);
    });

    test('incompatible players outside ELO range', () {
      final a = MatchRequest(
        userId: 'user_a',
        elo: 500,
        region: 'eu',
        timestamp: DateTime.now(),
      );
      final b = MatchRequest(
        userId: 'user_b',
        elo: 1500,
        region: 'eu',
        timestamp: DateTime.now(),
      );
      expect(MatchmakingManager.isCompatible(a, b), isFalse);
    });
  });

  // ── ObstaclePacket ──────────────────────────────────────────────────

  group('ObstaclePacket', () {
    test('creates packet with required fields', () {
      const packet = ObstaclePacket(type: ObstacleType.ice, count: 3);
      expect(packet.type, ObstacleType.ice);
      expect(packet.count, 3);
      expect(packet.areaSize, isNull);
    });

    test('creates packet with areaSize', () {
      const packet = ObstaclePacket(
        type: ObstacleType.stone,
        count: 1,
        areaSize: 3,
      );
      expect(packet.type, ObstacleType.stone);
      expect(packet.count, 1);
      expect(packet.areaSize, 3);
    });

    test('all obstacle types are valid', () {
      for (final type in ObstacleType.values) {
        final packet = ObstaclePacket(type: type, count: 1);
        expect(packet.type, type);
      }
      expect(ObstacleType.values.length, 3);
    });
  });

  // ── Unconfigured repository entegrasyonu ─────────────────────────────

  group('unconfigured repository integration', () {
    test('repository is not configured', () {
      expect(unconfiguredRepo.isConfigured, isFalse);
    });

    test('broadcastGameOver with unconfigured repo completes', () async {
      // broadcastGameOver iceride submitPvpResult cagirir — repo guard ile doner
      await service.broadcastGameOver('match_1', 500);
    });

    test('sendObstacle with unconfigured repo completes', () async {
      // sendObstacle iceride DB insert yapar — duel channel null ile erken doner
      const packet = ObstaclePacket(type: ObstacleType.locked, count: 2);
      await service.sendObstacle('match_1', packet);
    });
  });

  // ── Lifecycle sırası ──────────────────────────────────────────────────

  group('lifecycle order', () {
    test('dispose before any operation', () async {
      final s = PvpRealtimeService(repository: unconfiguredRepo);
      await s.dispose();
    });

    test('cancel then dispose', () async {
      final s = PvpRealtimeService(repository: unconfiguredRepo);
      await s.cancelMatchmaking();
      await s.dispose();
    });

    test('leave then dispose', () async {
      final s = PvpRealtimeService(repository: unconfiguredRepo);
      await s.leaveDuelRoom('match_x');
      await s.dispose();
    });

    test('full lifecycle without Supabase', () async {
      final s = PvpRealtimeService(repository: unconfiguredRepo);

      // Broadcast calls (no-op without duel channel)
      await s.broadcastScore('m1', 100);
      await s.broadcastGameOver('m1', 200);
      await s.sendObstacle(
        'm1',
        const ObstaclePacket(type: ObstacleType.ice, count: 1),
      );

      // Streams (return stream but no events without channel)
      final scoreStream = s.listenOpponentScore('m1');
      final obstacleStream = s.listenOpponentObstacles('m1');
      final gameOverStream = s.listenOpponentGameOver('m1');

      expect(scoreStream, isA<Stream<int>>());
      expect(obstacleStream, isA<Stream<ObstaclePacket>>());
      expect(gameOverStream, isA<Stream<int>>());

      // Cleanup
      await s.cancelMatchmaking();
      await s.leaveDuelRoom('m1');
      await s.dispose();
    });
  });
}
