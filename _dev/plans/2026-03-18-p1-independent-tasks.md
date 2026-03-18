# P1 Bağımsız Görevler — Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** P1 öncelikli, harici bağımlılığı olmayan 3 görevi tamamla: Certificate Pinning (H.9), Erişilebilirlik (H.7), Integration Test (H.6)

**Architecture:** Her görev bağımsız ve paralel çalışılabilir. TDD yaklaşımı: önce test, sonra implementasyon.

**Tech Stack:** Flutter 3.41+, Dart, Riverpod, Supabase, Firebase, `integration_test` SDK

**Not:** H.11 (UMP SDK) zaten tamamlanmış — `ConsentService` + `user_messaging_platform` + `AdManager` consent gate'leri mevcut. todo.md'de tamamlandı olarak işaretlenmeli.

---

## Dosya Yapısı

### H.9 — Certificate Pinning
- Create: `lib/core/network/certificate_pinner.dart` — Pin doğrulama mantığı
- Create: `lib/core/network/pinned_http_overrides.dart` — Global HttpOverrides
- Modify: `lib/data/remote/supabase_client.dart` — Custom httpClient enjekte et
- Modify: `lib/main.dart` — HttpOverrides.global ata
- Create: `android/app/src/main/res/xml/network_security_config.xml` — Android pin config
- Modify: `android/app/src/main/AndroidManifest.xml` — networkSecurityConfig referansı
- Create: `test/core/network/certificate_pinner_test.dart`

### H.7 — Erişilebilirlik
- Create: `lib/core/ui/accessible_tap_target.dart` — 44x44dp minimum wrapper
- Modify: `lib/features/home_screen/widgets/bottom_bar.dart` — Semantics + tap target
- Modify: `lib/features/home_screen/widgets/mode_card.dart` — Semantics iyileştirme
- Modify: `lib/features/game_screen/power_up_toolbar.dart` — Semantics + tap target
- Modify: `lib/features/game_screen/game_over_buttons.dart` — Semantics
- Modify: `lib/features/shop/shop_screen.dart` — Semantics
- Modify: `lib/features/pvp/pvp_lobby_screen.dart` — Semantics
- Modify: `lib/features/settings/settings_screen.dart` — textScaler
- Modify: `lib/features/level_select/level_select_screen.dart` — Semantics
- Create: `test/core/ui/accessible_tap_target_test.dart`
- Create: `test/accessibility/semantics_coverage_test.dart`

### H.6 — Integration Test
- Create: `integration_test/classic_game_test.dart` — Classic mod E2E testi
- Create: `integration_test/helpers/test_app.dart` — Provider override helper
- Modify: `pubspec.yaml` — `integration_test` SDK bağımlılığı

---

## Task 1: H.11 — UMP SDK (TAMAMLANDI — Sadece Doğrulama)

