import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/game/shapes/gel_shape.dart';
import 'package:gloo/game/world/grid_manager.dart';

void main() {
  group('availableColors filtering', () {
    test('generateSmartHand respects availableColors', () {
      final sg = ShapeGenerator(rng: Random(42));
      final gm = GridManager(rows: 8, cols: 8);
      final colors = [GelColor.red, GelColor.blue];

      final hand = sg.generateSmartHand(
        gridManager: gm,
        difficulty: 0.5,
        availableColors: colors,
      );

      for (final (_, color) in hand) {
        expect(colors.contains(color), isTrue,
            reason: 'Color $color not in availableColors');
      }
    });

    test('generateSmartHand uses kPrimaryColors when availableColors is null',
        () {
      final sg = ShapeGenerator(rng: Random(42));
      final gm = GridManager(rows: 8, cols: 8);

      final hand = sg.generateSmartHand(
        gridManager: gm,
        difficulty: 0.5,
      );

      for (final (_, color) in hand) {
        expect(kPrimaryColors.contains(color), isTrue);
      }
    });

    test('generateSeededHand respects availableColors', () {
      final colors = [GelColor.yellow, GelColor.white];
      final hand = ShapeGenerator.generateSeededHand(
        42,
        availableColors: colors,
      );

      for (final (_, color) in hand) {
        expect(colors.contains(color), isTrue,
            reason: 'Seeded hand color $color not in availableColors');
      }
    });

    test('single available color produces uniform hand', () {
      final sg = ShapeGenerator(rng: Random(99));
      final gm = GridManager(rows: 8, cols: 8);
      final colors = [GelColor.red];

      final hand = sg.generateSmartHand(
        gridManager: gm,
        difficulty: 0.5,
        availableColors: colors,
      );

      for (final (_, color) in hand) {
        expect(color, GelColor.red);
      }
    });

    test('generateNextSeededHand passes availableColors through', () {
      final colors = [GelColor.blue, GelColor.white];
      final hand = ShapeGenerator.generateNextSeededHand(
        baseSeed: 100,
        handIndex: 0,
        moveCount: 5,
        availableColors: colors,
      );

      for (final (_, color) in hand) {
        expect(colors.contains(color), isTrue);
      }
    });

    test('generateHand respects availableColors', () {
      final sg = ShapeGenerator(rng: Random(42));
      final colors = [GelColor.yellow];

      final hand = sg.generateHand(availableColors: colors);

      for (final (_, color) in hand) {
        expect(color, GelColor.yellow);
      }
    });
  });
}
