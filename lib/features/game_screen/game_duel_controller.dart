import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/ui_constants.dart';
import '../../data/remote/pvp_realtime_service.dart';
import '../../game/pvp/matchmaking.dart';
import '../../game/world/game_world.dart';
import '../../providers/locale_provider.dart';
import '../../providers/pvp_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import '../pvp/duel_result_overlay.dart';

/// PvP Duel realtime senkronizasyon ve sonuc yonetimi.
///
/// [_GameScreenState]'ten cikartilmis bagimsiz sinif.
/// Tum PvP state degiskenleri ve realtime dinleyicileri burada.
class GameDuelController {
  GameDuelController({
    required this.ref,
    required this.game,
    required this.matchId,
    required this.isBot,
    required this.seed,
    required this.onStateChanged,
    this.opponentElo,
  });

  final WidgetRef ref;
  final GlooGame game;
  final String? matchId;
  final bool isBot;
  final int seed;
  final VoidCallback onStateChanged;
  final int? opponentElo;

  PvpRealtimeService? _pvpService;
  StreamSubscription<int>? _opponentScoreSub;
  StreamSubscription<ObstaclePacket>? _opponentObstacleSub;
  StreamSubscription<int>? _opponentGameOverSub;
  Timer? scoreBroadcastTimer;
  Timer? botScoreTimer;
  Timer? botObstacleTimer;
  int _lastBroadcastedScore = 0;

  PvpRealtimeService? get pvpService => _pvpService;