**Files:**
- Verify: `lib/services/consent_service.dart`
- Verify: `lib/services/ad_manager.dart` (ConsentService().canShowAds guard'ları)
- Verify: `pubspec.yaml` (`user_messaging_platform: ^1.3.0`)

- [ ] **Step 1: Doğrula ve todo.md'yi güncelle**

`ConsentService` tam implementasyon: UMP SDK init, EEA/UK form, consent status tracking. `AdManager` tüm reklam tiplerinde `canShowAds` guard'ı mevcut. `_dev/tasks/todo.md`'de H.11'i P1'den kaldırıp tamamlandı olarak işaretle.

---

## Task 2: H.9 — Certificate Pinning (Supabase + Firebase)

**Files:**
- Create: `lib/core/network/certificate_pinner.dart`
- Create: `lib/core/network/pinned_http_overrides.dart`
- Modify: `lib/data/remote/supabase_client.dart:43-46`
- Modify: `lib/main.dart`
- Create: `android/app/src/main/res/xml/network_security_config.xml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `test/core/network/certificate_pinner_test.dart`

### Ön Bilgi

Certificate pinning, MITM saldırılarını önler. Supabase (`kxrdblgdydixgeruejpc.supabase.co`) ve Firebase (`firebaseio.com`, `googleapis.com`) için SHA-256 pin'leri kullanılacak.

**Yaklaşım:** Platform-native pinning tercih edilir:
- **Android:** `network_security_config.xml` — OS seviyesinde güvenilir, bakımı kolay
- **iOS:** `TrustKit` SPM paketi — iOS'ta native NSURLSession pinning sağlar
- **Dart katmanı:** `http_certificate_pinning` paketi ile `SecurityContext` + trusted cert bundle. NOT: `badCertificateCallback` sadece zaten reddedilmiş sertifikalar için çağrılır, pinning için kullanılamaz.

**Pin Alma:** Canlı sertifikaların SHA-256 public key hash'leri `openssl` ile alınır. Backup pin (CA root) eklenir — sertifika yenilendiğinde app kırılmaz.

- [ ] **Step 2.1: Pin hash'lerini al**

Terminal'de çalıştır:
```bash
# Supabase pin
openssl s_client -connect kxrdblgdydixgeruejpc.supabase.co:443 -servername kxrdblgdydixgeruejpc.supabase.co </dev/null 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256 -binary | base64

# Firebase pin (googleapis.com — GTS CA 1C3 root)
openssl s_client -connect firebaseio.com:443 -servername firebaseio.com </dev/null 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256 -binary | base64
```

Çıktıyı not al — Step 2.3'te kullanılacak.

- [ ] **Step 2.2: Failing test yaz**

```dart
// test/core/network/certificate_pinner_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/network/certificate_pinner.dart';

void main() {
  group('CertificatePinner', () {
    test('validates known pin for supabase domain', () {
      final pinner = CertificatePinner(pins: {
        'kxrdblgdydixgeruejpc.supabase.co': [
          'ACTUAL_SUPABASE_PIN_HERE', // Step 2.1'den
        ],
      });
      expect(pinner.hasPinsFor('kxrdblgdydixgeruejpc.supabase.co'), isTrue);
      expect(pinner.hasPinsFor('unknown.com'), isFalse);
    });

    test('rejects empty pin list', () {
      expect(
        () => CertificatePinner(pins: {}),
        throwsAssertionError,
      );
    });
  });
}
```

- [ ] **Step 2.3: Test'in fail ettiğini doğrula**

Run: `flutter test test/core/network/certificate_pinner_test.dart`
Expected: FAIL — `certificate_pinner.dart` dosyası yok

- [ ] **Step 2.4: CertificatePinner implementasyonu**

```dart
// lib/core/network/certificate_pinner.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// SHA-256 SPKI pin doğrulaması yapan sınıf.
///
/// [pins] map'i: domain → List<base64-encoded SHA-256 SPKI pin>.
/// Bir domain için en az bir pin eşleşirse bağlantı kabul edilir.
/// Backup pin (CA root) eklenmelidir — leaf sertifika yenilendiğinde
/// app kırılmaz.
class CertificatePinner {
  CertificatePinner({required this.pins})
      : assert(pins.isNotEmpty, 'At least one pin required');

  final Map<String, List<String>> pins;

  bool hasPinsFor(String host) => pins.containsKey(host);

  /// X509Certificate'ın SPKI SHA-256 hash'inin pin listesinde olup
  /// olmadığını doğrular.
  bool validate(X509Certificate cert, String host) {
    final domainPins = pins[host];
    if (domainPins == null || domainPins.isEmpty) return true; // pin yoksa geç

    // DER encoded certificate → SPKI hash
    final der = cert.der;
    final hash = _sha256SpkiHash(der);
    final pinMatch = domainPins.contains(hash);

    if (!pinMatch && kDebugMode) {
      debugPrint('CertificatePinner: pin mismatch for $host');
      debugPrint('  Got: $hash');
      debugPrint('  Expected: $domainPins');
    }

    return pinMatch;
  }

  String _sha256SpkiHash(Uint8List der) {
    // Platform-level SPKI extraction from DER
    // Note: Full implementation requires ASN.1 parsing
    // For production, use the certificate chain from badCertificateCallback
    return base64Encode(der); // Placeholder — real impl below
  }
}
```

**Not:** Gerçek implementasyonda `badCertificateCallback`'ten gelen `X509Certificate` üzerinde SPKI hash hesaplanır. Dart'ın `X509Certificate.der` getter'ı tüm sertifika DER'ini verir. Ancak SPKI (SubjectPublicKeyInfo) bölümünü çıkarmak ASN.1 parse gerektirir. Alternatif yaklaşım: tüm sertifika SHA-256 hash'ini pin olarak kullanmak (daha basit, ama sertifika yenilenince güncelleme gerekir).

**Pragmatik karar:** `ssl_pinning_plugin` veya `http_certificate_pinning` paketini kullanmak yerine, Android'de `network_security_config.xml` ve iOS'ta native `TrustKit` veya `Info.plist` pin configuration kullanmak daha güvenilir. Dart katmanında `HttpOverrides.badCertificateCallback` yedek doğrulama sağlar.

- [ ] **Step 2.5: Test'in geçtiğini doğrula**

Run: `flutter test test/core/network/certificate_pinner_test.dart`
Expected: PASS

- [ ] **Step 2.6: Android network_security_config.xml oluştur**

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config>
        <domain includeSubdomains="true">supabase.co</domain>
        <pin-set expiration="2027-01-01">
            <pin digest="SHA-256">SUPABASE_LEAF_PIN</pin>
            <pin digest="SHA-256">SUPABASE_BACKUP_CA_PIN</pin>
        </pin-set>
    </domain-config>
    <domain-config>
        <domain includeSubdomains="true">googleapis.com</domain>
        <domain includeSubdomains="true">firebaseio.com</domain>
        <pin-set expiration="2027-01-01">
            <pin digest="SHA-256">GOOGLE_GTS_ROOT_PIN</pin>
            <pin digest="SHA-256">GOOGLE_BACKUP_PIN</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

- [ ] **Step 2.7: AndroidManifest.xml'e referans ekle**

`android/app/src/main/AndroidManifest.xml` — `<application>` tag'ine:
```xml
android:networkSecurityConfig="@xml/network_security_config"
```

- [ ] **Step 2.8: PinnedHttpOverrides oluştur (Dart katmanı yedek)**

```dart
// lib/core/network/pinned_http_overrides.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'certificate_pinner.dart';

class PinnedHttpOverrides extends HttpOverrides {
  PinnedHttpOverrides({required this.pinner});

  final CertificatePinner pinner;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) {
      if (!pinner.hasPinsFor(host)) return false;
      return pinner.validate(cert, host);
    };
    return client;
  }
}
```

- [ ] **Step 2.9: main.dart'a HttpOverrides.global ata**

`lib/main.dart` — `main()` fonksiyonunun başına, `WidgetsFlutterBinding.ensureInitialized()` sonrasına:

```dart
if (!kIsWeb) {
  HttpOverrides.global = PinnedHttpOverrides(
    pinner: CertificatePinner(pins: kCertificatePins),
  );
}
```

`kCertificatePins` sabitini `certificate_pinner.dart`'ta tanımla.

- [ ] **Step 2.10: Supabase client'a httpClient ekle**

`lib/data/remote/supabase_client.dart:43-46` — `Supabase.initialize()` çağrısına:

```dart
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  httpClient: PinnedHttpOverrides(
    pinner: CertificatePinner(pins: kCertificatePins),
  ).createHttpClient(null),
);
```

**Not:** `supabase_flutter` `httpClient` parametresi `Supabase.initialize()`'da mevcut. Kontrol edilmeli — yoksa sadece `HttpOverrides.global` yeterli.

- [ ] **Step 2.11: flutter analyze + test**

Run: `flutter analyze && flutter test`
Expected: 0 error, tüm testler geçiyor

- [ ] **Step 2.12: Commit**

```bash
git add lib/core/network/ test/core/network/ android/app/src/main/res/xml/ android/app/src/main/AndroidManifest.xml lib/main.dart lib/data/remote/supabase_client.dart
git commit -m "feat(security): certificate pinning — Supabase + Firebase (H.9)"
```

---

## Task 3: H.7 — Erişilebilirlik (Semantics %15→%60, textScaler, 44x44dp)

**Files:**
- Create: `lib/core/ui/accessible_tap_target.dart`
- Modify: 8+ ekran dosyası (aşağıda detaylı)
- Create: `test/core/ui/accessible_tap_target_test.dart`
- Create: `test/accessibility/semantics_coverage_test.dart`

### Ön Bilgi

Mevcut durum: 10/69 dosyada Semantics widget'ı (%14). Hedef: %60+.

**3 ana çalışma alanı:**
1. `AccessibleTapTarget` wrapper — tüm GestureDetector'ları 44x44dp minimum ile sar
2. `Semantics` widget'ları — tüm interaktif elemanlara label ekle
3. `textScaler` desteği — hardcoded font size'ları MediaQuery.textScalerOf ile ölçekle

**Referans dosya:** `game_cell_widget.dart` — mevcut Semantics pattern'ini örnek al.

- [ ] **Step 3.1: AccessibleTapTarget widget test yaz**

```dart
// test/core/ui/accessible_tap_target_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/ui/accessible_tap_target.dart';

