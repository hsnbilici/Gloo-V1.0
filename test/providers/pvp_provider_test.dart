import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/providers/pvp_provider.dart';

void main() {
  // ─── DuelState ──────────────────────────────────────────────────────────

  group('DuelState', () {
    test('default values', () {
      const state = DuelState();
      expect(state.matchId, isNull);
      expect(state.seed, isNull);
      expect(state.isBot, isFalse);
      expect(state.opponentScore, 0);
      expect(state.isOpponentDone, isFalse);
    });

    test('copyWith updates only specified fields', () {
      const state = DuelState(
        matchId: 'match1',
        seed: 42,
        isBot: false,
        opponentScore: 100,
      );
      final updated = state.copyWith(opponentScore: 500);
      expect(updated.matchId, 'match1');
      expect(updated.seed, 42);
      expect(updated.isBot, isFalse);
      expect(updated.opponentScore, 500);
      expect(updated.isOpponentDone, isFalse);
    });

    test('copyWith can update all fields', () {
      const state = DuelState();
      final updated = state.copyWith(
        matchId: 'match2',
        seed: 99,
        isBot: true,
        opponentScore: 300,
        isOpponentDone: true,
      );
      expect(updated.matchId, 'match2');
      expect(updated.seed, 99);
      expect(updated.isBot, isTrue);
      expect(updated.opponentScore, 300);
      expect(updated.isOpponentDone, isTrue);
    });
  });

  // ─── DuelNotifier ─────────────────────────────────────────────────────

  group('DuelNotifier', () {
    late DuelNotifier notifier;

    setUp(() {
      notifier = DuelNotifier();
    });

    test('initial state is empty DuelState', () {
      expect(notifier.state.matchId, isNull);
      expect(notifier.state.seed, isNull);
      expect(notifier.state.isBot, isFalse);
      expect(notifier.state.opponentScore, 0);
    });

    test('setMatch sets matchId, seed, and isBot', () {
      notifier.setMatch(matchId: 'abc', seed: 42, isBot: false);
      expect(notifier.state.matchId, 'abc');
      expect(notifier.state.seed, 42);
      expect(notifier.state.isBot, isFalse);
    });

    test('setMatch with bot', () {
      notifier.setMatch(matchId: 'bot-match', seed: 7, isBot: true);
      expect(notifier.state.isBot, isTrue);
    });

    test('updateOpponentScore changes score', () {
      notifier.setMatch(matchId: 'abc', seed: 42, isBot: false);
      notifier.updateOpponentScore(250);
      expect(notifier.state.opponentScore, 250);
      expect(notifier.state.matchId, 'abc'); // preserved
    });

    test('setOpponentDone sets score and done flag', () {
      notifier.setMatch(matchId: 'abc', seed: 42, isBot: false);
      notifier.setOpponentDone(1000);
      expect(notifier.state.opponentScore, 1000);
      expect(notifier.state.isOpponentDone, isTrue);
    });

    test('reset returns to empty state', () {
      notifier.setMatch(matchId: 'abc', seed: 42, isBot: true);
      notifier.updateOpponentScore(500);
      notifier.reset();
      expect(notifier.state.matchId, isNull);
      expect(notifier.state.seed, isNull);
      expect(notifier.state.isBot, isFalse);
      expect(notifier.state.opponentScore, 0);
      expect(notifier.state.isOpponentDone, isFalse);
    });
  });
}
