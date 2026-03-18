import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/network/certificate_pinner.dart';

void main() {
  group('CertificatePinner', () {
    const pinner = CertificatePinner(pins: kCertificatePins);

    test('recognizes supabase domain', () {
      expect(pinner.hasPinsFor('kxrdblgdydixgeruejpc.supabase.co'), isTrue);
    });

    test('recognizes googleapis domain', () {
      expect(pinner.hasPinsFor('firestore.googleapis.com'), isTrue);
    });

    test('returns false for unknown domain', () {
      expect(pinner.hasPinsFor('example.com'), isFalse);
    });

    test('returns correct pins for supabase', () {
      final pins =
          pinner.getPinsFor('kxrdblgdydixgeruejpc.supabase.co');
      expect(pins, isNotNull);
      expect(pins!.length, 2);
      expect(pins[0], 'GU2W4j1P24T3sqlI+o6YTnidzz0PI8fB/Gvd2ITfSZE=');
    });

    test('subdomain lookup works', () {
      expect(pinner.hasPinsFor('storage.googleapis.com'), isTrue);
    });

    test('returns correct pins for googleapis subdomain', () {
      final pins = pinner.getPinsFor('storage.googleapis.com');
      expect(pins, isNotNull);
      expect(pins!.length, 2);
      expect(pins[0], 'UaKBWnoEx6t0je/kqEQQI8mTFKQx23cg3on7tECzBf4=');
    });

    test('getPinsFor returns null for unknown domain', () {
      expect(pinner.getPinsFor('example.com'), isNull);
    });
  });
}