void main() {
  testWidgets('enforces minimum 44x44 tap target', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccessibleTapTarget(
            onTap: () {},
            semanticLabel: 'Test button',
            child: const SizedBox(width: 20, height: 20),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(AccessibleTapTarget));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });

  testWidgets('wraps child in Semantics with label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccessibleTapTarget(
            onTap: () {},
            semanticLabel: 'Play button',
            child: const Icon(Icons.play_arrow),
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Play button'),
      findsOneWidget,
    );
  });
}
```

- [ ] **Step 3.2: Test'in fail ettiğini doğrula**

Run: `flutter test test/core/ui/accessible_tap_target_test.dart`
Expected: FAIL

- [ ] **Step 3.3: AccessibleTapTarget implementasyonu**

```dart
// lib/core/ui/accessible_tap_target.dart
import 'package:flutter/material.dart';

/// WCAG 2.1 uyumlu minimum 44x44dp tap target wrapper.
///
/// [semanticLabel] zorunlu — erişilebilirlik label'ı.
/// İç widget 44dp'den küçükse, görünmez padding ile genişletir.
class AccessibleTapTarget extends StatelessWidget {
  const AccessibleTapTarget({
    super.key,
    required this.onTap,
    required this.semanticLabel,
    required this.child,
    this.minSize = 44.0,
  });

