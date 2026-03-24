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

import 'app/app.dart';
import 'core/constants/color_constants.dart';
import 'core/l10n/app_strings.dart';
import 'core/network/certificate_pinner.dart';
import 'core/network/pinned_http_overrides.dart';
import 'firebase_options.dart';

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

    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    // iOS immersiveSticky tam desteklemez — edgeToEdge kullan
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    FlutterNativeSplash.remove();

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
        child: const GlooApp(),
      ),
    );
  }, (error, stack) {
    if (kDebugMode) debugPrint('Uncaught error: $error\n$stack');
  });
}
