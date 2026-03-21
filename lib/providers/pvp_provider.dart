import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/supabase_client.dart';

/// Sentinel for nullable copyWith fields — identity-based, never equals a real value.
const _absent = _Absent();

class _Absent {
  const _Absent();
}

/// PvP duello durumu — rakip skoru, mac bilgisi, bot durumu.
class DuelState {
  const DuelState({
    this.matchId,
    this.seed,
    this.isBot = false,
    this.opponentElo,
    this.opponentScore = 0,
    this.isOpponentDone = false,
  });

  final String? matchId;
  final int? seed;
  final bool isBot;
  final int? opponentElo;
  final int opponentScore;
  final bool isOpponentDone;

  DuelState copyWith({
    Object? matchId = _absent,
    Object? seed = _absent,
    bool? isBot,
    Object? opponentElo = _absent,
    int? opponentScore,
    bool? isOpponentDone,
  }) {
    return DuelState(
      matchId: matchId == _absent ? this.matchId : matchId as String?,
      seed: seed == _absent ? this.seed : seed as int?,
      isBot: isBot ?? this.isBot,
      opponentElo:
          opponentElo == _absent ? this.opponentElo : opponentElo as int?,
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
    int? opponentElo,
  }) {
    state = DuelState(
      matchId: matchId,
      seed: seed,
      isBot: isBot,
      opponentElo: opponentElo,
    );
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

final currentUserIdProvider = Provider<String?>((ref) {
  return SupabaseConfig.currentUserId;
});
