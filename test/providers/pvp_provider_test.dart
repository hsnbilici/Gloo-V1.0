import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      expect(state.opponentElo, isNull);
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
        opponentElo: 1500,
        opponentScore: 300,
        isOpponentDone: true,
      );
      expect(updated.matchId, 'match2');
      expect(updated.seed, 99);
      expect(updated.isBot, isTrue);
      expect(updated.opponentElo, 1500);
      expect(updated.opponentScore, 300);
      expect(updated.isOpponentDone, isTrue);
    });

    test('copyWith can clear nullable fields to null', () {
      const state = DuelState(
        matchId: 'match1',
        seed: 42,
        opponentElo: 1200,
      );
      final cleared = state.copyWith(
        matchId: null,
        seed: null,
        opponentElo: null,
      );
      expect(cleared.matchId, isNull);
      expect(cleared.seed, isNull);
      expect(cleared.opponentElo, isNull);
    });
  });

  // ─── DuelNotifier ─────────────────────────────────────────────────────

  group('DuelNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('initial state is empty DuelState', () {
      final state = container.read(duelProvider);
      expect(state.matchId, isNull);
      expect(state.seed, isNull);
      expect(state.isBot, isFalse);
      expect(state.opponentScore, 0);
    });

    test('setMatch sets matchId, seed, and isBot', () {
      container
          .read(duelProvider.notifier)
          .setMatch(matchId: 'abc', seed: 42, isBot: false);
      final state = container.read(duelProvider);
      expect(state.matchId, 'abc');
      expect(state.seed, 42);
      expect(state.isBot, isFalse);
      expect(state.opponentElo, isNull);
    });

    test('setMatch with bot', () {
      container
          .read(duelProvider.notifier)
          .setMatch(matchId: 'bot-match', seed: 7, isBot: true);
      expect(container.read(duelProvider).isBot, isTrue);
    });

    test('setMatch with opponentElo', () {
      container.read(duelProvider.notifier).setMatch(
            matchId: 'ranked',
            seed: 42,
            isBot: false,
            opponentElo: 1350,
          );
      final state = container.read(duelProvider);
      expect(state.opponentElo, 1350);
    });

    test('updateOpponentScore changes score', () {
      container
          .read(duelProvider.notifier)
          .setMatch(matchId: 'abc', seed: 42, isBot: false);
      container.read(duelProvider.notifier).updateOpponentScore(250);
      final state = container.read(duelProvider);
      expect(state.opponentScore, 250);
      expect(state.matchId, 'abc'); // preserved
    });

    test('setOpponentDone sets score and done flag', () {
      container
          .read(duelProvider.notifier)
          .setMatch(matchId: 'abc', seed: 42, isBot: false);
      container.read(duelProvider.notifier).setOpponentDone(1000);
      final state = container.read(duelProvider);
      expect(state.opponentScore, 1000);
      expect(state.isOpponentDone, isTrue);
    });

    test('reset returns to empty state', () {
      final notifier = container.read(duelProvider.notifier);
      notifier.setMatch(matchId: 'abc', seed: 42, isBot: true);
      notifier.updateOpponentScore(500);
      notifier.reset();
      final state = container.read(duelProvider);
      expect(state.matchId, isNull);
      expect(state.seed, isNull);
      expect(state.isBot, isFalse);
      expect(state.opponentScore, 0);
      expect(state.isOpponentDone, isFalse);
    });
  });
}
