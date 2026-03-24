import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gloo/app/router.dart';
import 'package:gloo/game/world/game_world.dart';

/// Extract the flat list of [GoRoute] objects from the router provider.
List<GoRoute> _extractRoutes() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final router = container.read(routerProvider);
  return router.configuration.routes.whereType<GoRoute>().toList();
}

/// Build a GoRouter whose every route renders a [Text] widget showing which
/// path pattern matched. This avoids pulling in real screens (which need many
/// providers) while still exercising GoRouter's own path-matching logic.
GoRouter _buildProbeRouter() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final realRouter = container.read(routerProvider);

  // Mirror every real GoRoute but replace the builder with a simple Text.
  List<GoRoute> cloneRoutes(List<RouteBase> originals) {
    return originals.whereType<GoRoute>().map((r) {
      return GoRoute(
        path: r.path,
        builder: (context, state) => Text(
          'matched:${r.path}',
          textDirection: TextDirection.ltr,
        ),
        routes: cloneRoutes(r.routes),
      );
    }).toList();
  }

  return GoRouter(
    initialLocation: '/',
    routes: cloneRoutes(realRouter.configuration.routes),
  );
}

void main() {
  // ─────────────────────────────────────────────
  // Existing tests — untouched
  // ─────────────────────────────────────────────
  group('GameMode.fromString', () {
    test('parses classic', () {
      expect(GameMode.fromString('classic'), GameMode.classic);
    });

    test('parses colorChef', () {
      expect(GameMode.fromString('colorChef'), GameMode.colorChef);
    });

    test('parses timeTrial', () {
      expect(GameMode.fromString('timeTrial'), GameMode.timeTrial);
    });

    test('parses zen', () {
      expect(GameMode.fromString('zen'), GameMode.zen);
    });

    test('parses daily', () {
      expect(GameMode.fromString('daily'), GameMode.daily);
    });

    test('parses level', () {
      expect(GameMode.fromString('level'), GameMode.level);
    });

    test('parses duel', () {
      expect(GameMode.fromString('duel'), GameMode.duel);
    });

    test('unknown mode falls back to classic', () {
      expect(GameMode.fromString('unknown'), GameMode.classic);
    });

    test('empty string falls back to classic', () {
      expect(GameMode.fromString(''), GameMode.classic);
    });

    test('case-sensitive — Classic is not valid', () {
      expect(GameMode.fromString('Classic'), GameMode.classic);
    });
  });

  group('GameMode enum', () {
    test('has exactly 7 modes', () {
      expect(GameMode.values.length, 7);
    });

    test('all modes have unique names', () {
      final names = GameMode.values.map((m) => m.name).toSet();
      expect(names.length, GameMode.values.length);
    });
  });

  // ─────────────────────────────────────────────
  // New tests: Route configuration
  // ─────────────────────────────────────────────
  group('Route configuration', () {
    test('router defines exactly 18 top-level routes', () {
      final routes = _extractRoutes();
      expect(routes.length, 18);
    });

    test('all expected paths are present', () {
      final routes = _extractRoutes();
      final paths = routes.map((r) => r.path).toSet();

      const expectedPaths = <String>{
        '/loading',
        '/',
        '/onboarding',
        '/levels',
        '/pvp-lobby',
        '/game/level/:levelId',
        '/game/duel',
        '/game/:mode',
        '/daily',
        '/shop',
        '/leaderboard',
        '/settings',
        '/collection',
        '/island',
        '/character',
        '/season-pass',
        '/friends',
        '/friend/:code',
      };

      for (final path in expectedPaths) {
        expect(paths, contains(path), reason: 'Missing route: $path');
      }
    });

    test('no duplicate paths', () {
      final routes = _extractRoutes();
      final paths = routes.map((r) => r.path).toList();
      expect(paths.length, paths.toSet().length,
          reason: 'Duplicate route paths found');
    });

    test('initial location is /loading', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);
      // GoRouter navigates to initialLocation on creation
      expect(
        router.routeInformationProvider.value.uri.path,
        '/loading',
      );
    });
  });

  // ─────────────────────────────────────────────
  // New tests: Route priority (CRITICAL per CLAUDE.md)
  // ─────────────────────────────────────────────
  group('Route priority — specific before generic', () {
    test('/game/level/:levelId is defined before /game/:mode', () {
      final routes = _extractRoutes();
      final paths = routes.map((r) => r.path).toList();

      final levelIndex = paths.indexOf('/game/level/:levelId');
      final genericIndex = paths.indexOf('/game/:mode');

      expect(levelIndex, isNot(-1), reason: '/game/level/:levelId must exist');
      expect(genericIndex, isNot(-1), reason: '/game/:mode must exist');
      expect(levelIndex, lessThan(genericIndex),
          reason: '/game/level/:levelId must come BEFORE /game/:mode');
    });

    test('/game/duel is defined before /game/:mode', () {
      final routes = _extractRoutes();
      final paths = routes.map((r) => r.path).toList();

      final duelIndex = paths.indexOf('/game/duel');
      final genericIndex = paths.indexOf('/game/:mode');

      expect(duelIndex, isNot(-1), reason: '/game/duel must exist');
      expect(genericIndex, isNot(-1), reason: '/game/:mode must exist');
      expect(duelIndex, lessThan(genericIndex),
          reason: '/game/duel must come BEFORE /game/:mode');
    });

    test('/game/level/:levelId is defined before /game/duel', () {
      final routes = _extractRoutes();
      final paths = routes.map((r) => r.path).toList();

      final levelIndex = paths.indexOf('/game/level/:levelId');
      final duelIndex = paths.indexOf('/game/duel');

      expect(levelIndex, lessThan(duelIndex),
          reason: '/game/level/:levelId should come before /game/duel');
    });
  });

  // ─────────────────────────────────────────────
  // New tests: Route matching via probe router
  // ─────────────────────────────────────────────
  group('Route matching — probe router', () {
    testWidgets('/game/level/5 matches /game/level/:levelId pattern',
        (tester) async {
      final router = _buildProbeRouter();
      router.go('/game/level/5');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('matched:/game/level/:levelId'), findsOneWidget);
    });

    testWidgets('/game/level/1 matches /game/level/:levelId pattern',
        (tester) async {
      final router = _buildProbeRouter();
      router.go('/game/level/1');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('matched:/game/level/:levelId'), findsOneWidget);
    });

    testWidgets('/game/duel matches /game/duel pattern', (tester) async {
      final router = _buildProbeRouter();
      router.go('/game/duel');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('matched:/game/duel'), findsOneWidget);
    });

    testWidgets('/game/duel with query params still matches /game/duel',
        (tester) async {
      final router = _buildProbeRouter();
      router.go('/game/duel?matchId=abc&seed=42&isBot=true');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('matched:/game/duel'), findsOneWidget);
    });

    testWidgets('/game/classic matches /game/:mode pattern', (tester) async {
      final router = _buildProbeRouter();
      router.go('/game/classic');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('matched:/game/:mode'), findsOneWidget);
    });

    testWidgets('/game/zen matches /game/:mode pattern', (tester) async {
      final router = _buildProbeRouter();
      router.go('/game/zen');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('matched:/game/:mode'), findsOneWidget);
    });

    testWidgets('/game/colorChef matches /game/:mode pattern', (tester) async {
      final router = _buildProbeRouter();
      router.go('/game/colorChef');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('matched:/game/:mode'), findsOneWidget);
    });

    testWidgets('/game/timeTrial matches /game/:mode pattern', (tester) async {
      final router = _buildProbeRouter();
      router.go('/game/timeTrial');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('matched:/game/:mode'), findsOneWidget);
    });

    testWidgets('/game/nonexistent matches /game/:mode (fallback)',
        (tester) async {
      final router = _buildProbeRouter();
      router.go('/game/nonexistent');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Even invalid mode strings match /game/:mode — GameMode.fromString
      // handles the fallback to classic.
      expect(find.text('matched:/game/:mode'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────
  // New tests: Route existence via probe router
  // ─────────────────────────────────────────────
  group('Route existence — all documented routes navigable', () {
    final documentedRoutes = <String, String>{
      '/': '/',
      '/onboarding': '/onboarding',
      '/daily': '/daily',
      '/settings': '/settings',
      '/shop': '/shop',
      '/leaderboard': '/leaderboard',
      '/collection': '/collection',
      '/levels': '/levels',
      '/pvp-lobby': '/pvp-lobby',
      '/island': '/island',
      '/character': '/character',
      '/season-pass': '/season-pass',
    };

    for (final entry in documentedRoutes.entries) {
      testWidgets('${entry.key} is navigable', (tester) async {
        final router = _buildProbeRouter();
        router.go(entry.value);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('matched:${entry.key}'), findsOneWidget);
      });
    }
  });

  // ─────────────────────────────────────────────
  // New tests: GameMode.fromString additional fallback
  // ─────────────────────────────────────────────
  group('GameMode.fromString — additional fallback cases', () {
    test('numeric string falls back to classic', () {
      expect(GameMode.fromString('123'), GameMode.classic);
    });

    test('special characters fall back to classic', () {
      expect(GameMode.fromString('cl@ssic!'), GameMode.classic);
    });

    test('whitespace-only string falls back to classic', () {
      expect(GameMode.fromString('   '), GameMode.classic);
    });
  });
}
