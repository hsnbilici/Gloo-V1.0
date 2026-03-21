import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ─── Tema Modu ──────────────────────────────────────────────────────────

  Future<ThemeMode> getThemeMode() async {
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
}
