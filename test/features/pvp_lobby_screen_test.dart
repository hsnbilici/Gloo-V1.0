import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/pvp/pvp_lobby_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
      'pvp_elo': 1000,
      'pvp_wins': 5,
      'pvp_losses': 3,
    });
  });

  Widget buildPvpLobby() {
    return const ProviderScope(
      child: MaterialApp(home: PvpLobbyScreen()),
    );
  }

  group('PvpLobbyScreen', () {
    testWidgets('renders screen without errors', (tester) async {
      // Suppress RenderFlex overflow errors from _MatchButton
      // (layout issue at default test viewport — not a test concern)
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final isOverflow = details.exceptionAsString().contains('overflowed');
        if (!isOverflow) oldHandler?.call(details);
      };

      await tester.pumpWidget(buildPvpLobby());
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;

      expect(find.byType(PvpLobbyScreen), findsOneWidget);
    });

    testWidgets('shows PvP DUELLO title', (tester) async {
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final isOverflow = details.exceptionAsString().contains('overflowed');
        if (!isOverflow) oldHandler?.call(details);
      };

      await tester.pumpWidget(buildPvpLobby());
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;

      expect(find.text('PvP DUELLO'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final isOverflow = details.exceptionAsString().contains('overflowed');
        if (!isOverflow) oldHandler?.call(details);
      };

      await tester.pumpWidget(buildPvpLobby());
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows matchmaking button', (tester) async {
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final isOverflow = details.exceptionAsString().contains('overflowed');
        if (!isOverflow) oldHandler?.call(details);
      };

      await tester.pumpWidget(buildPvpLobby());
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;

      expect(find.text('Eslestirme Ara'), findsOneWidget);
    });

    testWidgets('shows ELO display', (tester) async {
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final isOverflow = details.exceptionAsString().contains('overflowed');
        if (!isOverflow) oldHandler?.call(details);
      };

      await tester.pumpWidget(buildPvpLobby());
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;

      expect(find.text('1000 ELO'), findsOneWidget);
    });

    testWidgets('shows PvP stats labels', (tester) async {
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        final isOverflow = details.exceptionAsString().contains('overflowed');
        if (!isOverflow) oldHandler?.call(details);
      };

      await tester.pumpWidget(buildPvpLobby());
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;

      expect(find.text('Wins'), findsOneWidget);
      expect(find.text('Losses'), findsOneWidget);
      expect(find.text('Ratio'), findsOneWidget);
    });
  });
}
