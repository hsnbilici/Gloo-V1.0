import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app/app.dart';
import 'data/remote/supabase_client.dart';
import 'firebase_options.dart';
import 'services/ad_manager.dart';
import 'services/purchase_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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

    // Widget build hatalarinda kullanici dostu hata ekrani
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
        color: const Color(0xFF010C14), // kBgDark
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Bir hata oluştu',
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
      const ProviderScope(
        child: GlooApp(),
      ),
    );
  }, (error, stack) {
    if (kDebugMode) debugPrint('Uncaught error: $error\n$stack');
  });
}