  void init() {
    ref.read(duelProvider.notifier).setMatch(
          matchId: matchId ?? 'local',
          seed: seed,
          isBot: isBot,
          opponentElo: opponentElo,
        );

    if (isBot) {
      _initBotSimulation();
      _logBotMatchAnalytics();
      return;
    }

    if (matchId == null) return;

    // Gercek rakip — Supabase Realtime baglantisi
    _pvpService = ref.read(pvpRealtimeServiceProvider);
    _pvpService!.joinDuelRoom(matchId!);

    // Rakip skorunu dinle
    _opponentScoreSub =
        _pvpService!.listenOpponentScore(matchId!).listen((score) {
      ref.read(duelProvider.notifier).updateOpponentScore(score);
    });

    // Rakip engellerini dinle
    _opponentObstacleSub =
        _pvpService!.listenOpponentObstacles(matchId!).listen((packet) {
      _applyIncomingObstacle(packet);
    });

    // Rakip oyun bitis sinyali
    _opponentGameOverSub =
        _pvpService!.listenOpponentGameOver(matchId!).listen((finalScore) {
      ref.read(duelProvider.notifier).setOpponentDone(finalScore);
    });

    // Skor degistiginde 500ms icinde broadcast et
    scoreBroadcastTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) {
        if (game.status == GameStatus.playing &&
            game.score != _lastBroadcastedScore) {
          _lastBroadcastedScore = game.score;
          _pvpService!.broadcastScore(matchId!, game.score);
        }
      },
    );
  }

  Future<void> _logBotMatchAnalytics() async {
    final repo = await ref.read(localRepositoryProvider.future);
    final dailyCount = await repo.incrementDailyBotMatchCount();
    ref.read(analyticsServiceProvider).logBotMatchCount(
          dailyCount: dailyCount,
        );
  }

  void _initBotSimulation() {
    final difficulty = MatchmakingManager.botDifficulty(
      ref.read(eloProvider).valueOrNull ?? 1000,
    );
    var botScore = 0;

    botScoreTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (game.status != GameStatus.playing) return;
      final gain = (30 + (70 * difficulty)).round();
      botScore += gain;
      ref.read(duelProvider.notifier).updateOpponentScore(botScore);
    });

    // Bot engel zorluğu — difficulty'ye göre ölçeklenir
    final obstacleCount = (1 + (difficulty * 3)).round().clamp(1, 4);
    final obstacleInterval = (20 - (difficulty * 8)).round().clamp(12, 20);
    botObstacleTimer = Timer.periodic(Duration(seconds: obstacleInterval), (_) {
      if (game.status != GameStatus.playing) return;
      _applyIncomingObstacle(ObstaclePacket(
        type: ObstacleType.ice,
        count: obstacleCount,
      ));
    });
  }

  void _applyIncomingObstacle(ObstaclePacket packet) {
    final grid = game.gridManager;
    if (packet.areaSize != null) {
      grid.applyAreaObstacle(packet.type, packet.areaSize!);
    } else {
      for (var i = 0; i < packet.count; i++) {
        grid.applyRandomObstacle(packet.type);
      }
    }
    onStateChanged();
  }

  void sendObstacles(int linesCleared, String comboTier) {
    if (isBot) return;
    if (matchId == null || _pvpService == null) return;

    final packets = ObstacleGenerator.fromLineClear(
      linesCleared: linesCleared,
      comboTier: comboTier,
    );
    for (final packet in packets) {
      _pvpService!.sendObstacle(matchId!, packet);
    }
  }

  void handleGameOver(int playerScore, BuildContext context) {
    final duelState = ref.read(duelProvider);

    // Rakibe oyun bitis sinyali gonder
    if (!isBot && duelState.matchId != null) {
      _pvpService?.broadcastGameOver(duelState.matchId!, playerScore);
    }

    // Duello sonuclandi — tum abonelikleri ve zamanlayicilari temizle
    _cancelSubscriptions();

    _finalizeDuelResult(playerScore, context);
  }

  /// Tum stream aboneliklerini ve zamanlayicilari iptal et.
  void _cancelSubscriptions() {
    _opponentScoreSub?.cancel();
    _opponentScoreSub = null;
    _opponentObstacleSub?.cancel();
    _opponentObstacleSub = null;
    _opponentGameOverSub?.cancel();
    _opponentGameOverSub = null;
    scoreBroadcastTimer?.cancel();
    scoreBroadcastTimer = null;
    botScoreTimer?.cancel();
    botScoreTimer = null;
    botObstacleTimer?.cancel();
    botObstacleTimer = null;
  }

  Future<void> _finalizeDuelResult(
      int playerScore, BuildContext context) async {
    final duelState = ref.read(duelProvider);
    final opponentScore = duelState.opponentScore;

    final repo = await ref.read(localRepositoryProvider.future);
    final playerElo = await repo.getElo();

    final opponentElo = isBot
        ? (playerElo * MatchmakingManager.botDifficulty(playerElo) * 1.2)
            .round()
        : (duelState.opponentElo ?? playerElo);

    final DuelOutcome outcome;
    if (playerScore > opponentScore) {
      outcome = DuelOutcome.win;
    } else if (playerScore < opponentScore) {
      outcome = DuelOutcome.loss;
    } else {
      outcome = DuelOutcome.draw;
    }

    final rawEloChange = EloSystem.calculateChange(
      playerElo: playerElo,
      opponentElo: opponentElo,
      outcome: outcome,
    );
    // Bot maçlarından ELO kazanımını %50 azalt (inflasyon önlemi)
    final eloChange =
        (isBot && rawEloChange > 0) ? (rawEloChange ~/ 2) : rawEloChange;
    final gelReward = EloSystem.calculateGelReward(outcome);
    final newElo = (playerElo + eloChange).clamp(0, 9999);

    // Lokal persist
    repo.saveElo(newElo);
    if (outcome != DuelOutcome.draw) {
      repo.recordPvpResult(isWin: outcome == DuelOutcome.win);
    }
    repo.saveGelOzu(await repo.getGelOzu() + gelReward);

    // Backend sync — bot maçlarında doğrudan güncelle, gerçek maçlarda Edge Function
    final remote = ref.read(remoteRepositoryProvider);
    final realMatchId = duelState.matchId;
    if (!isBot && realMatchId != null && realMatchId != 'local') {
      remote.updateElo(
        newElo: newElo,
        matchId: realMatchId,
        outcome: outcome.name,
        playerScore: playerScore,
        opponentScore: opponentScore,
      );
    } else {
      remote.updateElo(newElo: newElo);
    }
    remote.incrementPvpStats(isWin: outcome == DuelOutcome.win);
    if (duelState.matchId != null && duelState.matchId != 'local') {
      remote.submitPvpResult(
        matchId: duelState.matchId!,
        score: playerScore,
      );
    }

    ref.read(analyticsServiceProvider).logPvpResult(
          outcome: outcome.name,
          eloChange: eloChange,
          isBot: isBot,
        );

    final result = DuelResult(
      outcome: outcome,
      playerScore: playerScore,
      opponentScore: opponentScore,
      eloChange: eloChange,
      gelReward: gelReward,
    );

    if (!context.mounted) return;
    _showDuelResultDialog(result, newElo, context);
  }

  void _showDuelResultDialog(
      DuelResult result, int newElo, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 380),
        transitionBuilder: fadeScaleTransition,
        pageBuilder: (ctx, _, __) {
          final l = ref.read(stringsProvider);
          return DuelResultOverlay(
            result: result,
            playerElo: newElo,
            playAgainLabel: l.playAgainLabel,
            mainMenuLabel: l.mainMenuLabel,
            l: l,
            onHome: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            onRematch: () {
              Navigator.of(ctx).pop();
              context.go('/pvp-lobby');
            },
          );
        },
      );
    });
  }

  void dispose() {
    _cancelSubscriptions();
    if (matchId != null) {
      _pvpService?.leaveDuelRoom(matchId!);
    }
  }
}
