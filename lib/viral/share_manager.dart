import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../core/l10n/app_strings.dart';
import '../services/analytics_service.dart';

class ShareManager {
  static const String _hashtags = '#Gloo #ASMR #satisfying #puzzle #colorsort';
  static const String _appUrl = 'https://gloo.app';

  final AnalyticsService _analytics;

  ShareManager({AnalyticsService? analyticsService})
      : _analytics = analyticsService ?? AnalyticsService();

  Future<void> shareScore({
    required int score,
    required String mode,
    required AppStrings l,
  }) async {
    final text = _buildCaption(score: score, mode: mode, l: l);
    _analytics.logShare(mode: mode);
    await Share.share(text);
  }

  /// Video klip dosyasını (MP4) metin başlığıyla paylaşır.
  /// Web'de sessizce atlanır.
  Future<void> shareVideo({
    required String videoPath,
    required String caption,
  }) async {
    if (kIsWeb) return;
    try {
      await Share.shareXFiles(
        [XFile(videoPath)],
        text: '$caption\n\n$_hashtags',
      );
      _analytics.logShare(mode: 'video');
    } catch (e) {
      if (kDebugMode) debugPrint('ShareManager.shareVideo error: $e');
    }
  }

  Future<void> shareDailyResult({
    required int score,
    required String dateLabel,
    required AppStrings l,
  }) async {
    _analytics.logShare(mode: 'daily');
    final text = '${l.shareDailyCaption(dateLabel, _formatScore(score))} '
        '${l.shareDailyChallenge} '
        '$_appUrl\n\n$_hashtags';
    await Share.share(text);
  }

  Future<void> shareComboResult({
    required int score,
    required String mode,
    required String comboLabel,
    required AppStrings l,
  }) async {
    final modeName = _modeName(l, mode);
    final text =
        '${l.shareComboCaption(comboLabel, modeName, _formatScore(score))} '
        '$_appUrl\n\n$_hashtags';
    _analytics.logShare(mode: 'combo');
    await Share.share(text);
  }

  String _buildCaption({
    required int score,
    required String mode,
    required AppStrings l,
  }) {
    final modeName = _modeName(l, mode);
    return '${l.shareScoreCaption(modeName, _formatScore(score))} '
        '${l.shareScoreChallenge} '
        '$_appUrl\n\n$_hashtags';
  }

  String _modeName(AppStrings l, String mode) => switch (mode) {
        'classic' => l.modeLabelClassic,
        'colorChef' => l.modeLabelColorChef,
        'timeTrial' => l.modeLabelTimeTrial,
        'zen' => l.modeLabelZen,
        'daily' => l.modeLabelDaily,
        _ => mode,
      };

  String _formatScore(int score) {
    if (score >= 1000000) return '${(score / 1000000).toStringAsFixed(1)}M';
    if (score >= 1000) return '${(score / 1000).toStringAsFixed(1)}K';
    return score.toString();
  }
}
