import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../core/utils/near_miss_detector.dart';
import '../game/systems/combo_detector.dart';
import 'video_processor.dart';

/// Oyun anlarını klip olarak kayıt eden yönetici.
///
/// Web'de tüm işlemler sessizce atlanır (kIsWeb guard).
/// Mobil platformlarda RepaintBoundary frame capture + FFmpeg pipeline.
enum RecordingState { idle, buffering, processing }

class ClipRecorder {
  /// RepaintBoundary için global key — game_screen içinde ızgarayı sarmalamak için kullanılır.
  final GlobalKey repaintKey = GlobalKey();

  /// Sonuç klip dosyasına hazır olunca callback.
  void Function(String outputPath)? onClipReady;

  RecordingState _state = RecordingState.idle;
  bool _autoStopScheduled = false;
  final List<ui.Image> _capturedFrames = [];

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
    if (_state == RecordingState.buffering) return;
    _beginCapture();
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
    _capturedFrames.clear();
    debugPrint('ClipRecorder: recording started');
  }

  /// Her frame'de çağrılacak — RepaintBoundary'den frame yakalar.
  /// GameScreen post-frame callback'inde çağrılmalı.
  Future<void> captureFrame() async {
    if (_state != RecordingState.buffering) return;
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 1.0);
      _capturedFrames.add(image);
    } catch (e) {
      debugPrint('ClipRecorder.captureFrame error: $e');
    }
  }

  Future<void> _finalizeClip() async {
    if (_state != RecordingState.buffering) return;
    _state = RecordingState.processing;
    debugPrint('ClipRecorder: processing ${_capturedFrames.length} frames');

    if (_capturedFrames.isEmpty) {
      _state = RecordingState.idle;
      return;
    }

    try {
      // Frame'leri gecici dizine PNG olarak kaydet
      final tempDir = await getTemporaryDirectory();
      final framesDir =
          Directory('${tempDir.path}/gloo_clip_frames');
      if (await framesDir.exists()) {
        await framesDir.delete(recursive: true);
      }
      await framesDir.create(recursive: true);

      for (int i = 0; i < _capturedFrames.length; i++) {
        final byteData = await _capturedFrames[i]
            .toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) continue;
        final file = File(
            '${framesDir.path}/frame_${i.toString().padLeft(4, '0')}.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
      }

      // FFmpeg ile video isle
      final outputPath = '${tempDir.path}/gloo_clip.mp4';
      final processor = VideoProcessor();
      final result = await processor.processClip(VideoProcessRequest(
        framesDir: framesDir.path,
        outputPath: outputPath,
      ));

      if (result != null) {
        debugPrint('ClipRecorder: clip ready at $result');
        onClipReady?.call(result);
      }

      // Temizlik
      for (final img in _capturedFrames) {
        img.dispose();
      }
      _capturedFrames.clear();
    } catch (e) {
      debugPrint('ClipRecorder._finalizeClip error: $e');
    }

    _state = RecordingState.idle;
  }

  void dispose() {
    for (final img in _capturedFrames) {
      img.dispose();
    }
    _capturedFrames.clear();
  }

  // Eski API uyumluluğu
  void onTrigger(NearMissEvent event) => onNearMiss(event);
}
