import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/constants/color_constants.dart';
import 'core/l10n/app_strings.dart';
import 'core/network/certificate_pinner.dart';
import 'core/network/pinned_http_overrides.dart';
import 'data/local/local_repository.dart';
import 'data/remote/supabase_client.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'services/ad_manager.dart';
import 'services/consent_service.dart';
import 'services/purchase_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Certificate pinning — Android'de network_security_config.xml ile,
  // Dart katmaninda ek guvenlik olarak badCertificateCallback ile
  if (!kIsWeb) {
    HttpOverrides.global = PinnedHttpOverrides(
      pinner: const CertificatePinner(pins: kCertificatePins),
    );
  }

  runZonedGuarded(() async {
    // Fallback hata yakalayici — Firebase basarisiz olsa bile aktif
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };

    // Firebase init (placeholder anahtarlar varsa sessizce atlar)
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      if (!kIsWeb) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: kDebugMode
              ? AndroidProvider.debug
              : AndroidProvider.playIntegrity,
          appleProvider:
              kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
        );
      }
    } catch (_) {
      // Firebase henuz yapilandirilmamis — uygulama calismaya devam eder
    }

    // UMP consent — AdMob'dan önce çalışmalı (EEA/UK GDPR zorunluluğu)
    if (!kIsWeb) {
      try {
        await ConsentService().initialize();
      } catch (_) {
        // UMP hatası — uygulama çalışmaya devam eder
      }
    }

    // Supabase, AdMob, IAP birbirinden bagimsiz — paralel baslatma
    try {
      await Future.wait([
        SupabaseConfig.initialize(),
        if (!kIsWeb) AdManager().initialize(),
        if (!kIsWeb) PurchaseService().initialize(),
      ]);
    } catch (_) {
      // Ag baglantisi yok veya servis down — uygulama calismaya devam eder
    }

    // Onceki oturumdan kalan dogrulanamamis IAP'leri yeniden dogrula
    // ve suresi dolmus abonelikleri temizle
    if (!kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final localRepo = LocalRepository(prefs);
        await PurchaseService().loadPendingVerifications(localRepo);
        await PurchaseService().syncLocalProducts(localRepo);
        await AdManager().restoreDailyCaps(prefs);
      } catch (_) {
        // Network hatasi — sonraki baslatmada tekrar denenir
      }
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // iOS immersiveSticky tam desteklemez — edgeToEdge kullan
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    FlutterNativeSplash.remove();

    // Kalici tema modunu runApp oncesi yukle — sistem temasina geri donusu onler
    ThemeMode savedThemeMode = ThemeMode.dark;
    try {
      final prefs = await SharedPreferences.getInstance();
      savedThemeMode = await LocalRepository(prefs).getThemeMode();
    } catch (_) {
      // Okuma basarisiz — varsayilan karanlik temaya devam et
    }

    // Widget build hatalarinda kullanici dostu hata ekrani
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
        color: kBgDark,
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              AppStrings.forLocale(PlatformDispatcher.instance.locale)
                  .errorOccurred,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
              textDirection: TextDirection.ltr,
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              Text(
                details.exceptionAsString(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
                textDirection: TextDirection.ltr,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      );
    };

    runApp(
      ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(
            () => ThemeModeNotifier(savedThemeMode),
          ),
        ],
        child: const GlooApp(),
      ),
    );
  }, (error, stack) {
    if (kDebugMode) debugPrint('Uncaught error: $error\n$stack');
  });
}
