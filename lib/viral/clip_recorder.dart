import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/utils/near_miss_detector.dart';
import '../game/systems/combo_detector.dart';

/// Oyun anlarını klip olarak kayıt eden yönetici.
///
/// Web'de tüm işlemler sessizce atlanır (kIsWeb guard).
/// Mobil platformlarda şu an state yönetimi aktiftir;
/// gerçek frame yakalama `screen_recorder` paketi eklenince etkinleştirilecektir.
///
/// Entegrasyon adımları (pubspec.yaml'a eklenince):
/// ```yaml
/// screen_recorder: ^0.3.0
/// ffmpeg_kit_flutter_full_gpl: ^6.0.3
/// ```
///
/// FFmpeg komutu (frame dizisini video'ya çevirir):
/// ```
/// ffmpeg -r 30 -i frame_%04d.png -c:v libx264 -pix_fmt yuv420p output.mp4
/// ```
enum RecordingState { idle, buffering, processing }

class ClipRecorder {
  /// RepaintBoundary için global key — game_screen içinde ızgarayı sarmalamak için kullanılır.
  final GlobalKey repaintKey = GlobalKey();

  /// Sonuç klip dosyasına hazır olunca callback.
  void Function(String outputPath)? onClipReady;

  RecordingState _state = RecordingState.idle;
  bool _autoStopScheduled = false;

  RecordingState get state => _state;
  bool get isBuffering => _state == RecordingState.buffering;

  // ─── Tetikleyiciler ───────────────────────────────────────────────────────

  /// Near-miss olayında klip kayıt başlatır.
  void onNearMiss(NearMissEvent event) {
    if (kIsWeb) return;
    _triggerCapture();
  }

  /// Combo olayında klip kayıt başlatır — sadece large/epic tier tetikler.
  void onCombo(ComboEvent combo) {
    if (kIsWeb) return;
    if (combo.tier.index < ComboTier.large.index) return;
    _triggerCapture();
  }

  // ─── Kayıt kontrolü ──────────────────────────────────────────────────────

  /// Manuel kayıt başlat (dış çağrı için).
  void startRecording() {
    if (kIsWeb) return;
    if (_state == RecordingState.buffering) return;
    _beginCapture();
  }

  /// Manuel kayıt durdur ve işleme geç.
  void stopRecording() {
    if (_state != RecordingState.buffering) return;
    _finalizeClip();
  }

  // ─── Dahili ───────────────────────────────────────────────────────────────

  void _triggerCapture() {
    if (_state == RecordingState.buffering) return; // zaten kayıt var
    _beginCapture();
    // 5 saniye sonra otomatik durdur
    if (!_autoStopScheduled) {
      _autoStopScheduled = true;
      Future.delayed(const Duration(seconds: 5), () {
        _autoStopScheduled = false;
        if (_state == RecordingState.buffering) _finalizeClip();
      });
    }
  }

  void _beginCapture() {
    _state = RecordingState.buffering;
    // TODO: screen_recorder paketi eklenince aşağıdaki satırlar aktifleştirilir:
    // _controller.start();
  }

  void _finalizeClip() {
    if (_state != RecordingState.buffering) return;
    _state = RecordingState.processing;

    // TODO: screen_recorder paketi eklenince:
    // final frames = await _controller.stop();
    // final outputPath = await _processFrames(frames);
    // onClipReady?.call(outputPath);

    _state = RecordingState.idle;
  }

  void dispose() {
    // TODO: _controller.dispose() — screen_recorder eklenince aktifleştirilir.
  }

  // Eski API uyumluluğu (mevcut stub imzasını korur)
  void onTrigger(NearMissEvent event) => onNearMiss(event);
}
