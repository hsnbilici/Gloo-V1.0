import 'package:flutter/foundation.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart';

/// Google UMP (User Messaging Platform) consent yöneticisi — singleton.
///
/// AdMob GDPR uyumluluğu için IAB TCF consent string'ini toplar.
/// EEA/UK kullanıcılarına otomatik consent formu gösterir.
/// Web platformunda no-op.
class ConsentService {
  ConsentService._();
  static final ConsentService _instance = ConsentService._();
  factory ConsentService() => _instance;

  bool _initialized = false;
  bool _canShowAds = false;

  /// Reklam gösterilebilir mi? UMP consent durumuna göre.
  bool get canShowAds => _canShowAds;

  /// UMP SDK'yı initialize et ve consent durumunu kontrol et.
  ///
  /// EEA/UK kullanıcılarında consent formu gerekirse [onFormRequired]
  /// callback'i tetiklenir — form gösterimi için çağıran taraf
  /// [showConsentForm] çağırmalıdır.
  Future<void> initialize({bool debugGeography = false}) async {
    if (kIsWeb || _initialized) return;

    try {
      final params = ConsentRequestParameters(
        debugSettings: debugGeography
            ? ConsentDebugSettings(
                geography: DebugGeography.EEA,
              )
            : null,
      );

      final info = await UserMessagingPlatform.instance
          .requestConsentInfoUpdate(params);

      _updateConsentStatus(info.consentStatus);

      if (info.formStatus == FormStatus.available) {
        // EEA/UK kullanıcısı — consent formu gösterilmeli
        await showConsentForm();
      }

      _initialized = true;
      if (kDebugMode) {
        debugPrint(
            'ConsentService: initialized — canShowAds=$_canShowAds, '
            'status=${info.consentStatus}');
      }
    } catch (e) {
      // UMP hatası — güvenli tarafta kal, reklam gösterme
      _canShowAds = false;
      if (kDebugMode) debugPrint('ConsentService: init failed — $e');
    }
  }

  /// Consent formunu göster.
  Future<void> showConsentForm() async {
    if (kIsWeb) return;

    try {
      final info =
          await UserMessagingPlatform.instance.showConsentForm();
      _updateConsentStatus(info.consentStatus);
      if (kDebugMode) {
        debugPrint(
            'ConsentService: form dismissed — status=${info.consentStatus}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('ConsentService: form error — $e');
    }
  }

  /// Consent durumunu güncelle.
  void _updateConsentStatus(ConsentStatus status) {
    _canShowAds = status == ConsentStatus.obtained ||
        status == ConsentStatus.notRequired;
  }

  /// Consent bilgilerini sıfırla (debug/test amaçlı).
  Future<void> reset() async {
    if (kIsWeb) return;
    await UserMessagingPlatform.instance.resetConsentInfo();
    _canShowAds = false;
    _initialized = false;
    if (kDebugMode) debugPrint('ConsentService: reset');
  }
}
