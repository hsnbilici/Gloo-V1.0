import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../services/analytics_service.dart';

class ShareManager {
  static const String _hashtags = '#Gloo #ASMR #satisfying #puzzle #colorsort';
  static const String _appUrl = 'https://gloo.app';

  Future<void> shareScore({required int score, required String mode}) async {
    final text = _buildCaption(score: score, mode: mode);
    AnalyticsService().logShare(mode: mode);
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
      AnalyticsService().logShare(mode: 'video');
    } catch (e) {
      debugPrint('ShareManager.shareVideo error: $e');
    }
  }

  Future<void> shareDailyResult({
    required int score,
    required String dateLabel,
  }) async {
    AnalyticsService().logShare(mode: 'daily');
    final text = 'Günlük Bulmaca [$dateLabel] — ${_formatScore(score)} puan! '
        'Sen bugün kaç yaptın? '
        '$_appUrl\n\n$_hashtags';
    await Share.share(text);
  }

  String _buildCaption({required int score, required String mode}) {
    final modeLabel = switch (mode) {
      'classic' => 'Klasik',
      'colorChef' => 'Renk Şefi',
      'timeTrial' => 'Zaman Koşusu',
      'zen' => 'Zen',
      'daily' => 'Günlük Bulmaca',
      _ => mode,
    };

    return '$modeLabel modunda ${_formatScore(score)} puan yaptım! '
        'Senin en yüksek puanın nedir? '
        '$_appUrl\n\n$_hashtags';
  }

  String _formatScore(int score) {
    if (score >= 1000000) return '${(score / 1000000).toStringAsFixed(1)}M';
    if (score >= 1000) return '${(score / 1000).toStringAsFixed(1)}K';
    return score.toString();
  }
}
