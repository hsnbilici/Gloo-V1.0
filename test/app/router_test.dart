import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/game/world/game_world.dart';

void main() {
  group('GameMode.fromString', () {
    test('parses classic', () {
      expect(GameMode.fromString('classic'), GameMode.classic);
    });

    test('parses colorChef', () {
      expect(GameMode.fromString('colorChef'), GameMode.colorChef);
    });

    test('parses timeTrial', () {
      expect(GameMode.fromString('timeTrial'), GameMode.timeTrial);
    });

    test('parses zen', () {
      expect(GameMode.fromString('zen'), GameMode.zen);
    });

    test('parses daily', () {
      expect(GameMode.fromString('daily'), GameMode.daily);
    });

    test('parses level', () {
      expect(GameMode.fromString('level'), GameMode.level);
    });

    test('parses duel', () {
      expect(GameMode.fromString('duel'), GameMode.duel);
    });

    test('unknown mode falls back to classic', () {
      expect(GameMode.fromString('unknown'), GameMode.classic);
    });

    test('empty string falls back to classic', () {
      expect(GameMode.fromString(''), GameMode.classic);
    });

    test('case-sensitive — Classic is not valid', () {
      expect(GameMode.fromString('Classic'), GameMode.classic);
    });
  });

  group('GameMode enum', () {
    test('has exactly 7 modes', () {
      expect(GameMode.values.length, 7);
    });

    test('all modes have unique names', () {
      final names = GameMode.values.map((m) => m.name).toSet();
      expect(names.length, GameMode.values.length);
    });
  });
}
