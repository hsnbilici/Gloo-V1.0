import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/shop/shop_screen.dart';
import 'package:gloo/providers/audio_provider.dart';

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
        appSettingsProvider.overrideWith(() => AppSettingsNotifier()),
      );
    }

    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: ShopScreen()),
    );
  }

  group('ShopScreen', () {
    testWidgets('renders screen without errors', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pumpAndSettle();

      expect(find.byType(ShopScreen), findsOneWidget);
    });

    testWidgets('shows shop title and back button', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pumpAndSettle();

      expect(find.text('Shop'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows Gloo+ subscription section', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // 'GLOO+' is the section header on the Gloo+ tab (active by default)
      expect(find.text('GLOO+'), findsOneWidget);
      // 'Gloo+' appears as both the tab label and the card title
      expect(find.text('Gloo+'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows AD-FREE section in Premium tab', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Navigate to Premium tab (index 2)
      await tester.tap(find.text('Premium'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('AD-FREE'), findsOneWidget);
    });

    testWidgets('shows JEL OZU section in currency tab', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Navigate to Gel Drops / Jel Özü tab (index 1)
      await tester.tap(find.byIcon(Icons.water_drop_rounded).first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('JEL OZU'), findsOneWidget);
    });

    testWidgets('shows SOUND PACKS section in Premium tab', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Navigate to Premium tab (index 2)
      await tester.tap(find.text('Premium'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SOUND PACKS'), findsOneWidget);
    });

    // flutter_animate widget'ları inflate olunca timer başlatır.
    // pump ile animasyonları bitirmeli.
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

    testWidgets('shows restore purchases button (persistent footer)', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Restore Purchases is a persistent footer outside the TabBarView
      expect(find.text('Restore Purchases'), findsOneWidget);
    });
  });
}
