import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/game_constants.dart';

void main() {
  test('streak rewards defined for milestones 3, 7, 14, 30', () {
    expect(GameConstants.streakRewards[3], 10);
    expect(GameConstants.streakRewards[7], 50);
    expect(GameConstants.streakRewards[14], 100);
    expect(GameConstants.streakRewards[30], 200);
  });

  test('no reward for non-milestone days', () {
    expect(GameConstants.streakRewards[1], isNull);
    expect(GameConstants.streakRewards[5], isNull);
    expect(GameConstants.streakRewards[10], isNull);
  });
}
