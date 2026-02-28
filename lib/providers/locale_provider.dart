import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_strings.dart';

// Desteklenen dil kodları
const _kSupportedLangs = [
  'tr', 'en', 'de', 'zh', 'ja', 'ko', 'ru', 'es', 'ar', 'hi', 'pt', 'fr',
];

/// Cihaz sistem dilini okur; desteklenmiyorsa İngilizce'ye düşer.
/// Kullanıcı ayarlardan dil seçerse [setLocale] ile güncellenir.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_detect());

  static Locale _detect() {
    final sys = PlatformDispatcher.instance.locale.languageCode;
    return Locale(_kSupportedLangs.contains(sys) ? sys : 'en');
  }

  void setLocale(Locale locale) => state = locale;
}

/// Desteklenen dillerin tanım listesi (kod + yerel ad çifti).
const kLanguageOptions = [
  (code: 'tr', nativeName: 'Türkçe'),
  (code: 'en', nativeName: 'English'),
  (code: 'de', nativeName: 'Deutsch'),
  (code: 'zh', nativeName: '中文'),
  (code: 'ja', nativeName: '日本語'),
  (code: 'ko', nativeName: '한국어'),
  (code: 'ru', nativeName: 'Русский'),
  (code: 'es', nativeName: 'Español'),
  (code: 'ar', nativeName: 'العربية'),
  (code: 'hi', nativeName: 'हिन्दी'),
  (code: 'pt', nativeName: 'Português'),
  (code: 'fr', nativeName: 'Français'),
];

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

/// Aktif locale'e karşılık gelen AppStrings implementasyonunu döner.
final stringsProvider = Provider<AppStrings>((ref) {
  return AppStrings.forLocale(ref.watch(localeProvider));
});
