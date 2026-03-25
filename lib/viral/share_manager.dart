import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/color_constants.dart';
import '../core/l10n/app_strings.dart';
import '../core/models/challenge.dart';
import '../services/analytics_service.dart';

class ShareManager {
  static const String _hashtags = '#Gloo #ASMR #satisfying #puzzle #colorsort';
  static const String _appUrl = 'https://gloogame.com';
  static const String _shareBaseUrl = 'https://gloogame.com/share';

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

  /// Daily puzzle sonucunu Wordle formatında emoji grid ile paylaşır.
  ///
  /// [grid] — oyun sonu grid durumu (GlooGame.gridManager.grid). null ise
  /// grid satırı gösterilmez; yalnızca skor ve başlık paylaşılır.
  Future<void> shareDailyResult({
    required int score,
    required String dateLabel,
    required AppStrings l,
    List<List<GelColor?>>? grid,
  }) async {
    _analytics.logShare(mode: 'daily');
    final emojiGrid = grid != null ? buildDailyEmojiGrid(grid, score) : null;
    final caption = l.shareDailyCaption(dateLabel, _formatScore(score));
    final challenge = l.shareDailyChallenge;
    // Deep link: recipients can tap to open the same daily puzzle directly.
    final dailyLink = '$_shareBaseUrl/daily?date=${Uri.encodeComponent(dateLabel)}';
    final text = emojiGrid != null
        ? '$caption\n$emojiGrid\n$challenge $dailyLink\n\n$_hashtags'
        : '$caption $challenge $dailyLink\n\n$_hashtags';
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

  Future<void> shareChallenge(Challenge challenge, AppStrings l) async {
    final text = '${l.challengeShareCaption(challenge.senderUsername)}\n'
        'https://gloogame.com/challenge/${challenge.id}\n\n'
        '#GlooChallenge #Gloo #puzzle';
    _analytics.logShare(mode: 'challenge');
    await Share.share(text);
  }

  /// Keşfedilen sentez renklerini paylaşır.
  ///
  /// [discoveredColors] — oyuncunun şimdiye kadar keşfettiği sentez renkleri.
  Future<void> shareCollection({
    required AppStrings l,
    required Set<GelColor> discoveredColors,
  }) async {
    const total = 8; // sentez rengi sayısı (kColorMixingTable değerleri)
    final found = discoveredColors.length;
    final emojis = discoveredColors.map(_colorEmoji).join(' ');
    final text = '${l.shareCollectionCaption(found, total)}\n$emojis\n#GlooGame';
    _analytics.logShare(mode: 'collection');
    await Share.share(text);
  }

  /// Oyun sonu grid durumundan Wordle benzeri emoji grid metni üretir.
  ///
  /// Dolu hücreler ilgili renk emoji'siyle, boş hücreler ⬛ ile gösterilir.
  /// En fazla [maxRows] satır gösterilir; fazlası "+N more" ile belirtilir.
  /// Yıldız sayısı skor bazlıdır (1–3 ⭐).
  String buildDailyEmojiGrid(
    List<List<GelColor?>> grid,
    int score, {
    int maxRows = 5,
  }) {
    final stars = _starRating(score);
    final starStr = '⭐' * stars;

    // Sadece en az bir dolu hücre içeren satırları al
    final filledRows = <List<GelColor?>>[];
    for (final row in grid) {
      if (row.any((c) => c != null)) filledRows.add(row);
    }

    final shownRows = filledRows.take(maxRows).toList();
    final overflow = filledRows.length - shownRows.length;

    final buffer = StringBuffer();
    buffer.writeln('$kAppName Daily $starStr');
    for (final row in shownRows) {
      buffer.writeln(row.map((c) => c != null ? _colorEmoji(c) : '⬛').join());
    }
    if (overflow > 0) buffer.writeln('...+$overflow more');

    return buffer.toString().trimRight();
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

  /// Skor bazlı yıldız sayısı: <500→1, <2000→2, ≥2000→3.
  int _starRating(int score) {
    if (score >= 2000) return 3;
    if (score >= 500) return 2;
    return 1;
  }

  /// GelColor → tek unicode emoji.
  String _colorEmoji(GelColor color) => switch (color) {
        GelColor.red => '🟥',
        GelColor.yellow => '🟨',
        GelColor.blue => '🟦',
        GelColor.white => '⬜',
        GelColor.orange => '🟧',
        GelColor.green => '🟩',
        GelColor.purple => '🟪',
        GelColor.pink => '🩷',
        GelColor.lightBlue => '🩵',
        GelColor.lime => '🟢',
        GelColor.maroon => '🟤',
        GelColor.brown => '🤎',
      };
}
