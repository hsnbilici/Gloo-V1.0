import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/services/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    test('singleton returns same instance', () {
      final a = AnalyticsService();
      final b = AnalyticsService();
      expect(identical(a, b), isTrue);
    });

    test('setEnabled does not throw without Firebase', () async {
      final service = AnalyticsService();
      // Should gracefully handle null Firebase instances
      await expectLater(service.setEnabled(false), completes);
      await expectLater(service.setEnabled(true), completes);
    });

    test('logGameStart does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(() => service.logGameStart(mode: 'classic'), returnsNormally);
    });

    test('logGameOver does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(
        () => service.logGameOver(mode: 'classic', score: 500),
        returnsNormally,
      );
    });

    test('logCombo does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(() => service.logCombo(tier: 'epic'), returnsNormally);
    });

    test('logShare does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(() => service.logShare(mode: 'classic'), returnsNormally);
    });

    test('logPowerUpUsed does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(
        () => service.logPowerUpUsed(powerUp: 'bomb', mode: 'classic'),
        returnsNormally,
      );
    });

    test('logLevelComplete does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(
        () => service.logLevelComplete(levelId: 1, score: 100),
        returnsNormally,
      );
    });

    test('logPvpResult does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(
        () => service.logPvpResult(
          outcome: 'win',
          eloChange: 15,
          isBot: false,
        ),
        returnsNormally,
      );
    });

    test('logColorSynthesis does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(
        () => service.logColorSynthesis(resultColor: 'orange'),
        returnsNormally,
      );
    });

    test('logPurchase does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(
        () => service.logPurchase(productId: 'gloo_plus_monthly'),
        returnsNormally,
      );
    });

    test('recordError does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(
        () => service.recordError(Exception('test'), StackTrace.current),
        returnsNormally,
      );
    });

    test('setUserId does not throw without Firebase', () {
      final service = AnalyticsService();
      expect(() => service.setUserId('user123'), returnsNormally);
    });

    test('disabled service does not call log methods', () {
      final service = AnalyticsService();
      service.setEnabled(false);
      // All these should silently no-op
      expect(() => service.logGameStart(mode: 'zen'), returnsNormally);
      expect(
        () => service.logGameOver(mode: 'zen', score: 0),
        returnsNormally,
      );
      expect(() => service.logCombo(tier: 'small'), returnsNormally);
      expect(
        () => service.recordError('error', null, reason: 'test'),
        returnsNormally,
      );
    });
  });
}
