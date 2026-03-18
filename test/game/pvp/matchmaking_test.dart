import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/pvp/matchmaking.dart';

void main() {
  group('ObstacleGenerator.fromLineClear', () {
    test('medium kombo bonus uretir', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 2,
        comboTier: 'medium',
      );
      final totalCount =
          packets.fold<int>(0, (sum, p) => sum + p.count);
      // base: ice(2) + locked(1) + medium bonus: ice(2) + stone(1) = 6
      expect(totalCount, 6);
    });

    test('large kombo medium\'dan daha agir engel uretir', () {
      final medium = ObstacleGenerator.fromLineClear(
        linesCleared: 2,
        comboTier: 'medium',
      );
      final large = ObstacleGenerator.fromLineClear(
        linesCleared: 2,
        comboTier: 'large',
      );
      final mediumTotal =
          medium.fold<int>(0, (sum, p) => sum + p.count);
      final largeTotal =
          large.fold<int>(0, (sum, p) => sum + p.count);

      expect(mediumTotal, 6);
      expect(largeTotal, 8); // base(2) + locked(1) + ice(3) + stone(2)
      expect(largeTotal, greaterThan(mediumTotal));
    });

    test('epic kombo alan etkisi uretir', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 1,
        comboTier: 'epic',
      );
      final hasAreaEffect =
          packets.any((p) => p.areaSize != null && p.areaSize! > 1);
      expect(hasAreaEffect, isTrue);
    });
  });
}