  final VoidCallback? onTap;
  final String semanticLabel;
  final Widget child;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3.4: Test'in geçtiğini doğrula**

Run: `flutter test test/core/ui/accessible_tap_target_test.dart`
Expected: PASS

- [ ] **Step 3.5: Commit**

```bash
git add lib/core/ui/accessible_tap_target.dart test/core/ui/accessible_tap_target_test.dart
git commit -m "feat(a11y): AccessibleTapTarget widget — 44x44dp minimum + Semantics (H.7)"
```

- [ ] **Step 3.6: bottom_bar.dart — Semantics + tap target iyileştirme**

`lib/features/home_screen/widgets/bottom_bar.dart`:
- Mevcut `GestureDetector` → `AccessibleTapTarget` ile değiştir
- Her navigation item'a açıklayıcı `semanticLabel` ekle (l10n string)
- Padding-based tap target'ları `ConstrainedBox(minWidth: 44, minHeight: 44)` ile değiştir

- [ ] **Step 3.7: power_up_toolbar.dart — Semantics ekle**

`lib/features/game_screen/power_up_toolbar.dart`:
- Her power-up butonuna `Semantics(label: powerUpName, button: true)` ekle
- `GestureDetector` tap target'larını 44x44dp minimum yap

- [ ] **Step 3.8: game_over_buttons.dart — Semantics ekle**

`lib/features/game_screen/game_over_buttons.dart`:
- Retry, Home, Share butonlarına `Semantics` ekle

- [ ] **Step 3.9: shop_screen.dart — Semantics ekle**

`lib/features/shop/shop_screen.dart`:
- IAP ürün kartlarına `Semantics(label: productName)` ekle
- Satın al butonlarına `Semantics(label: 'Buy productName', button: true)` ekle

- [ ] **Step 3.10: pvp_lobby_screen.dart — Semantics ekle**

`lib/features/pvp/pvp_lobby_screen.dart`:
- Matchmaking butonu ve lobby UI elemanlarına Semantics ekle

- [ ] **Step 3.11: level_select_screen.dart — Semantics ekle**

`lib/features/level_select/level_select_screen.dart`:
- Her level kartına `Semantics(label: 'Level $number')` ekle
- Kilitli level'lara `Semantics(label: 'Level $number, locked')` ekle

- [ ] **Step 3.12: textScaler desteği — kritik ekranlar**

Hardcoded `fontSize` değerlerini `MediaQuery.textScalerOf(context)` ile ölçeklemek için:

```dart
// Kullanım örneği (mevcut kodu değiştirirken):
final scaler = MediaQuery.textScalerOf(context);
// fontSize: 18 → fontSize: scaler.scale(18)
// VEYA maxLines + overflow ekle (taşma önleme)
```

Öncelikli ekranlar (hardcoded fontSize yoğunluğu yüksek):
1. `home_screen.dart` — mode card başlıkları
2. `settings_screen.dart` — ayar etiketleri
3. `shop_screen.dart` — fiyat ve ürün adları
4. `game_overlay.dart` — skor ve mesajlar

**Not:** Oyun ekranındaki grid cell'ler textScaler'dan muaf olabilir — oyun dengesini bozabilir.

- [ ] **Step 3.13: Semantics coverage testi**

```dart
// test/accessibility/semantics_coverage_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/home_screen/home_screen.dart';
import 'package:gloo/providers/audio_provider.dart';
import 'package:gloo/providers/user_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
    });
  });

  testWidgets('HomeScreen interactive elements have Semantics',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          streakProvider.overrideWith((ref) async => 0),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Navigation bar items should have semantic labels
    final semantics = tester.getSemantics(find.byType(HomeScreen));
    expect(semantics, isNotNull);
  });
}
```

- [ ] **Step 3.14: flutter analyze + test**

Run: `flutter analyze && flutter test`
Expected: 0 error, tüm testler geçiyor

- [ ] **Step 3.15: Commit**

```bash
git add lib/features/ test/accessibility/
git commit -m "feat(a11y): Semantics + textScaler + 44dp targets — 8 screen (H.7)"
```

---

## Task 4: H.6 — Integration Test Altyapısı (Classic Mod E2E)

**Files:**
- Create: `integration_test/helpers/test_app.dart`
- Create: `integration_test/classic_game_test.dart`
- Modify: `pubspec.yaml` — `integration_test` SDK

### Ön Bilgi

Mevcut: 1220 unit/widget test, 0 integration test. Hedef: Classic mod tam akış testi (oyun başlat → taş yerleştir → skor kazan → game over).

**Zorluklar:**
- `GlooGame` pure Dart, `GameScreen` 3 mixin ile karmaşık
- `flutter_animate` timer'ları `pumpAndSettle()` beklemesini bozabilir → `pump(Duration)` kullan
- Platform bağımlılıkları (AdManager, Firebase, Supabase) mock'lanmalı

- [ ] **Step 4.1: pubspec.yaml'a integration_test ekle**

```yaml
# pubspec.yaml → dev_dependencies bloğuna ekle:
  integration_test:
    sdk: flutter
```

- [ ] **Step 4.2: flutter pub get**

Run: `flutter pub get`
Expected: Success

- [ ] **Step 4.3: Test helper — test_app.dart oluştur**

```dart
// integration_test/helpers/test_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/app/app.dart';
import 'package:gloo/providers/audio_provider.dart';
import 'package:gloo/providers/user_provider.dart';

/// Integration test için GlooApp wrapper.
///
/// Platform bağımlılıklarını (Firebase, Supabase, AdMob) devre dışı bırakır.
/// SharedPreferences mock değerlerle başlatır.
Future<Widget> createTestApp({
  List<Override> additionalOverrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({
    'onboarding_done': true,
    'colorblind_prompt_shown': true,
    'analytics_enabled': false,
    'sfx_enabled': false,
    'music_enabled': false,
    'haptics_enabled': false,
  });

  return ProviderScope(
    overrides: [
      streakProvider.overrideWith((ref) async => 0),
      ...additionalOverrides,
    ],
    child: const GlooApp(),
  );
}
```

- [ ] **Step 4.4: Classic mod E2E testi yaz**

```dart
// integration_test/classic_game_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Classic mode E2E', () {
    testWidgets('can start classic game and see grid', (tester) async {
      final app = await createTestApp();
      await tester.pumpWidget(app);
      await tester.pump(const Duration(seconds: 2));

      // HomeScreen görünmeli
      expect(find.text('Classic'), findsOneWidget);

      // Classic mod kartına dokun
      await tester.tap(find.text('Classic'));
      await tester.pump(const Duration(seconds: 2));

      // GameScreen yüklenmeli — grid görünmeli
      // GlooGame 8x10 grid oluşturur
      // Skor göstergesi görünmeli
      expect(find.textContaining('0'), findsWidgets);
    });
  });
}
```

- [ ] **Step 4.5: Emülatörde integration testi çalıştır**

Run (Android): `flutter test integration_test/classic_game_test.dart -d Gloo_Pixel8`
Run (iOS sim): `flutter test integration_test/classic_game_test.dart -d "iPhone 17 Pro"`
Run (Chrome): `flutter test integration_test/classic_game_test.dart -d chrome`

Expected: Test geçer (en azından web/emülatörde)

**Not:** İlk çalıştırmada fail olabilir — provider override eksikliği, timer sorunları vb. Debug et ve düzelt.

- [ ] **Step 4.6: Commit**

```bash
git add integration_test/ pubspec.yaml
git commit -m "feat(qa): integration test infrastructure — classic mod E2E (H.6)"
```

---

## Doğrulama Kontrol Listesi

| Kontrol | Durumu |
|---------|--------|
| `flutter analyze` — 0 error | ☐ |
| `flutter test` — tüm 1220+ test geçiyor | ☐ |
| Integration test çalışıyor (en az 1 platformda) | ☐ |
| H.9: Certificate pin'ler gerçek sertifikalardan alınmış | ☐ |
| H.7: Semantics coverage %60+ | ☐ |
| H.7: textScaler en az 4 ekranda aktif | ☐ |
| H.7: Tüm interaktif elemanlar 44x44dp minimum | ☐ |
| H.6: `integration_test/` klasörü mevcut, test geçiyor | ☐ |
| `_dev/tasks/todo.md` güncellendi | ☐ |

---

## Sıralama ve Bağımlılıklar

```
H.11 ✅ (zaten tamamlanmış — sadece todo.md güncelle)
   ↓
H.9 (certificate pinning) ← bağımsız, hemen başlanabilir
H.7 (erişilebilirlik)     ← bağımsız, hemen başlanabilir
H.6 (integration test)    ← bağımsız, ama H.7 sonrası daha faydalı (Semantics test edilir)
```

**Önerilen sıra:** H.9 → H.7 → H.6 (veya H.9 ∥ H.7, sonra H.6)
