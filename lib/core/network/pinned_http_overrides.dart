import 'dart:io';

import 'package:flutter/foundation.dart';

import 'certificate_pinner.dart';

/// Dart katmani certificate dogrulama — Android native pinning'e ek guvenlik.
///
/// NOT: `badCertificateCallback` yalnizca zaten reddedilmis sertifikalar
/// icin tetiklenir. Aktif pinning Android'de `network_security_config.xml`,
/// iOS'ta ATS tarafindan saglanir. Bu sinif ek bir guvenlik katmanidir.
class PinnedHttpOverrides extends HttpOverrides {
  PinnedHttpOverrides({required this.pinner});

  final CertificatePinner pinner;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      // Pinned domain'lere yapilan baglantilarda kotu sertifika
      // kesinlikle reddedilmeli
      if (pinner.hasPinsFor(host)) {
        if (kDebugMode) {
          debugPrint(
            'PinnedHttpOverrides: BAD certificate rejected for pinned domain $host',
          );
        }
        return false; // Reject — pinned domain'de kotu sertifika kabul edilmez
      }
      // Pin tanimsiz domain — varsayilan davranis (reject)
      return false;
    };
    return client;
  }
}
