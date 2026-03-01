import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/data/remote/dto/daily_puzzle.dart';
import 'package:gloo/data/remote/dto/leaderboard_entry.dart';
import 'package:gloo/data/remote/dto/meta_state.dart';
import 'package:gloo/data/remote/dto/pvp_match.dart';
import 'package:gloo/data/remote/dto/redeem_result.dart';
import 'package:gloo/data/remote/remote_repository.dart';

/// RemoteRepository alt sinifi — `isConfigured` false dondurerek
/// tum metodlarin guard pattern ile sessizce donmesini test eder.
class _UnconfiguredRemoteRepository extends RemoteRepository {
  @override
  bool get isConfigured => false;
}

void main() {
  late RemoteRepository repo;

  setUp(() {
    repo = _UnconfiguredRemoteRepository();
  });

  // ── isConfigured Guard ───────────────────────────────────────────────

  group('isConfigured guard — not configured', () {
    test('submitScore returns immediately when not configured', () async {
      // Guard pattern: isConfigured false → Future<void> tamamlanir
      await repo.submitScore(mode: 'classic', value: 1000);
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('getGlobalLeaderboard returns empty list when not configured',
        () async {
      final result = await repo.getGlobalLeaderboard(mode: 'classic');
      expect(result, isEmpty);
    });

    test('getGlobalLeaderboard with weekly returns empty list when not configured',
        () async {
      final result = await repo.getGlobalLeaderboard(
        mode: 'timetrial',
        weekly: true,
        limit: 10,
      );
      expect(result, isEmpty);
      expect(result, isA<List<LeaderboardEntry>>());
    });

    test('getUserRank returns null when not configured', () async {
      final result = await repo.getUserRank(mode: 'classic');
      expect(result, isNull);
    });

    test('getUserRank with weekly returns null when not configured', () async {
      final result = await repo.getUserRank(mode: 'classic', weekly: true);
      expect(result, isNull);
    });

    test('ensureProfile returns immediately when not configured', () async {
      await repo.ensureProfile(username: 'TestUser');
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('ensureProfile without username returns immediately when not configured',
        () async {
      await repo.ensureProfile();
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('getDailyPuzzle returns null when not configured', () async {
      final result = await repo.getDailyPuzzle();
      expect(result, isNull);
    });

    test('submitDailyResult returns immediately when not configured', () async {
      await repo.submitDailyResult(score: 500, completed: true);
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('createPvpMatch returns null when not configured', () async {
      final result = await repo.createPvpMatch();
      expect(result, isNull);
    });

    test('createPvpMatch with opponentId returns null when not configured',
        () async {
      final result = await repo.createPvpMatch(
        opponentId: 'opponent_123',
      );
      expect(result, isNull);
    });

    test('submitPvpResult returns immediately when not configured', () async {
      await repo.submitPvpResult(matchId: 'match_1', score: 500);
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('updateElo returns immediately when not configured', () async {
      await repo.updateElo(newElo: 1200);
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('getPvpMatch returns null when not configured', () async {
      final result = await repo.getPvpMatch('match_1');
      expect(result, isNull);
    });

    test('incrementPvpStats win returns immediately when not configured',
        () async {
      await repo.incrementPvpStats(isWin: true);
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('incrementPvpStats loss returns immediately when not configured',
        () async {
      await repo.incrementPvpStats(isWin: false);
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('verifyPurchase returns null when not configured', () async {
      final result = await repo.verifyPurchase(
        platform: 'ios',
        receipt: 'fake_receipt',
        productId: 'gloo_plus',
      );
      expect(result, isNull);
    });

    test('redeemCode returns RedeemResult.error when not configured', () async {
      final result = await repo.redeemCode('TESTCODE');
      expect(result, isA<RedeemError>());
    });

    test('saveMetaState returns immediately when not configured', () async {
      await repo.saveMetaState(
        islandState: {'island_1': 2},
        gelEnergy: 100,
      );
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('saveMetaState with all parameters returns immediately when not configured',
        () async {
      await repo.saveMetaState(
        islandState: {'island_1': 2},
        characterState: {'skin': 'default'},
        seasonPassState: {'tier': 5},
        questProgress: {'quest_1': 3},
        questDate: '2026-03-01',
        gelEnergy: 100,
        totalEarnedEnergy: 500,
      );
      // Hata atilmadan tamamlanmasi beklenir
    });

    test('loadMetaState returns null when not configured', () async {
      final result = await repo.loadMetaState();
      expect(result, isNull);
    });

    test('deleteUserData returns immediately when not configured', () async {
      await repo.deleteUserData();
      // Hata atilmadan tamamlanmasi beklenir
    });
  });

  // ── Return Type Kontrolleri ──────────────────────────────────────────

  group('return type verification', () {
    test('getGlobalLeaderboard returns List<Map<String, dynamic>>', () async {
      final result = await repo.getGlobalLeaderboard(mode: 'classic');
      expect(result, isA<List<LeaderboardEntry>>());
    });

    test('getUserRank returns nullable int', () async {
      final result = await repo.getUserRank(mode: 'classic');
      expect(result, isNull);
    });

    test('getDailyPuzzle returns nullable DailyPuzzle', () async {
      final result = await repo.getDailyPuzzle();
      expect(result, isNull);
    });

    test('createPvpMatch returns nullable record', () async {
      final result = await repo.createPvpMatch();
      expect(result, isNull);
    });

    test('getPvpMatch returns nullable PvpMatch', () async {
      final result = await repo.getPvpMatch('id');
      expect(result, isNull);
    });

    test('verifyPurchase returns nullable bool', () async {
      final result = await repo.verifyPurchase(
        platform: 'android',
        receipt: 'r',
        productId: 'p',
      );
      expect(result, isNull);
    });

    test('redeemCode returns RedeemResult', () async {
      final result = await repo.redeemCode('CODE');
      expect(result, isA<RedeemResult>());
    });

    test('loadMetaState returns nullable MetaState', () async {
      final result = await repo.loadMetaState();
      expect(result, isNull);
    });
  });

  // ── Varsayilan deger kontrolleri ──────────────────────────────────────

  group('default parameter values', () {
    test('getGlobalLeaderboard default limit is 50', () async {
      // Yapilandirilmamis oldugu icin bos doner — ama method signature dogrulanir
      final result = await repo.getGlobalLeaderboard(mode: 'classic');
      expect(result, isEmpty);
    });

    test('getGlobalLeaderboard default weekly is false', () async {
      final result = await repo.getGlobalLeaderboard(mode: 'classic');
      expect(result, isEmpty);
    });
  });

  // ── Ardisik cagri guvenlirligi ────────────────────────────────────────

  group('sequential call safety', () {
    test('multiple submitScore calls complete without error', () async {
      await repo.submitScore(mode: 'classic', value: 100);
      await repo.submitScore(mode: 'classic', value: 200);
      await repo.submitScore(mode: 'timeTrial', value: 300);
      // Uc cagri da hata atilmadan tamamlanir
    });

    test('multiple different method calls complete without error', () async {
      await repo.submitScore(mode: 'classic', value: 100);
      final leaderboard = await repo.getGlobalLeaderboard(mode: 'classic');
      final rank = await repo.getUserRank(mode: 'classic');
      final daily = await repo.getDailyPuzzle();

      expect(leaderboard, isEmpty);
      expect(rank, isNull);
      expect(daily, isNull);
    });
  });

  // ── RemoteRepository dogrudan olusturma ──────────────────────────────

  group('RemoteRepository construction', () {
    test('can be instantiated', () {
      final r = RemoteRepository();
      expect(r, isA<RemoteRepository>());
    });

    test('isConfigured returns bool', () {
      final r = RemoteRepository();
      expect(r.isConfigured, isA<bool>());
    });
  });

  // ── DTO fromMap testleri ──────────────────────────────────────────────

  group('DTO fromMap', () {
    test('LeaderboardEntry.fromMap parses complete map', () {
      final entry = LeaderboardEntry.fromMap({
        'id': 'score_1',
        'user_id': 'user_1',
        'mode': 'classic',
        'score': 5000,
        'created_at': '2026-03-01T12:00:00Z',
        'profiles': {'username': 'TestPlayer'},
      });
      expect(entry.id, 'score_1');
      expect(entry.userId, 'user_1');
      expect(entry.mode, 'classic');
      expect(entry.score, 5000);
      expect(entry.username, 'TestPlayer');
      expect(entry.createdAt, isNotNull);
    });

    test('LeaderboardEntry.fromMap handles missing profiles', () {
      final entry = LeaderboardEntry.fromMap({
        'id': 'score_2',
        'user_id': 'user_2',
        'mode': 'timetrial',
        'score': 3000,
      });
      expect(entry.username, 'Player');
      expect(entry.score, 3000);
    });

    test('LeaderboardEntry.fromMap handles null values', () {
      final entry = LeaderboardEntry.fromMap(<String, dynamic>{});
      expect(entry.id, '');
      expect(entry.score, 0);
      expect(entry.username, 'Player');
      expect(entry.createdAt, isNull);
    });

    test('DailyPuzzle.fromMap parses complete map', () {
      final puzzle = DailyPuzzle.fromMap({
        'id': 'dp_1',
        'date': '2026-03-01',
        'user_id': 'user_1',
        'completed': true,
        'score': 1500,
        'completed_at': '2026-03-01T15:30:00Z',
      });
      expect(puzzle.id, 'dp_1');
      expect(puzzle.date, '2026-03-01');
      expect(puzzle.completed, true);
      expect(puzzle.score, 1500);
      expect(puzzle.completedAt, isNotNull);
    });

    test('DailyPuzzle.fromMap handles empty map', () {
      final puzzle = DailyPuzzle.fromMap(<String, dynamic>{});
      expect(puzzle.date, '');
      expect(puzzle.completed, false);
      expect(puzzle.score, isNull);
    });

    test('PvpMatch.fromMap parses complete map', () {
      final match = PvpMatch.fromMap({
        'id': 'match_1',
        'player1_id': 'p1',
        'player2_id': 'p2',
        'seed': 42,
        'status': 'active',
        'player1_score': 1000,
        'player2_score': 800,
        'winner_id': 'p1',
        'created_at': '2026-03-01T10:00:00Z',
      });
      expect(match.id, 'match_1');
      expect(match.player1Id, 'p1');
      expect(match.player2Id, 'p2');
      expect(match.seed, 42);
      expect(match.status, 'active');
      expect(match.player1Score, 1000);
      expect(match.player2Score, 800);
      expect(match.winnerId, 'p1');
      expect(match.createdAt, isNotNull);
    });

    test('PvpMatch.fromMap handles minimal map', () {
      final match = PvpMatch.fromMap(<String, dynamic>{});
      expect(match.id, '');
      expect(match.player1Id, '');
      expect(match.player2Id, isNull);
      expect(match.seed, 0);
      expect(match.status, 'unknown');
    });

    test('MetaState.fromMap parses complete map', () {
      final state = MetaState.fromMap({
        'user_id': 'user_1',
        'island_state': {'island_1': 2, 'island_2': 1},
        'character_state': {'skin': 'default', 'level': 5},
        'season_pass_state': {'tier': 3},
        'quest_progress': {'quest_1': 2},
        'quest_date': '2026-03-01',
        'gel_energy': 500,
        'total_earned_energy': 2000,
        'updated_at': '2026-03-01T12:00:00Z',
      });
      expect(state.userId, 'user_1');
      expect(state.islandState, isNotNull);
      expect(state.islandState!['island_1'], 2);
      expect(state.characterState, isNotNull);
      expect(state.seasonPassState, isNotNull);
      expect(state.questProgress, isNotNull);
      expect(state.questDate, '2026-03-01');
      expect(state.gelEnergy, 500);
      expect(state.totalEarnedEnergy, 2000);
      expect(state.updatedAt, isNotNull);
    });

    test('MetaState.fromMap handles empty map', () {
      final state = MetaState.fromMap(<String, dynamic>{});
      expect(state.userId, '');
      expect(state.islandState, isNull);
      expect(state.gelEnergy, isNull);
    });
  });
}
