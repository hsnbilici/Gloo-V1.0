import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/foundation.dart';

/// Kaydedilen frame'leri viral klip haline getiren işlemci.
///
/// Platform desteği: Android, iOS.
/// Web'de tüm işlemler sessizce atlanır (kIsWeb guard).
///
/// İşlem zinciri:
/// 1. Frame dizisi giriş: `framesDir/frame_%04d.png`
/// 2. Yavaş çekim: `-filter:v "setpts=2.0*PTS"` (0.5× hız)
/// 3. Renk grading: `eq=saturation=1.3:contrast=1.1`
/// 4. Filigran (opsiyonel): `-i watermark.png -filter_complex "overlay=W-w-10:10"`
/// 5. Çıkış: H.264 MP4, 30fps, yuv420p piksel formatı
class VideoProcessRequest {
  const VideoProcessRequest({
    required this.framesDir,
    required this.outputPath,
    this.watermarkAssetPath,
    this.slowMotionFactor = 2.0,
  });

  final String framesDir;
  final String outputPath;
  final String? watermarkAssetPath;
  final double slowMotionFactor;
}

class VideoProcessor {
  /// Frame dizisini yavaş çekim + renk grading + filigranla MP4'e çevirir.
  ///
  /// Döner: çıkış dosyasının yolu (başarılı) veya null (hata/web)
  Future<String?> processClip(VideoProcessRequest req) async {
    if (kIsWeb) return null;

    final pts = req.slowMotionFactor.toStringAsFixed(1);
    final baseFilter = 'setpts=$pts*PTS,eq=saturation=1.3:contrast=1.1';

    String cmd;
    if (req.watermarkAssetPath != null) {
      cmd = '-r 30 -i ${req.framesDir}/frame_%04d.png '
          '-i ${req.watermarkAssetPath} '
          '-filter_complex "[$baseFilter][1:v]overlay=W-w-10:10" '
          '-c:v libx264 -pix_fmt yuv420p -y ${req.outputPath}';
    } else {
      cmd = '-r 30 -i ${req.framesDir}/frame_%04d.png '
          '-filter:v "$baseFilter" '
          '-c:v libx264 -pix_fmt yuv420p -y ${req.outputPath}';
    }

    try {
      final session = await FFmpegKit.execute(cmd);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('VideoProcessor: success → ${req.outputPath}');
        return req.outputPath;
      }
      final logs = await session.getLogs();
      debugPrint(
          'VideoProcessor error: ${logs.map((l) => l.getMessage()).join('\n')}');
      return null;
    } catch (e) {
      debugPrint('VideoProcessor.processClip error: $e');
      return null;
    }
  }
}
