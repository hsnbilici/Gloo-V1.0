import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../interfaces/i_remote_repository.dart';
import 'dto/daily_puzzle.dart';
import 'dto/leaderboard_entry.dart';
import 'dto/meta_state.dart';
import 'dto/pvp_match.dart';
import 'dto/redeem_result.dart';
import 'supabase_client.dart';

/// Supabase uzak deposu — profil, skor, günlük bulmaca ve sıralama.
///
/// Tablo yapısı GDD 4.8'de tanımlanan SQL şemasına uygundur:
/// - `profiles`: kullanıcı profilleri (auth.users ile 1:1)
/// - `scores`: oyun skorları (mode, score, created_at)
/// - `daily_tasks`: günlük bulmaca tamamlanma durumu
class RemoteRepository implements IRemoteRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  String? get _userId => SupabaseConfig.currentUserId;

  /// Supabase yapilandirilmis ve initialize edilmis mi?
  bool get isConfigured =>
      SupabaseConfig.isConfigured && SupabaseConfig.isInitialized;

  /// ELO submission idempotency guard — submitted matchId'leri izler.
  /// Duplicate submission'ları önler (network retry veya double-tap).
  final Set<String> _submittedMatchIds = {};

  /// Basit retry mekanizmasi — network hatasinda exponential backoff ile tekrar dener.
  Future<T?> _retry<T>(Future<T> Function() action,
      {int maxAttempts = 3}) async {
    for (var i = 0; i < maxAttempts; i++) {
      try {
        return await action();
      } catch (e) {
        if (i == maxAttempts - 1) rethrow;
        await Future<void>.delayed(
            Duration(milliseconds: 500 * (i + 1) + Random().nextInt(200)));
      }
    }
    return null;
  }

  // ── Skor kaydet ─────────────────────────────────────────────────────────
  /// Skoru sunucu tarafinda dogrulayan RPC fonksiyonu uzerinden gonderir.
  /// Mod bazli maks skor siniri sunucu tarafinda uygulanir.
  Future<void> submitScore({
    required String mode,
    required int value,
  }) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      final result = await _retry(() => _client.rpc('submit_score', params: {
            'p_mode': mode,
            'p_score': value,
          }));

      if (result is Map && result['error'] != null) {
        if (kDebugMode)
          debugPrint(
              'RemoteRepository.submitScore rejected: ${result['error']}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.submitScore error: $e');
    }
  }

  // ── Global sıralama ─────────────────────────────────────────────────────
  /// [mode]: 'classic' | 'timetrial'
  /// [weekly]: true ise son 7 günlük filtre uygulanır
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    required String mode,
    int limit = 50,
    bool weekly = false,
  }) async {
    if (!isConfigured) return [];
    try {
      var query = _client
          .from('leaderboard_view')
          .select('id, user_id, mode, score, created_at, username')
          .eq('mode', mode);

      if (weekly) {
        final weekAgo =
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
        query = query.gte('created_at', weekAgo);
      }

      final data = await query.order('score', ascending: false).limit(limit);

      return (data as List)
          .map((e) =>
              LeaderboardEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint('RemoteRepository.getGlobalLeaderboard error: $e');
      return [];
    }
  }

  /// Kullanıcının belirli moddaki en yüksek sırasını döner.
  /// Sunucu tarafında tek RPC çağrısı ile hesaplanır.
  Future<int?> getUserRank({
    required String mode,
    bool weekly = false,
  }) async {
    if (!isConfigured) return null;
    final uid = _userId;
    if (uid == null) return null;
    try {
      final result = await _client.rpc('get_user_rank', params: {
        'p_mode': mode,
        'p_weekly': weekly,
      });
      if (result == null) return null;
      return result as int;
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.getUserRank error: $e');
      return null;
    }
  }

  // ── PvP ELO Sıralama ───────────────────────────────────────────────────
  /// ELO bazli PvP sıralamasını döner.
  Future<List<LeaderboardEntry>> getEloLeaderboard({int limit = 50}) async {
    if (!isConfigured) return [];
    try {
      final data = await _client
          .from('profiles')
          .select('id, username, elo')
          .gt('elo', 0)
          .order('elo', ascending: false)
          .limit(limit);

      return (data as List).map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return LeaderboardEntry(
          id: map['id'] as String? ?? '',
          userId: map['id'] as String? ?? '',
          mode: 'pvp',
          score: map['elo'] as int? ?? 0,
          username: map['username'] as String? ?? 'Player',
          createdAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint('RemoteRepository.getEloLeaderboard error: $e');
      return [];
    }
  }

  // ── Profil ──────────────────────────────────────────────────────────────
  Future<void> ensureProfile({String? username}) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client.from('profiles').upsert({
        'id': uid,
        'username': username ?? 'Player_${uid.substring(0, 6)}',
      });
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.ensureProfile error: $e');
    }
  }

  // ── Günlük Bulmaca ─────────────────────────────────────────────────────
  Future<DailyPuzzle?> getDailyPuzzle() async {
    if (!isConfigured) return null;
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final data = await _client
          .from('daily_tasks')
          .select()
          .eq('date', today)
          .maybeSingle();
      if (data == null) return null;
      return DailyPuzzle.fromMap(data);
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.getDailyPuzzle error: $e');
      return null;
    }
  }

  Future<void> submitDailyResult({
    required int score,
    required bool completed,
  }) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await _client.from('daily_tasks').upsert({
        'date': today,
        'user_id': uid,
        'completed': completed,
        'score': score,
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
      });
    } catch (e) {
      if (kDebugMode)
        debugPrint('RemoteRepository.submitDailyResult error: $e');
    }
  }

  // ── PvP ────────────────────────────────────────────────────────────────────

  /// Yeni PvP maci olustur. Seed sunucu tarafinda uretilir (DB DEFAULT).
  /// [opponentId] null ise bot eslestirme.
  Future<({String id, int seed})?> createPvpMatch({
    String? opponentId,
  }) async {
    if (!isConfigured) return null;
    final uid = _userId;
    if (uid == null) return null;
    try {
      final data = await _client
          .from('pvp_matches')
          .insert({
            'player1_id': uid,
            'player2_id': opponentId,
            'status': 'active',
          })
          .select('id, seed')
          .single();
      return (id: data['id'] as String, seed: data['seed'] as int);
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.createPvpMatch error: $e');
      return null;
    }
  }

  /// Mac skorunu sunucu tarafinda kaydet.
  /// Winner belirleme ve mac tamamlama sunucu tarafinda (RPC) yapilir.
  ///
  /// Idempotent: ayni matchId'ye ait duplicate submission'lar sessizce yoksayilir.
  /// Orn: network timeout veya double-tap retry'lerinde.
  Future<void> submitPvpResult({
    required String matchId,
    required int score,
  }) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;

    // Idempotency guard: ayni matchId daha once submit edilmis mi?
    if (_submittedMatchIds.contains(matchId)) {
      if (kDebugMode) {
        debugPrint(
            'RemoteRepository.submitPvpResult: duplicate matchId=$matchId skipped (idempotent)');
      }
      return;
    }

    try {
      await _retry(() => _client.rpc('submit_pvp_score', params: {
            'p_match_id': matchId,
            'p_score': score,
          }));
      // Basarili submission sonrasi matchId'yi markala
      _submittedMatchIds.add(matchId);
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.submitPvpResult error: $e');
    }
  }

  /// ELO puanini sunucu tarafinda hesapla ve guncelle.
  ///
  /// Edge Function server-side ELO hesaplamasi yapar, rate limiting ve
  /// duplicate match korumasini icerir.
  /// Fallback: Edge Function basarisiz olursa dogrudan profile gunceller.
  Future<void> updateElo({
    required int newElo,
    String? matchId,
    String? outcome,
    int? playerScore,
    int? opponentScore,
  }) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;

    // Edge Function ile sunucu tarafinda hesaplama
    if (matchId != null && outcome != null) {
      try {
        await _client.functions.invoke('calculate-elo', body: {
          'match_id': matchId,
          'outcome': outcome,
          'player_score': playerScore ?? 0,
          'opponent_score': opponentScore ?? 0,
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('RemoteRepository.updateElo RPC error: $e');
        }
        // Guvenlik: RPC hatasi durumunda client-side ELO yazmiyoruz.
        // ELO yalnizca sunucu tarafinda hesaplanmali.
      }
      return;
    }

    // Fallback: yalnizca bot maclari icin (matchId == null)
    try {
      await _client.from('profiles').update({'elo': newElo}).eq('id', uid);
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.updateElo error: $e');
    }
  }

  /// PvP mac bilgisi getir.
  Future<PvpMatch?> getPvpMatch(String matchId) async {
    if (!isConfigured) return null;
    try {
      final data = await _client
          .from('pvp_matches')
          .select()
          .eq('id', matchId)
          .maybeSingle();
      if (data == null) return null;
      return PvpMatch.fromMap(data);
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.getPvpMatch error: $e');
      return null;
    }
  }

  /// PvP istatistiklerini atomik olarak guncelle (galibiyet/maglubiyet).
  /// Sunucu tarafinda `pvp_wins = pvp_wins + 1` seklinde atomic increment yapar.
  /// Race condition riski yoktur.
  Future<void> incrementPvpStats({required bool isWin}) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client.rpc('increment_pvp_stat', params: {
        'p_stat': isWin ? 'win' : 'loss',
      });
    } catch (e) {
      if (kDebugMode)
        debugPrint('RemoteRepository.incrementPvpStats error: $e');
    }
  }

  // ── IAP Receipt Dogrulama ────────────────────────────────────────────────

  /// Satin alim receipt'ini sunucu tarafinda dogrular.
  /// Basarili dogrulama icin `true`, hata veya dogrulama basarisizliginda `false` doner.
  /// Network hatasi durumunda `null` doner (graceful degradation icin).
  Future<bool?> verifyPurchase({
    required String platform,
    required String receipt,
    required String productId,
  }) async {
    if (!isConfigured) return null;
    try {
      final response = await _client.functions.invoke(
        'verify-purchase',
        body: {
          'platform': platform,
          'receipt': receipt,
          'productId': productId,
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['verified'] == true;
      }

      if (kDebugMode) {
        debugPrint(
          'RemoteRepository.verifyPurchase rejected: ${response.data}',
        );
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.verifyPurchase error: $e');
      return null; // network hatasi — graceful degradation
    }
  }

  // ── Redeem Code ──────────────────────────────────────────────────────────

  /// Kodu Edge Function uzerinden dogrular. Gecerli ise urun ID listesi doner.
  /// Client dogrudan redeem_codes tablosuna erismez — tum islem sunucu tarafinda yapilir.
  ///
  /// Return degerleri:
  /// - `RedeemResult.success(productIds)` — kod basariyla kullanildi
  /// - `RedeemResult.alreadyRedeemed` — kullanici bu kodu daha once kullanmis
  /// - `RedeemResult.error` — gecersiz, suresi dolmus veya baska bir hata
  Future<RedeemResult> redeemCode(String code) async {
    if (!isConfigured) return RedeemResult.error;
    try {
      final response = await _client.functions.invoke(
        'redeem-code',
        body: {'code': code.toUpperCase()},
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        final productIds = (data['productIds'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        return RedeemResult.success(productIds);
      }

      // Per-user limit: kullanici bu kodu daha once kullanmis
      if (response.status == 409) {
        return RedeemResult.alreadyRedeemed;
      }

      if (kDebugMode)
        debugPrint('RemoteRepository.redeemCode rejected: ${response.data}');
      return RedeemResult.error;
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.redeemCode error: $e');
      return RedeemResult.error;
    }
  }

  // ── Meta-Game State ────────────────────────────────────────────────────────

  /// Meta-game state'ini Supabase'e kaydet (island, character, season_pass, quest).
  Future<void> saveMetaState({
    Map<String, int>? islandState,
    Map<String, dynamic>? characterState,
    Map<String, int>? seasonPassState,
    Map<String, int>? questProgress,
    String? questDate,
    int? gelEnergy,
    int? totalEarnedEnergy,
  }) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      final data = <String, dynamic>{
        'user_id': uid,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (islandState != null) data['island_state'] = islandState;
      if (characterState != null) data['character_state'] = characterState;
      if (seasonPassState != null) data['season_pass_state'] = seasonPassState;
      if (questProgress != null) data['quest_progress'] = questProgress;
      if (questDate != null) data['quest_date'] = questDate;
      if (gelEnergy != null) data['gel_energy'] = gelEnergy;
      if (totalEarnedEnergy != null) {
        data['total_earned_energy'] = totalEarnedEnergy;
      }

      await _client.from('meta_states').upsert(data);
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.saveMetaState error: $e');
    }
  }

  /// Meta-game state'ini Supabase'den yukle.
  Future<MetaState?> loadMetaState() async {
    if (!isConfigured) return null;
    final uid = _userId;
    if (uid == null) return null;
    try {
      final data = await _client
          .from('meta_states')
          .select()
          .eq('user_id', uid)
          .maybeSingle();
      if (data == null) return null;
      return MetaState.fromMap(data);
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.loadMetaState error: $e');
      return null;
    }
  }

  // ── GDPR: Uzak Veri Silme ───────────────────────────────────────────────

  /// Kullaniciya ait tum uzak verileri + auth.users satirini siler (GDPR Article 17).
  /// Edge Function uzerinden:
  ///   1. delete_user_data RPC (uygulama tablolari — transaction)
  ///   2. auth.admin.deleteUser (auth.users satiri — email/phone)
  /// Basarili silme → `true`, hata veya yapilandirma eksikse → `false`.
  Future<bool> deleteUserData() async {
    if (!isConfigured) return false;
    final uid = _userId;
    if (uid == null) return false;
    try {
      final response = await _client.functions.invoke('delete-user');

      if (response.status != 200) {
        if (kDebugMode) {
          debugPrint(
            'RemoteRepository.deleteUserData: Edge Function error ${response.status}',
          );
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint(
          'RemoteRepository.deleteUserData: all data + auth deleted for $uid',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteRepository.deleteUserData error: $e');
      return false;
    }
  }
}
