import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/audio_constants.dart';

/// Tema, yerel ayar, ses, analitik, onboarding ve renk körlüğü ayarlarını yönetir.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  bool getOnboardingDone() => _prefs.getBool('onboarding_done') ?? false;

  Future<void> setOnboardingDone() async {
    await _prefs.setBool('onboarding_done', true);
  }

  bool getColorblindPromptShown() =>
      _prefs.getBool('colorblind_prompt_shown') ?? false;

  Future<void> setColorblindPromptShown() async {
    await _prefs.setBool('colorblind_prompt_shown', true);
  }

  // ─── Gizlilik & Analitik ───────────────────────────────────────────────

  bool getAnalyticsEnabled() => _prefs.getBool('analytics_enabled') ?? false;

  Future<void> setAnalyticsEnabled(bool value) async {
    await _prefs.setBool('analytics_enabled', value);
  }

  bool getConsentShown() => _prefs.getBool('consent_shown') ?? false;

  Future<void> setConsentShown() async {
    await _prefs.setBool('consent_shown', true);
  }

  // ─── Bildirimler ───────────────────────────────────────────────────────

  bool getNotificationsEnabled() =>
      _prefs.getBool('notifications_enabled') ?? true;

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool('notifications_enabled', value);
  }

  // ─── İpucu Gösterim Sayısı ──────────────────────────────────────────────

  int getTipShownCount(String tipKey) =>
      _prefs.getInt('tip_shown_$tipKey') ?? 0;

  Future<void> incrementTipShown(String tipKey) async {
    final count = getTipShownCount(tipKey);
    await _prefs.setInt('tip_shown_$tipKey', count + 1);
  }

  // ─── Tema Modu ──────────────────────────────────────────────────────────

  ThemeMode getThemeMode() {
    final value = _prefs.getString('theme_mode');
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString('theme_mode', mode.name);
  }

  // ─── Ses Paketi ─────────────────────────────────────────────────────────────

  AudioPackage getAudioPackage() {
    final value = _prefs.getString('audio_package');
    return AudioPackage.values.firstWhere(
      (p) => p.name == value,
      orElse: () => AudioPackage.standard,
    );
  }

  Future<void> saveAudioPackage(AudioPackage package) async {
    await _prefs.setString('audio_package', package.name);
  }

  // ─── Beceri Profili ───────────────────────────────────────────────────

  String? getSkillProfileJson() => _prefs.getString('skill_profile');

  Future<void> saveSkillProfileJson(String json) =>
      _prefs.setString('skill_profile', json);
}
