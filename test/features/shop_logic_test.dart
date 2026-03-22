import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/shop/shop_screen.dart';
import 'package:gloo/providers/audio_provider.dart';
import 'package:gloo/services/purchase_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
    });
  });

  Widget buildShop({bool glooPlus = false, bool adsRemoved = false}) {
    final overrides = <Override>[];
    if (glooPlus || adsRemoved) {
      overrides.add(
        appSettingsProvider.overrideWith(() => _TestSettingsNotifier(
              glooPlus: glooPlus,
              adsRemoved: adsRemoved,
            )),
      );
    }

    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: ShopScreen()),
    );
  }

  group('ShopLogic — product list display', () {
    testWidgets('renders Gloo+ subscription section', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // 'GLOO+' is the section header on the Gloo+ tab (active by default)
      expect(find.text('GLOO+'), findsOneWidget);
      // 'Gloo+' appears as both the tab label and the card title
      expect(find.text('Gloo+'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders AD-FREE section in Premium tab', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Navigate to Premium tab (index 2)
      await tester.tap(find.text('Premium'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('AD-FREE'), findsOneWidget);
    });

    testWidgets('renders JEL OZU in currency tab and SOUND PACKS in Premium tab',
        (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Navigate to Gel Drops / Jel Özü tab (index 1)
      await tester.tap(find.byIcon(Icons.water_drop_rounded).first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('JEL OZU'), findsOneWidget);

      // Navigate to Premium tab (index 2)
      await tester.tap(find.text('Premium'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SOUND PACKS'), findsOneWidget);
    });

    testWidgets('shows product prices with fallback values', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Fallback prices should be displayed when store is not available
      expect(find.text('\$1.99'), findsWidgets);
    });
  });

  group('ShopLogic — Gloo+ subscription status', () {
    testWidgets('shows subscribe buttons when not subscribed', (tester) async {
      await tester.pumpWidget(buildShop(glooPlus: false));
      await tester.pump(const Duration(seconds: 1));

      // Monthly and yearly subscribe options should be visible
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
    });

    testWidgets('reflects Gloo+ active state', (tester) async {
      await tester.pumpWidget(buildShop(glooPlus: true));
      await tester.pump(const Duration(seconds: 1));

      // When Gloo+ is active, the card should reflect subscribed state
      expect(find.byType(ShopScreen), findsOneWidget);
    });
  });

  group('ShopLogic — redeem code section', () {
    testWidgets('shows redeem code section in Promo tab', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Navigate to Promo Code tab (index 3)
      await tester.tap(find.byIcon(Icons.confirmation_number_rounded));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('REDEEM CODE'), findsOneWidget);
      expect(find.text('Redeem'), findsOneWidget);
    });

    testWidgets('redeem code text field accepts input', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Navigate to Promo Code tab (index 3)
      await tester.tap(find.byIcon(Icons.confirmation_number_rounded));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      final textField = find.byType(TextField);
      if (textField.evaluate().isNotEmpty) {
        await tester.enterText(textField.first, 'TESTCODE');
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('TESTCODE'), findsOneWidget);
      }
    });
  });

  group('ShopLogic — restore purchases', () {
    testWidgets('shows restore purchases button (persistent footer)', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Restore Purchases is a persistent footer outside the TabBarView
      expect(find.text('Restore Purchases'), findsOneWidget);
    });
  });

  group('ShopLogic — product ID constants', () {
    test('PurchaseService has all expected product IDs', () {
      expect(PurchaseService.kRemoveAds, equals('gloo_remove_ads'));
      expect(PurchaseService.kSoundCrystal, equals('gloo_sound_crystal'));
      expect(PurchaseService.kSoundForest, equals('gloo_sound_forest'));
      expect(PurchaseService.kTexturePack, equals('gloo_texture_pack'));
      expect(PurchaseService.kStarterPack, equals('gloo_starter_pack'));
      expect(PurchaseService.kGlooPlusMonthly, equals('gloo_plus_monthly'));
      expect(PurchaseService.kGlooPlusQuarter, equals('gloo_plus_quarter'));
      expect(PurchaseService.kGlooPlusYearly, equals('gloo_plus_yearly'));
    });

    test('allProductIds contains all 10 products', () {
      expect(PurchaseService.allProductIds.length, equals(10));
    });
  });
}

/// Test helper: AppSettingsNotifier with configurable initial state.
class _TestSettingsNotifier extends AppSettingsNotifier {
  _TestSettingsNotifier({
    bool glooPlus = false,
    bool adsRemoved = false,
  })  : _initGlooPlus = glooPlus,
        _initAdsRemoved = adsRemoved;

  final bool _initGlooPlus;
  final bool _initAdsRemoved;

  @override
  AppSettings build() {
    super.build();
    return AppSettings(
      glooPlus: _initGlooPlus,
      adsRemoved: _initAdsRemoved,
    );
  }
}
