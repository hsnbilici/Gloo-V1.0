import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/challenge.dart';
import '../data/remote/challenge_repository.dart';

final challengeRepositoryProvider =
    Provider<ChallengeRepository>((ref) => ChallengeRepository());

class ChallengeState {
  const ChallengeState({
    this.received = const [],
    this.sent = const [],
    this.dailySentCount = 0,
    this.isLoading = false,
  });

  final List<Challenge> received;
  final List<Challenge> sent;
  final int dailySentCount;
  final bool isLoading;

  int get pendingCount =>
      received.where((c) => c.status == ChallengeStatus.pending).length;

  ChallengeState copyWith({
    List<Challenge>? received,
    List<Challenge>? sent,
    int? dailySentCount,
    bool? isLoading,
  }) {
    return ChallengeState(
      received: received ?? this.received,
      sent: sent ?? this.sent,
      dailySentCount: dailySentCount ?? this.dailySentCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChallengeNotifier extends StateNotifier<ChallengeState> {
  ChallengeNotifier(this._repo) : super(const ChallengeState());

  final ChallengeRepository _repo;

  Future<void> loadChallenges() async {
    if (!_repo.isConfigured) return;
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        _repo.getPendingChallenges(),
        _repo.getSentChallenges(),
        _repo.getDailyChallengeCount(),
      ]);
      state = ChallengeState(
        received: results[0] as List<Challenge>,
        sent: results[1] as List<Challenge>,
        dailySentCount: results[2] as int,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Map<String, dynamic>?> sendChallenge({
    String? recipientId,
    required String mode,
    required String challengeType,
    required int senderScore,
    required int wager,
    int? clientBalance,
  }) async {
    final result = await _repo.createChallenge(
      recipientId: recipientId,
      mode: mode,
      challengeType: challengeType,
      senderScore: senderScore,
      wager: wager,
      clientBalance: clientBalance,
    );
    if (result != null) await loadChallenges();
    return result;
  }

  Future<Map<String, dynamic>?> acceptChallenge(
    String id, {
    int? clientBalance,
  }) async {
    final result = await _repo.acceptChallenge(
      challengeId: id,
      clientBalance: clientBalance,
    );
    if (result != null) await loadChallenges();
    return result;
  }

  Future<bool> declineChallenge(String id) async {
    final success = await _repo.declineChallenge(id);
    if (success) await loadChallenges();
    return success;
  }

  Future<bool> cancelChallenge(String id) async {
    final success = await _repo.cancelChallenge(id);
    if (success) await loadChallenges();
    return success;
  }

  Future<ChallengeResult?> submitScore(String id, int score) async {
    final result = await _repo.submitRecipientScore(
      challengeId: id,
      score: score,
    );
    if (result != null) await loadChallenges();
    return result;
  }

  Future<Map<String, dynamic>?> claimDeepLink(String id) async {
    final result = await _repo.claimDeepLinkChallenge(id);
    if (result != null) await loadChallenges();
    return result;
  }

  Future<void> refresh() => loadChallenges();
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, ChallengeState>((ref) {
  final repo = ref.watch(challengeRepositoryProvider);
  return ChallengeNotifier(repo);
});

final pendingChallengeCountProvider = Provider<int>((ref) {
  return ref.watch(challengeProvider).pendingCount;
});
