import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
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

  // Firebase init (placeholder anahtarlar varsa sessizce atlar)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (_) {
    // Firebase henuz yapilandirilmamis — uygulama calismaya devam eder
  }

  // Supabase, AdMob, IAP birbirinden bagimsiz — paralel baslatma
  await Future.wait([
    SupabaseConfig.initialize(),
    if (!kIsWeb) AdManager().initialize(),
    if (!kIsWeb) PurchaseService().initialize(),
  ]);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // iOS immersiveSticky tam desteklemez — edgeToEdge kullan
  if (!kIsWeb && Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } else {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: GlooApp(),
    ),
  );
}
