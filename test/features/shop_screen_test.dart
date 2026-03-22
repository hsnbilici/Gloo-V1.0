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
      await tester.pumpAndSettle();

      expect(find.text('GLOO+'), findsOneWidget);
      expect(find.text('Gloo+'), findsOneWidget);
    });

    testWidgets('shows AD-FREE and JEL OZU sections', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pumpAndSettle();

      expect(find.text('AD-FREE'), findsOneWidget);
      expect(find.text('JEL OZU'), findsOneWidget);
    });

    testWidgets('shows SOUND PACKS section after scrolling', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('SOUND PACKS'), findsOneWidget);
    });

    // flutter_animate widget'ları scroll'da inflate olunca timer başlatır.
    // pump ile animasyonları bitirmeli, birden fazla pump gerekebilir.
    testWidgets('shows redeem code section after scrolling', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Scroll down to reveal redeem code section
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('REDEEM CODE'), findsOneWidget);
      expect(find.text('Redeem'), findsOneWidget);
    });

    testWidgets('shows restore purchases after scrolling', (tester) async {
      await tester.pumpWidget(buildShop());
      await tester.pump(const Duration(seconds: 1));

      // Scroll down to reveal restore purchases link
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Restore Purchases'), findsOneWidget);
    });
  });
}
