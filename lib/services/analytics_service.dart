import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Firebase Analytics + Crashlytics sarmalayıcısı.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;

  final _analytics = FirebaseAnalytics.instance;
  final _crashlytics = FirebaseCrashlytics.instance;

  bool _enabled = true;

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _analytics.setAnalyticsCollectionEnabled(enabled);
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  // ── Oyun yaşam döngüsü ─────────────────────────────────────────────────

  void logGameStart({required String mode}) {
    if (!_enabled) return;
    _analytics.logEvent(
      name: 'game_start',
      parameters: {'mode': mode},
    );
  }

  void logGameOver({required String mode, required int score}) {
    if (!_enabled) return;
    _analytics.logEvent(
      name: 'game_over',
      parameters: {'mode': mode, 'score': score},
    );
  }

  void logCombo({required String tier}) {
    if (!_enabled) return;
    _analytics.logEvent(
      name: 'combo',
      parameters: {'tier': tier},
    );
  }

  void logShare({required String mode}) {
    if (!_enabled) return;
    _analytics.logEvent(
      name: 'share',
      parameters: {'mode': mode},
    );
  }

  // ── Custom event'ler ──────────────────────────────────────────────────

  void logPowerUpUsed({required String powerUp, required String mode}) {
    if (!_enabled) return;
    _analytics.logEvent(
      name: 'power_up_used',
      parameters: {'power_up': powerUp, 'mode': mode},
    );
  }

  void logLevelComplete({required int levelId, required int score}) {
    if (!_enabled) return;
    _analytics.logEvent(
      name: 'level_complete',
      parameters: {'level_id': levelId, 'score': score},
    );
  }

  void logPvpResult({
    required String outcome,
    required int eloChange,
    required bool isBot,
  }) {
    if (!_enabled) return;
    _analytics.logEvent(
      name: 'pvp_result',
      parameters: {
        'outcome': outcome,
        'elo_change': eloChange,
        'is_bot': isBot,
      },
    );
  }

  void logColorSynthesis({required String resultColor}) {
    if (!_enabled) return;
    _analytics.logEvent(
      name: 'color_synthesis',
      parameters: {'result_color': resultColor},
    );
  }

  void logPurchase({required String productId}) {
    if (!_enabled) return;
    _analytics.logEvent(
      name: 'iap_purchase',
      parameters: {'product_id': productId},
    );
  }

  // ── Crashlytics ─────────────────────────────────────────────────────────

  void recordError(dynamic error, StackTrace? stack, {String? reason}) {
    if (!_enabled) return;
    _crashlytics.recordError(error, stack, reason: reason);
  }

  void setUserId(String userId) {
    _analytics.setUserId(id: userId);
    _crashlytics.setUserIdentifier(userId);
  }
}
