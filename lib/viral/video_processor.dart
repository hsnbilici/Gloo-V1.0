// ffmpeg_kit_flutter_full_gpl disabled — paket discontinued, GitHub release 404.
// Video processing geçici olarak devre dışı. Oyun fonksiyonelliği etkilenmez.
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
  ///
  /// NOT: ffmpeg_kit_flutter_full_gpl discontinued olduğu için geçici olarak
  /// devre dışı. Paket yeniden kullanılabilir olduğunda geri alınacak.
  Future<String?> processClip(VideoProcessRequest req) async {
    if (kDebugMode) {
      debugPrint('VideoProcessor: ffmpeg_kit disabled — returning null');
    }
    return null;
  }
}
