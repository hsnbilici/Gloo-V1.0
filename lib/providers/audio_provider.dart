import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_manager.dart';
import '../audio/haptic_manager.dart';
import 'service_providers.dart';

class AppSettings {
  const AppSettings({
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

  AppSettings copyWith({
    bool? sfxEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? colorBlindMode,
    bool? analyticsEnabled,
    bool? glooPlus,
    bool? adsRemoved,
  }) {
    return AppSettings(
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

class AppSettingsNotifier extends Notifier<AppSettings> {
  late final AudioManager _audioManager;
  late final HapticManager _hapticManager;

  @override
  AppSettings build() {
    _audioManager = ref.watch(audioManagerProvider);
    _hapticManager = ref.watch(hapticManagerProvider);
    return const AppSettings();
  }

  void toggleSfx() {
    final next = !state.sfxEnabled;
    _audioManager.setSfxEnabled(next);
    state = state.copyWith(sfxEnabled: next);
  }

  void toggleMusic() {
    final next = !state.musicEnabled;
    _audioManager.setMusicEnabled(next);
    state = state.copyWith(musicEnabled: next);
  }

  void toggleHaptics() {
    final next = !state.hapticsEnabled;
    _hapticManager.setEnabled(next);
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

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
