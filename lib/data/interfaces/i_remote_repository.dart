import 'package:gloo/data/remote/dto/daily_puzzle.dart';
import 'package:gloo/data/remote/dto/leaderboard_entry.dart';
import 'package:gloo/data/remote/dto/meta_state.dart';
import 'package:gloo/data/remote/dto/pvp_match.dart';
import 'package:gloo/data/remote/dto/redeem_result.dart';

/// Abstract interface for remote data access.
/// Mirrors the public API of [RemoteRepository] to allow testable abstractions.
abstract class IRemoteRepository {
  bool get isConfigured;

  // ── Skor kaydet ─────────────────────────────────────────────────────────

  Future<void> submitScore({
    required String mode,
    required int value,
  });

  // ── Global sıralama ─────────────────────────────────────────────────────

  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    required String mode,
    int limit = 50,
    bool weekly = false,
  });

  Future<int?> getUserRank({
    required String mode,
    bool weekly = false,
  });

  // ── Profil ──────────────────────────────────────────────────────────────

  Future<void> ensureProfile({String? username});

  // ── Günlük Bulmaca ─────────────────────────────────────────────────────

  Future<DailyPuzzle?> getDailyPuzzle();

  Future<void> submitDailyResult({
    required int score,
    required bool completed,
  });

  // ── PvP ────────────────────────────────────────────────────────────────────

  Future<({String id, int seed})?> createPvpMatch({
    String? opponentId,
  });

  Future<void> submitPvpResult({
    required String matchId,
    required int score,
  });

  Future<void> updateElo({required int newElo});

  Future<PvpMatch?> getPvpMatch(String matchId);

  Future<void> incrementPvpStats({required bool isWin});

  // ── IAP Receipt Dogrulama ────────────────────────────────────────────────

  Future<bool?> verifyPurchase({
    required String platform,
    required String receipt,
    required String productId,
  });

  // ── Redeem Code ──────────────────────────────────────────────────────────

  Future<RedeemResult> redeemCode(String code);

  // ── Meta-Game State ────────────────────────────────────────────────────────

  Future<void> saveMetaState({
    Map<String, int>? islandState,
    Map<String, dynamic>? characterState,
    Map<String, int>? seasonPassState,
    Map<String, int>? questProgress,
    String? questDate,
    int? gelEnergy,
    int? totalEarnedEnergy,
  });

  Future<MetaState?> loadMetaState();

  // ── GDPR: Uzak Veri Silme ───────────────────────────────────────────────

  Future<bool> deleteUserData();
}
