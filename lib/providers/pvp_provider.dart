import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/pvp_realtime_service.dart';

/// PvP duello durumu — rakip skoru, mac bilgisi, bot durumu.
class DuelState {
  const DuelState({
    this.matchId,
    this.seed,
    this.isBot = false,
    this.opponentScore = 0,
    this.isOpponentDone = false,
  });

  final String? matchId;
  final int? seed;
  final bool isBot;
  final int opponentScore;
  final bool isOpponentDone;

  DuelState copyWith({
    String? matchId,
    int? seed,
    bool? isBot,
    int? opponentScore,
    bool? isOpponentDone,
  }) {
    return DuelState(
      matchId: matchId ?? this.matchId,
      seed: seed ?? this.seed,
      isBot: isBot ?? this.isBot,
      opponentScore: opponentScore ?? this.opponentScore,
      isOpponentDone: isOpponentDone ?? this.isOpponentDone,
    );
  }
}

class DuelNotifier extends Notifier<DuelState> {
  @override
  DuelState build() => const DuelState();

  void setMatch({
    required String matchId,
    required int seed,
    required bool isBot,
  }) {
    state = DuelState(matchId: matchId, seed: seed, isBot: isBot);
  }

  void updateOpponentScore(int score) {
    state = state.copyWith(opponentScore: score);
  }

  void setOpponentDone(int finalScore) {
    state = state.copyWith(opponentScore: finalScore, isOpponentDone: true);
  }

  void reset() => state = const DuelState();
}

final duelProvider = NotifierProvider<DuelNotifier, DuelState>(
  DuelNotifier.new,
);

final pvpRealtimeServiceProvider = Provider<PvpRealtimeService>((ref) {
  final service = PvpRealtimeService();
  ref.onDispose(() => service.dispose());
  return service;
});
