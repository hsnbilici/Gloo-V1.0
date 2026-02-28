import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';

import '../core/constants/audio_constants.dart';

/// Singleton ses yöneticisi.
///
/// SFX: [maxConcurrentSfxChannels] adet `AudioPlayer` havuzu, round-robin.
/// Müzik: tek `AudioPlayer`, döngü modunda.
///
/// Ses dosyaları `assets/audio/sfx/` ve `assets/audio/music/` altında
/// `AudioPaths` sabitlerinde tanımlı yollarla konumlandırılmalıdır.
/// Dosya bulunamazsa hata fırlatılmaz; sessizce atlanır.
class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  final _musicPlayer = AudioPlayer();
  late final List<AudioPlayer> _sfxPool = List.generate(
    AudioConfig.maxConcurrentSfxChannels,
    (_) => AudioPlayer(),
  );
  final _random = math.Random();
  int _sfxIndex = 0;

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  String? _currentMusicPath;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> initialize() async {
    // iOS audio session — ambient kategorisi: diğer seslerle karışır, sessiz modda sessiz
    if (!kIsWeb && Platform.isIOS) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
      ));
    }

    await _musicPlayer.setVolume(AudioConfig.musicVolume);
    await _musicPlayer.setLoopMode(LoopMode.all);
  }

  /// Kısa ses efekti oynat. [path] `AudioPaths` sabiti kullanılmalıdır.
  /// [pitchVariation] true ise [AudioConfig.pitchVarianceMin]–[AudioConfig.pitchVarianceMax]
  /// aralığında rasgele oynatma hızı uygulanır (tekrar hissi azalır).
  Future<void> playSfx(
    String path, {
    double volume = 1.0,
    bool pitchVariation = true,
  }) async {
    if (!_sfxEnabled) return;
    try {
      final player = _sfxPool[_sfxIndex % _sfxPool.length];
      _sfxIndex++;
      await player.setVolume(AudioConfig.sfxVolume * volume);
      if (pitchVariation) {
        final speed = AudioConfig.pitchVarianceMin +
            (AudioConfig.pitchVarianceMax - AudioConfig.pitchVarianceMin) *
                _random.nextDouble();
        await player.setSpeed(speed);
      } else {
        await player.setSpeed(1.0);
      }
      await player.setAsset(path);
      unawaited(player.play());
    } catch (_) {
      // Ses dosyası bulunamadı ya da çalma hatası — sessizce atla
    }
  }

  /// Arka plan müziği oynat. Aynı yol zaten oynatılıyorsa yeniden başlatmaz.
  Future<void> playMusic(String path, {bool loop = true}) async {
    if (!_musicEnabled) return;
    if (_currentMusicPath == path) return;
    try {
      _currentMusicPath = path;
      await _musicPlayer.setLoopMode(loop ? LoopMode.all : LoopMode.off);
      await _musicPlayer.setAsset(path);
      unawaited(_musicPlayer.play());
    } catch (_) {
      // Müzik dosyası bulunamadı — sessizce atla
    }
  }

  /// Müziği duraklat (devam ettirilebilir).
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  /// Müziği devam ettir.
  Future<void> resumeMusic() async {
    if (_musicEnabled) await _musicPlayer.play();
  }

  void setSfxEnabled(bool value) {
    _sfxEnabled = value;
    if (!value) {
      for (final p in _sfxPool) {
        p.stop();
      }
    }
  }

  void setMusicEnabled(bool value) {
    _musicEnabled = value;
    if (!value) {
      _musicPlayer.pause();
    } else if (_currentMusicPath != null) {
      _musicPlayer.play();
    }
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    for (final p in _sfxPool) {
      await p.dispose();
    }
  }
}

/// `unawaited` yardımcısı — lint uyarısını bastırmak için.
void unawaited(Future<void> future) {
  future.ignore();
}
