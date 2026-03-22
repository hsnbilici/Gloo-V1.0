import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
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
  final List<AudioPlayer?> _sfxPool =
      List.filled(AudioConfig.maxConcurrentSfxChannels, null);
  final _random = math.Random();
  int _nextSfxIndex = 0;

  AudioPlayer _getNextPlayer() {
    _sfxPool[_nextSfxIndex] ??= AudioPlayer();
    final player = _sfxPool[_nextSfxIndex]!;
    _nextSfxIndex = (_nextSfxIndex + 1) % _sfxPool.length;
    return player;
  }

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _isFading = false;
  String? _currentMusicPath;
  AudioPackage _activePackage = AudioPackage.standard;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  AudioPackage get activePackage => _activePackage;

  Future<void> initialize() async {
    // iOS audio session — ambient kategorisi: diğer seslerle karışır, sessiz modda sessiz
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
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
  /// Aktif ses paketi varsa path otomatik olarak paket klasörüne yönlendirilir;
  /// paket dosyası bulunamazsa standard path'e fallback yapılır.
  Future<void> playSfx(
    String path, {
    double volume = 1.0,
    bool pitchVariation = true,
    double? speed,
  }) async {
    if (!_sfxEnabled) return;
    final resolvedPath = _resolvePackagePath(path);
    await _playSfxAtPath(resolvedPath, volume: volume, pitchVariation: pitchVariation, speed: speed);
  }

  Future<void> _playSfxAtPath(
    String path, {
    double volume = 1.0,
    bool pitchVariation = true,
    double? speed,
    bool isFallback = false,
  }) async {
    try {
      final player = _getNextPlayer();
      await player.setVolume(AudioConfig.sfxVolume * volume);
      if (speed != null) {
        await player.setSpeed(speed);
      } else if (pitchVariation) {
        final s = AudioConfig.pitchVarianceMin +
            (AudioConfig.pitchVarianceMax - AudioConfig.pitchVarianceMin) *
                _random.nextDouble();
        await player.setSpeed(s);
      } else {
        await player.setSpeed(1.0);
      }
      await player.setAsset(path);
      unawaited(player.play());
    } catch (_) {
      // Paket dosyası bulunamadıysa standard path'e fallback yap
      if (!isFallback && _activePackage != AudioPackage.standard) {
        await _playSfxAtPath(
          path.replaceFirst('assets/audio/sfx/${_activePackage.name}/', 'assets/audio/sfx/'),
          volume: volume,
          pitchVariation: pitchVariation,
          speed: speed,
          isFallback: true,
        );
      }
      // Standard path de başarısız olursa sessizce atla
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

  /// Müziği kademeli olarak kıs ve duraklat.
  Future<void> fadeOutMusic(Duration duration) async {
    _isFading = true;
    try {
      const steps = 10;
      final stepDuration = duration ~/ steps;
      const startVolume = AudioConfig.musicVolume;
      for (var i = steps - 1; i >= 0; i--) {
        await Future.delayed(stepDuration);
        await _musicPlayer.setVolume(startVolume * i / steps);
      }
      await _musicPlayer.pause();
      // Volume'u eski haline getir (resume/play'de kullanılacak)
      await _musicPlayer.setVolume(startVolume);
    } finally {
      _isFading = false;
    }
  }

  /// Mevcut müzikten [newPath]'e [duration] sürede çapraz geçiş yapar.
  /// Aynı parça zaten çalıyorsa veya fade devam ediyorsa no-op.
  Future<void> crossfadeMusic(String newPath, {Duration duration = const Duration(milliseconds: 1500)}) async {
    if (!_musicEnabled) return;
    if (_currentMusicPath == newPath) return;
    if (_isFading) return;
    _isFading = true;
    try {
      // Mevcut parçayı kıs
      const steps = 8;
      final stepDuration = duration ~/ (steps * 2);
      const startVolume = AudioConfig.musicVolume;
      for (var i = steps - 1; i >= 0; i--) {
        await Future.delayed(stepDuration);
        await _musicPlayer.setVolume(startVolume * i / steps);
      }
      // Parçayı değiştir
      _currentMusicPath = newPath;
      await _musicPlayer.setAsset(newPath);
      unawaited(_musicPlayer.play());
      // Yeni parçayı aç
      for (var i = 1; i <= steps; i++) {
        await Future.delayed(stepDuration);
        await _musicPlayer.setVolume(startVolume * i / steps);
      }
    } catch (_) {
      // Sessizce atla
    } finally {
      _isFading = false;
    }
  }

  /// Müzik volume'unu geçici olarak değiştir. Fade sırasında atlanır.
  Future<void> setMusicVolume(double volume) async {
    if (_isFading) return;
    await _musicPlayer.setVolume(volume);
  }

  /// Müzik oynatma hızını değiştir (tempo).
  Future<void> setMusicSpeed(double speed) async {
    await _musicPlayer.setSpeed(speed);
  }

  /// Aktif ses paketini değiştirir. Mevcut SFX cache temizlenir.
  void setAudioPackage(AudioPackage package) {
    if (_activePackage == package) return;
    _activePackage = package;
    _clearSfxCache();
    if (kDebugMode) debugPrint('AudioManager: package changed to ${package.name}');
  }

  /// SFX havuzundaki player'ları durdurur ve sıfırlar.
  /// Sonraki play çağrısında yeni path'ten yüklenirler.
  void _clearSfxCache() {
    for (final p in _sfxPool) {
      p?.stop();
    }
  }

  /// Gelen tam path'i aktif pakete göre resolve eder.
  /// Path zaten `assets/audio/sfx/<name>.<ext>` formatındaysa base adı çıkarıp
  /// paket alt klasörüne yönlendirir. Müzik ve standart paket path'leri değişmez.
  String _resolvePackagePath(String path) {
    if (_activePackage == AudioPackage.standard) return path;
    // Sadece SFX path'lerini resolve et (müzik değişmez)
    if (!path.startsWith('assets/audio/sfx/')) return path;
    // Alt klasör içindeki path'leri (zaten paketle yüklenmiş) değiştirme
    const sfxPrefix = 'assets/audio/sfx/';
    final relative = path.substring(sfxPrefix.length); // e.g. "gel_place.ogg"
    if (relative.contains('/')) return path; // zaten alt klasörde
    // base adı: "gel_place.ogg" → "gel_place"
    final dotIndex = relative.lastIndexOf('.');
    final baseName = dotIndex >= 0 ? relative.substring(0, dotIndex) : relative;
    return AudioPaths.resolveSfxPath(baseName, _activePackage);
  }

  void setSfxEnabled(bool value) {
    _sfxEnabled = value;
    if (!value) {
      for (final p in _sfxPool) {
        p?.stop();
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
      await p?.dispose();
    }
  }
}

/// `unawaited` yardımcısı — lint uyarısını bastırmak için.
void unawaited(Future<void> future) {
  future.ignore();
}
