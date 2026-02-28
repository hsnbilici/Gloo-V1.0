import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app/app.dart';
import 'data/remote/supabase_client.dart';
import 'firebase_options.dart';
import 'services/ad_manager.dart';
import 'services/purchase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Crashlytics: yakalanmamis Flutter hatalarini raporla
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Supabase backend init (sahte anahtarlar varsa sessizce atlar)
  await SupabaseConfig.initialize();

  // AdMob init (web'de no-op)
  if (!kIsWeb) {
    await AdManager().initialize();
  }

  // IAP init (web'de no-op)
  if (!kIsWeb) {
    await PurchaseService().initialize();
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // iOS immersiveSticky tam desteklemez — edgeToEdge kullan
  if (!kIsWeb && Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } else {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  runApp(
    const ProviderScope(
      child: GlooApp(),
    ),
  );
}
