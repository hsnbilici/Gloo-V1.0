import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_manager.dart';
import '../audio/haptic_manager.dart';

class AudioSettings {
  const AudioSettings({
    this.sfxEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.colorBlindMode = false,
    this.analyticsEnabled = true,
    this.glooPlus = false,
    this.adsRemoved = false,
  });

  final bool sfxEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  /// Her dolu hücreye kısa renk etiketi (K/S/M/B…) ekler.
  final bool colorBlindMode;
  /// Firebase Analytics & Crashlytics veri toplamasına izin verir (GDPR).
  final bool analyticsEnabled;
  /// Gloo+ abonelik durumu — Zen Modu kilidi ve premium özellikler.
  final bool glooPlus;
  /// Reklamlar kaldırılmış mı (doğrudan IAP veya Gloo+).
  final bool adsRemoved;

  AudioSettings copyWith({
    bool? sfxEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? colorBlindMode,
    bool? analyticsEnabled,
    bool? glooPlus,
    bool? adsRemoved,
  }) {
    return AudioSettings(
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      glooPlus: glooPlus ?? this.glooPlus,
      adsRemoved: adsRemoved ?? this.adsRemoved,
    );
  }
}

class AudioSettingsNotifier extends StateNotifier<AudioSettings> {
  AudioSettingsNotifier() : super(const AudioSettings());

  void toggleSfx() {
    final next = !state.sfxEnabled;
    AudioManager().setSfxEnabled(next);
    state = state.copyWith(sfxEnabled: next);
  }

  void toggleMusic() {
    final next = !state.musicEnabled;
    AudioManager().setMusicEnabled(next);
    state = state.copyWith(musicEnabled: next);
  }

  void toggleHaptics() {
    final next = !state.hapticsEnabled;
    HapticManager().setEnabled(next);
    state = state.copyWith(hapticsEnabled: next);
  }

  void toggleColorBlindMode() =>
      state = state.copyWith(colorBlindMode: !state.colorBlindMode);

  void setColorBlindMode({required bool enabled}) =>
      state = state.copyWith(colorBlindMode: enabled);

  void toggleAnalytics() =>
      state = state.copyWith(analyticsEnabled: !state.analyticsEnabled);

  void setAnalyticsEnabled({required bool enabled}) =>
      state = state.copyWith(analyticsEnabled: enabled);

  void setGlooPlus({required bool enabled}) =>
      state = state.copyWith(glooPlus: enabled);

  void setAdsRemoved({required bool removed}) =>
      state = state.copyWith(adsRemoved: removed);
}

final audioSettingsProvider =
    StateNotifierProvider<AudioSettingsNotifier, AudioSettings>(
  (ref) => AudioSettingsNotifier(),
);
