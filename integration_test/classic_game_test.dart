import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Classic game E2E', () {
    testWidgets('can start classic game and see grid', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Wait for HomeScreen animations to settle.
      // Using pump(Duration) instead of pumpAndSettle() because
      // flutter_animate causes continuous animations.
      await tester.pump(const Duration(seconds: 2));

      // Verify HomeScreen rendered with Classic mode card.
      expect(find.text('Classic'), findsOneWidget);

      // Tap on Classic mode card.
      await tester.tap(find.text('Classic'));
      await tester.pump(const Duration(seconds: 2));

      // Verify GameScreen loaded — score display should show '0'.
      expect(find.text('0'), findsWidgets);
    });
  });
}
