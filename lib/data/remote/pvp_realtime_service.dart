import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../game/pvp/matchmaking.dart';
import 'remote_repository.dart';
import 'supabase_client.dart';

/// Supabase Realtime tabanli PvP servisi.
///
/// Iki ana kanal kullanir:
/// 1. **Presence** (`matchmaking`) — eslestirme kuyrugu
/// 2. **Broadcast** (`duel:{matchId}`) — duello senkronizasyonu
class PvpRealtimeService {
  PvpRealtimeService({RemoteRepository? repository})
      : _repository = repository ?? RemoteRepository();

  final RemoteRepository _repository;

  SupabaseClient get _client => SupabaseConfig.client;
  String? get _userId => SupabaseConfig.currentUserId;

  RealtimeChannel? _matchmakingChannel;
  RealtimeChannel? _duelChannel;
  Timer? _matchmakingTimeout;
  Timer? _evaluateDebounce;

  // Duello stream controller'lari — dispose'da kapatilir
  final List<StreamController<dynamic>> _duelControllers = [];

  // ── Eslestirme Kuyrugu (Presence) ─────────────────────────────────────

  /// Eslestirme kuyruguna katil. [onMatch] eslestirme bulunursa cagirilir.
  /// 30sn icinde eslestirme yoksa bot fallback yapilir.
  Future<void> joinMatchmakingQueue({
    required MatchRequest request,
    required void Function(MatchResult) onMatch,
  }) async {
    final uid = _userId;
    if (uid == null) return;

    _matchmakingChannel = _client.channel(
      'matchmaking',
      opts: const RealtimeChannelConfig(self: true),
    );

    _matchmakingChannel!
        .onPresenceSync((_) {
          _debouncedEvaluateMatches(request, onMatch);
        })
        .onPresenceJoin((_) {
          _debouncedEvaluateMatches(request, onMatch);
        })
        .subscribe((status, [error]) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await _matchmakingChannel!.track({
              'user_id': uid,
              'elo': request.elo,
              'region': request.region,
              'joined_at': DateTime.now().toIso8601String(),
            });
          }
        });

    // 30sn timeout → bot fallback
    _matchmakingTimeout = Timer(
      const Duration(seconds: MatchmakingManager.maxWaitSeconds),
      () => _botFallback(request, onMatch),
    );
  }

  /// Eslestirme degerlendirmesini debounce et.
  /// Birden fazla presence guncellemesi ayni anda geldiginde
  /// gereksiz tekrarlanan cagrilari onler.
  void _debouncedEvaluateMatches(
    MatchRequest request,
    void Function(MatchResult) onMatch,
  ) {
    _evaluateDebounce?.cancel();
    _evaluateDebounce = Timer(const Duration(milliseconds: 250), () {
      _evaluateMatches(request, onMatch);
    });
  }

  /// Presence state'ini tarayip uyumlu rakip ara.
  void _evaluateMatches(
    MatchRequest request,
    void Function(MatchResult) onMatch,
  ) {
    final states = _matchmakingChannel?.presenceState();
    if (states == null) return;

    for (final state in states) {
      for (final presence in state.presences) {
        final payload = presence.payload;
        final otherId = payload['user_id'] as String?;
        if (otherId == null || otherId == request.userId) continue;

        final otherElo = payload['elo'] as int? ?? 1000;
        final otherRequest = MatchRequest(
          userId: otherId,
          elo: otherElo,
          region: payload['region'] as String? ?? '',
          timestamp: DateTime.now(),
        );

        if (MatchmakingManager.isCompatible(request, otherRequest)) {
          _matchmakingTimeout?.cancel();
          final seed = MatchmakingManager.generateMatchSeed();

          // Mac olustur
          _repository
              .createPvpMatch(seed: seed, opponentId: otherId)
              .then((matchId) {
            if (matchId != null) {
              _leaveMatchmakingQueue();
              onMatch(MatchResult(
                matchId: matchId,
                player1Id: request.userId,
                player2Id: otherId,
                seed: seed,
                isBot: false,
              ));
            }
          });
          return;
        }
      }
    }
  }

  /// Bot fallback — timeout sonrasi.
  void _botFallback(
    MatchRequest request,
    void Function(MatchResult) onMatch,
  ) {
    _leaveMatchmakingQueue();
    final seed = MatchmakingManager.generateMatchSeed();
    final botId = 'bot_${Random().nextInt(99999).toString().padLeft(5, '0')}';

    // Bot maci veritabanina kaydetmeye gerek yok — lokal oynanir
    onMatch(MatchResult(
      matchId: 'bot_match_$seed',
      player1Id: request.userId,
      player2Id: botId,
      seed: seed,
      isBot: true,
    ));
  }

  /// Eslestirme kuyrugundan ayril.
  Future<void> _leaveMatchmakingQueue() async {
    _matchmakingTimeout?.cancel();
    _matchmakingTimeout = null;
    _evaluateDebounce?.cancel();
    _evaluateDebounce = null;
    await _matchmakingChannel?.untrack();
    await _matchmakingChannel?.unsubscribe();
    _matchmakingChannel = null;
  }

  /// Eslestirme aramasini iptal et.
  Future<void> cancelMatchmaking() async {
    await _leaveMatchmakingQueue();
  }

  // ── Duello Odasi (Broadcast) ──────────────────────────────────────────

  /// Duello odasina baglan.
  Future<void> joinDuelRoom(String matchId) async {
    _duelChannel = _client.channel(
      'duel:$matchId',
      opts: const RealtimeChannelConfig(self: false),
    );

    _duelChannel!.subscribe();
  }

  /// Skor guncelleme broadcast'i.
  Future<void> broadcastScore(String matchId, int score) async {
    if (_duelChannel == null) return;
    await _duelChannel!.sendBroadcastMessage(
      event: 'score_update',
      payload: {
        'user_id': _userId,
        'score': score,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Engel paketi broadcast'i.
  Future<void> sendObstacle(
    String matchId,
    ObstaclePacket packet,
  ) async {
    if (_duelChannel == null) return;
    await _duelChannel!.sendBroadcastMessage(
      event: 'obstacle_sent',
      payload: {
        'user_id': _userId,
        'type': packet.type.name,
        'count': packet.count,
        'area_size': packet.areaSize,
      },
    );

    // Veritabanina da kaydet
    try {
      await _client.from('pvp_obstacles').insert({
        'match_id': matchId,
        'sender_id': _userId,
        'obstacle_type': packet.type.name,
        'count': packet.count,
        'area_size': packet.areaSize,
      });
    } catch (e) {
      debugPrint('PvpRealtimeService.sendObstacle DB error: $e');
    }
  }

  /// Oyun bitis broadcast'i.
  Future<void> broadcastGameOver(String matchId, int finalScore) async {
    if (_duelChannel == null) return;
    await _duelChannel!.sendBroadcastMessage(
      event: 'game_over',
      payload: {
        'user_id': _userId,
        'score': finalScore,
      },
    );

    // Veritabanina kaydet
    await _repository.submitPvpResult(
      matchId: matchId,
      score: finalScore,
    );
  }

  /// Rakip skor guncellemelerini dinle.
  Stream<int> listenOpponentScore(String matchId) {
    final controller = StreamController<int>();
    _duelControllers.add(controller);

    _duelChannel?.onBroadcast(
      event: 'score_update',
      callback: (payload) {
        if (controller.isClosed) return;
        final senderId = payload['user_id'] as String?;
        if (senderId != null && senderId != _userId) {
          final score = payload['score'] as int? ?? 0;
          controller.add(score);
        }
      },
    );

    return controller.stream;
  }

  /// Rakip engellerini dinle.
  Stream<ObstaclePacket> listenOpponentObstacles(String matchId) {
    final controller = StreamController<ObstaclePacket>();
    _duelControllers.add(controller);

    _duelChannel?.onBroadcast(
      event: 'obstacle_sent',
      callback: (payload) {
        if (controller.isClosed) return;
        final senderId = payload['user_id'] as String?;
        if (senderId != null && senderId != _userId) {
          final typeName = payload['type'] as String? ?? 'ice';
          final type = ObstacleType.values.firstWhere(
            (t) => t.name == typeName,
            orElse: () => ObstacleType.ice,
          );
          controller.add(ObstaclePacket(
            type: type,
            count: payload['count'] as int? ?? 1,
            areaSize: payload['area_size'] as int?,
          ));
        }
      },
    );

    return controller.stream;
  }

  /// Rakip oyun bitis sinyalini dinle.
  Stream<int> listenOpponentGameOver(String matchId) {
    final controller = StreamController<int>();
    _duelControllers.add(controller);

    _duelChannel?.onBroadcast(
      event: 'game_over',
      callback: (payload) {
        if (controller.isClosed) return;
        final senderId = payload['user_id'] as String?;
        if (senderId != null && senderId != _userId) {
          final score = payload['score'] as int? ?? 0;
          controller.add(score);
        }
      },
    );

    return controller.stream;
  }

  /// Duello odasindan ayril ve temizle.
  Future<void> leaveDuelRoom(String matchId) async {
    _closeDuelControllers();
    await _duelChannel?.unsubscribe();
    _duelChannel = null;
  }

  /// Tum stream controller'lari kapat.
  void _closeDuelControllers() {
    for (final c in _duelControllers) {
      if (!c.isClosed) c.close();
    }
    _duelControllers.clear();
  }

  /// Tum kanallari temizle.
  Future<void> dispose() async {
    _evaluateDebounce?.cancel();
    _evaluateDebounce = null;
    await cancelMatchmaking();
    _closeDuelControllers();
    if (_duelChannel != null) {
      await _duelChannel!.unsubscribe();
      _duelChannel = null;
    }
  }
}
