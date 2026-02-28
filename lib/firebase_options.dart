// Bu dosya `flutterfire configure --project=gloo-d3dd8` ile otomatik uretilmelidir.
// Asagidaki placeholder degerler derleme hatasi vermemesi icin konulmustur.
// Firebase projesi kurulduktan sonra `flutterfire configure` calistirilmalidir.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions: $defaultTargetPlatform desteklenmiyor.',
        );
    }
  }

  // TODO: flutterfire configure calistirildiktan sonra bu degerler otomatik dolar.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'gloo-d3dd8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'gloo-d3dd8',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'gloo-d3dd8',
    iosBundleId: 'com.example.gloo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:000000000000:macos:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'gloo-d3dd8',
    iosBundleId: 'com.example.gloo',
  );
}
