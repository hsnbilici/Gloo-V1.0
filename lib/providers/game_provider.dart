import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/game_constants.dart';
import '../game/world/game_world.dart';

class GameState {
  const GameState({
    required this.score,
    required this.status,
    required this.mode,
    this.filledCells = 0,
    this.remainingSeconds = GameConstants.timeTrialDuration,
    this.chefProgress = 0,
    this.chefRequired = 3,
    // Faz 4
    this.gelOzu = 0,
    this.movesUsed = 0,
    this.currentLevel = 0,
    this.levelTargetScore = 0,
    this.elo = 1000,
  });

  final int score;
  final GameStatus status;
  final GameMode mode;
  final int filledCells;
  final int remainingSeconds;
  final int chefProgress;
  final int chefRequired;

  // Faz 4
  final int gelOzu;
  final int movesUsed;
  final int currentLevel;
  final int levelTargetScore;
  final int elo;

  GameState copyWith({
    int? score,
    GameStatus? status,
    GameMode? mode,
    int? filledCells,
    int? remainingSeconds,
    int? chefProgress,
    int? chefRequired,
    int? gelOzu,
    int? movesUsed,
    int? currentLevel,
    int? levelTargetScore,
    int? elo,
  }) {
    return GameState(
      score: score ?? this.score,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      filledCells: filledCells ?? this.filledCells,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      chefProgress: chefProgress ?? this.chefProgress,
      chefRequired: chefRequired ?? this.chefRequired,
      gelOzu: gelOzu ?? this.gelOzu,
      movesUsed: movesUsed ?? this.movesUsed,
      currentLevel: currentLevel ?? this.currentLevel,
      levelTargetScore: levelTargetScore ?? this.levelTargetScore,
      elo: elo ?? this.elo,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(GameMode mode)
      : super(GameState(score: 0, status: GameStatus.idle, mode: mode));

  void updateScore(int newScore) => state = state.copyWith(score: newScore);
  void updateFill(int filledCells) => state = state.copyWith(filledCells: filledCells);
  void updateStatus(GameStatus status) => state = state.copyWith(status: status);
  void updateRemainingSeconds(int seconds) =>
      state = state.copyWith(remainingSeconds: seconds);

  void updateChef(int progress, int required) =>
      state = state.copyWith(chefProgress: progress, chefRequired: required);

  // Faz 4
  void updateGelOzu(int value) => state = state.copyWith(gelOzu: value);
  void updateMovesUsed(int value) => state = state.copyWith(movesUsed: value);
  void updateLevel(int level, int targetScore) =>
      state = state.copyWith(currentLevel: level, levelTargetScore: targetScore);
  void updateElo(int value) => state = state.copyWith(elo: value);

  void reset() => state = GameState(score: 0, status: GameStatus.idle, mode: state.mode);
}

final gameProvider = StateNotifierProvider.family<GameNotifier, GameState, GameMode>(
  (ref, mode) => GameNotifier(mode),
);
