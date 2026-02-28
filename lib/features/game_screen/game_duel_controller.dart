import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/remote/pvp_realtime_service.dart';
import '../../data/remote/remote_repository.dart';
import '../../game/pvp/matchmaking.dart';
import '../../game/world/game_world.dart';
import '../../providers/pvp_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/analytics_service.dart';
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
  });

  final WidgetRef ref;
  final GlooGame game;
  final String? matchId;
  final bool isBot;
  final int seed;
  final VoidCallback onStateChanged;

  PvpRealtimeService? _pvpService;
  StreamSubscription<int>? _opponentScoreSub;
  StreamSubscription<ObstaclePacket>? _opponentObstacleSub;
  StreamSubscription<int>? _opponentGameOverSub;
  Timer? scoreBroadcastTimer;
  Timer? botScoreTimer;

  PvpRealtimeService? get pvpService => _pvpService;

  void init() {
    ref.read(duelProvider.notifier).setMatch(
      matchId: matchId ?? 'local',
      seed: seed,
      isBot: isBot,
    );

    if (isBot) {
      _initBotSimulation();
      return;
    }

    if (matchId == null) return;

    // Gercek rakip — Supabase Realtime baglantisi
    _pvpService = ref.read(pvpRealtimeServiceProvider);
    _pvpService!.joinDuelRoom(matchId!);

    // Rakip skorunu dinle
    _opponentScoreSub = _pvpService!
        .listenOpponentScore(matchId!)
        .listen((score) {
      ref.read(duelProvider.notifier).updateOpponentScore(score);
    });

    // Rakip engellerini dinle
    _opponentObstacleSub = _pvpService!
        .listenOpponentObstacles(matchId!)
        .listen((packet) {
      _applyIncomingObstacle(packet);
    });

    // Rakip oyun bitis sinyali
    _opponentGameOverSub = _pvpService!
        .listenOpponentGameOver(matchId!)
        .listen((finalScore) {
      ref.read(duelProvider.notifier).setOpponentDone(finalScore);
    });

    // Skoru her 5sn'de bir broadcast et
    scoreBroadcastTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (game.status == GameStatus.playing) {
          _pvpService!.broadcastScore(matchId!, game.score);
        }
      },
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
  }

  void _applyIncomingObstacle(ObstaclePacket packet) {
    final grid = game.gridManager;
    for (var i = 0; i < packet.count; i++) {
      grid.applyRandomObstacle(packet.type);
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

    if (isBot) {
      botScoreTimer?.cancel();
    }

    _finalizeDuelResult(playerScore, context);
  }

  Future<void> _finalizeDuelResult(int playerScore, BuildContext context) async {
    final duelState = ref.read(duelProvider);
    final opponentScore = duelState.opponentScore;

    final repo = await ref.read(localRepositoryProvider.future);
    final playerElo = repo.getElo();

    final opponentElo = isBot
        ? (playerElo * MatchmakingManager.botDifficulty(playerElo) * 1.2).round()
        : playerElo;

    final DuelOutcome outcome;
    if (playerScore > opponentScore) {
      outcome = DuelOutcome.win;
    } else if (playerScore < opponentScore) {
      outcome = DuelOutcome.loss;
    } else {
      outcome = DuelOutcome.draw;
    }

    final eloChange = EloSystem.calculateChange(
      playerElo: playerElo,
      opponentElo: opponentElo,
      outcome: outcome,
    );
    final gelReward = EloSystem.calculateGelReward(outcome);
    final newElo = (playerElo + eloChange).clamp(0, 9999);

    // Lokal persist
    repo.saveElo(newElo);
    if (outcome != DuelOutcome.draw) {
      repo.recordPvpResult(isWin: outcome == DuelOutcome.win);
    }
    repo.saveGelOzu(repo.getGelOzu() + gelReward);

    // Backend sync
    final remote = RemoteRepository();
    remote.updateElo(newElo: newElo);
    remote.incrementPvpStats(isWin: outcome == DuelOutcome.win);
    if (duelState.matchId != null && duelState.matchId != 'local') {
      remote.submitPvpResult(
        matchId: duelState.matchId!,
        score: playerScore,
      );
    }

    AnalyticsService().logPvpResult(
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

  void _showDuelResultDialog(DuelResult result, int newElo, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 380),
        transitionBuilder: (ctx, anim, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        pageBuilder: (ctx, _, __) {
          return DuelResultOverlay(
            result: result,
            playerElo: newElo,
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
    scoreBroadcastTimer?.cancel();
    botScoreTimer?.cancel();
    _opponentScoreSub?.cancel();
    _opponentObstacleSub?.cancel();
    _opponentGameOverSub?.cancel();
    if (matchId != null) {
      _pvpService?.leaveDuelRoom(matchId!);
    }
  }
}
