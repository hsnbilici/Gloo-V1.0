import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

/// Supabase uzak deposu — profil, skor, günlük bulmaca ve sıralama.
///
/// Tablo yapısı GDD 4.8'de tanımlanan SQL şemasına uygundur:
/// - `profiles`: kullanıcı profilleri (auth.users ile 1:1)
/// - `scores`: oyun skorları (mode, score, created_at)
/// - `daily_tasks`: günlük bulmaca tamamlanma durumu
class RemoteRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  String? get _userId => SupabaseConfig.currentUserId;

  /// Supabase yapilandirilmis mi? Sahte anahtarlarla tum metodlar sessizce atlar.
  bool get isConfigured => SupabaseConfig.isConfigured;

  // ── Skor kaydet ─────────────────────────────────────────────────────────
  Future<void> submitScore({
    required String mode,
    required int value,
  }) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client.from('scores').insert({
        'user_id': uid,
        'mode': mode,
        'score': value,
      });
    } catch (e) {
      debugPrint('RemoteRepository.submitScore error: $e');
    }
  }

  // ── Global sıralama ─────────────────────────────────────────────────────
  /// [mode]: 'classic' | 'timetrial'
  /// [weekly]: true ise son 7 günlük filtre uygulanır
  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({
    required String mode,
    int limit = 50,
    bool weekly = false,
  }) async {
    if (!isConfigured) return [];
    try {
      var query = _client
          .from('scores')
          .select('id, user_id, mode, score, created_at, profiles(username)')
          .eq('mode', mode);

      if (weekly) {
        final weekAgo =
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
        query = query.gte('created_at', weekAgo);
      }

      final data = await query
          .order('score', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('RemoteRepository.getGlobalLeaderboard error: $e');
      return [];
    }
  }

  /// Kullanıcının belirli moddaki en yüksek sırasını döner.
  Future<int?> getUserRank({
    required String mode,
    bool weekly = false,
  }) async {
    if (!isConfigured) return null;
    final uid = _userId;
    if (uid == null) return null;
    try {
      // Kullanıcının en yüksek skoru
      final userScores = await _client
          .from('scores')
          .select('score')
          .eq('mode', mode)
          .eq('user_id', uid)
          .order('score', ascending: false)
          .limit(1);

      if (userScores.isEmpty) return null;
      final topScore = userScores[0]['score'] as int;

      // Bu skorun üzerindeki kayıt sayısı = sıra - 1
      var query = _client
          .from('scores')
          .select('id')
          .eq('mode', mode)
          .gt('score', topScore);

      if (weekly) {
        final weekAgo =
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
        query = query.gte('created_at', weekAgo);
      }

      final above = await query;
      return above.length + 1;
    } catch (e) {
      debugPrint('RemoteRepository.getUserRank error: $e');
      return null;
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
      debugPrint('RemoteRepository.ensureProfile error: $e');
    }
  }

  // ── Günlük Bulmaca ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getDailyPuzzle() async {
    if (!isConfigured) return null;
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final data = await _client
          .from('daily_tasks')
          .select()
          .eq('date', today)
          .maybeSingle();
      return data;
    } catch (e) {
      debugPrint('RemoteRepository.getDailyPuzzle error: $e');
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
      debugPrint('RemoteRepository.submitDailyResult error: $e');
    }
  }

  // ── PvP ────────────────────────────────────────────────────────────────────

  /// Yeni PvP maci olustur. [opponentId] null ise bot eslestirme.
  Future<String?> createPvpMatch({
    required int seed,
    String? opponentId,
  }) async {
    if (!isConfigured) return null;
    final uid = _userId;
    if (uid == null) return null;
    try {
      final data = await _client.from('pvp_matches').insert({
        'player1_id': uid,
        'player2_id': opponentId,
        'seed': seed,
        'status': 'active',
      }).select('id').single();
      return data['id'] as String;
    } catch (e) {
      debugPrint('RemoteRepository.createPvpMatch error: $e');
      return null;
    }
  }

  /// Mac sonucunu kaydet ve durumu guncelle.
  Future<void> submitPvpResult({
    required String matchId,
    required int score,
  }) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      // Hangi oyuncu oldugunu belirle
      final match = await _client
          .from('pvp_matches')
          .select()
          .eq('id', matchId)
          .single();

      final isPlayer1 = match['player1_id'] == uid;
      final scoreField = isPlayer1 ? 'player1_score' : 'player2_score';

      await _client
          .from('pvp_matches')
          .update({scoreField: score})
          .eq('id', matchId);

      // Iki skor da varsa maci tamamla
      final updated = await _client
          .from('pvp_matches')
          .select()
          .eq('id', matchId)
          .single();

      final p1Score = updated['player1_score'] as int?;
      final p2Score = updated['player2_score'] as int?;

      if (p1Score != null && p2Score != null) {
        String? winnerId;
        if (p1Score > p2Score) {
          winnerId = updated['player1_id'] as String;
        } else if (p2Score > p1Score) {
          winnerId = updated['player2_id'] as String?;
        }

        await _client.from('pvp_matches').update({
          'status': 'completed',
          'winner_id': winnerId,
          'completed_at': DateTime.now().toIso8601String(),
        }).eq('id', matchId);
      }
    } catch (e) {
      debugPrint('RemoteRepository.submitPvpResult error: $e');
    }
  }

  /// ELO puanini guncelle.
  Future<void> updateElo({required int newElo}) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      await _client.from('profiles').update({'elo': newElo}).eq('id', uid);
    } catch (e) {
      debugPrint('RemoteRepository.updateElo error: $e');
    }
  }

  /// PvP mac bilgisi getir.
  Future<Map<String, dynamic>?> getPvpMatch(String matchId) async {
    if (!isConfigured) return null;
    try {
      return await _client
          .from('pvp_matches')
          .select()
          .eq('id', matchId)
          .maybeSingle();
    } catch (e) {
      debugPrint('RemoteRepository.getPvpMatch error: $e');
      return null;
    }
  }

  /// PvP istatistiklerini guncelle (galibiyet/maglubiyet).
  Future<void> incrementPvpStats({required bool isWin}) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      final profile = await _client
          .from('profiles')
          .select('pvp_wins, pvp_losses')
          .eq('id', uid)
          .single();

      final field = isWin ? 'pvp_wins' : 'pvp_losses';
      final current = profile[field] as int;

      await _client
          .from('profiles')
          .update({field: current + 1})
          .eq('id', uid);
    } catch (e) {
      debugPrint('RemoteRepository.incrementPvpStats error: $e');
    }
  }

  // ── Redeem Code ──────────────────────────────────────────────────────────

  /// Kodu Supabase'de dogrular. Gecerli ise urun ID listesi doner, degilse null.
  /// Basarili dogrulamada `current_uses`'i 1 arttirir.
  Future<List<String>?> redeemCode(String code) async {
    if (!isConfigured) return null;
    try {
      final data = await _client
          .from('redeem_codes')
          .select()
          .eq('code', code.toUpperCase())
          .maybeSingle();

      if (data == null) return null;

      final currentUses = data['current_uses'] as int;
      final maxUses = data['max_uses'] as int;
      if (currentUses >= maxUses) return null;

      final expiresAt = data['expires_at'] as String?;
      if (expiresAt != null) {
        final expiry = DateTime.tryParse(expiresAt);
        if (expiry != null && DateTime.now().isAfter(expiry)) return null;
      }

      // current_uses'i artir
      await _client
          .from('redeem_codes')
          .update({'current_uses': currentUses + 1})
          .eq('code', code.toUpperCase());

      final productIds = (data['product_ids'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      return productIds;
    } catch (e) {
      debugPrint('RemoteRepository.redeemCode error: $e');
      return null;
    }
  }
}
