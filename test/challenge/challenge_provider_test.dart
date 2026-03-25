import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/models/challenge.dart';
import 'package:gloo/core/models/game_mode.dart';
import 'package:gloo/providers/challenge_provider.dart';

void main() {
  group('ChallengeState', () {
    final now = DateTime.now();
    final later = now.add(const Duration(hours: 24));

    Challenge _makeChallenge({
      required String id,
      ChallengeStatus status = ChallengeStatus.pending,
    }) {
      return Challenge(
        id: id,
        senderId: 'sender-1',
        senderUsername: 'Alice',
        mode: GameMode.classic,
        type: ChallengeType.scoreBattle,
        wager: 10,
        status: status,
        expiresAt: later,
        createdAt: now,
      );
    }

    test('initial state has empty lists and 0 counts', () {
      const state = ChallengeState();
      expect(state.received, isEmpty);
      expect(state.sent, isEmpty);
      expect(state.dailySentCount, 0);
      expect(state.isLoading, false);
      expect(state.pendingCount, 0);
    });

    test('pendingCount counts only pending challenges in received', () {
      final state = ChallengeState(
        received: [
          _makeChallenge(id: '1', status: ChallengeStatus.pending),
          _makeChallenge(id: '2', status: ChallengeStatus.active),
          _makeChallenge(id: '3', status: ChallengeStatus.pending),
          _makeChallenge(id: '4', status: ChallengeStatus.declined),
        ],
      );
      expect(state.pendingCount, 2);
    });

    test('pendingCount is 0 when no pending challenges', () {
      final state = ChallengeState(
        received: [
          _makeChallenge(id: '1', status: ChallengeStatus.completed),
          _makeChallenge(id: '2', status: ChallengeStatus.expired),
        ],
      );
      expect(state.pendingCount, 0);
    });

    test('copyWith preserves fields when no arguments given', () {
      final original = ChallengeState(
        received: [_makeChallenge(id: '1')],
        sent: [_makeChallenge(id: '2')],
        dailySentCount: 5,
        isLoading: true,
      );

      final copied = original.copyWith();

      expect(copied.received, original.received);
      expect(copied.sent, original.sent);
      expect(copied.dailySentCount, 5);
      expect(copied.isLoading, true);
    });

    test('copyWith overrides specified fields', () {
      final original = ChallengeState(
        received: [_makeChallenge(id: '1')],
        sent: [_makeChallenge(id: '2')],
        dailySentCount: 3,
        isLoading: true,
      );

      final newReceived = [_makeChallenge(id: '3')];
      final copied = original.copyWith(
        received: newReceived,
        dailySentCount: 7,
        isLoading: false,
      );

      expect(copied.received, newReceived);
      expect(copied.sent, original.sent);
      expect(copied.dailySentCount, 7);
      expect(copied.isLoading, false);
    });
  });
}
