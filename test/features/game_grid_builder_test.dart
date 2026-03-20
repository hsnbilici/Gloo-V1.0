import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/constants/game_constants.dart';
import 'package:gloo/data/local/local_repository.dart';
import 'package:gloo/features/game_screen/game_cell_widget.dart';
import 'package:gloo/features/game_screen/game_screen.dart';
import 'package:gloo/features/game_screen/power_up_toolbar.dart';
import 'package:gloo/features/game_screen/shape_hand.dart';
import 'package:gloo/game/world/cell_type.dart';
import 'package:gloo/game/world/game_world.dart';
import 'package:gloo/game/world/grid_manager.dart';
import 'package:gloo/providers/service_providers.dart';
import 'package:gloo/providers/user_provider.dart';

import '../data/local/fake_secure_storage.dart';
import '../helpers/mocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

void _stubAnalytics(MockAnalyticsService mock) {
  when(() => mock.logGameStart(mode: any(named: 'mode'))).thenReturn(null);
  when(() => mock.logGameOver(
        mode: any(named: 'mode'),
        score: any(named: 'score'),
      )).thenReturn(null);
}

void _stubAdManager(MockAdManager mock) {
  when(() => mock.canShowNearMissRescue()).thenReturn(false);
  when(() => mock.canShowHighScoreContinue(
        currentScore: any(named: 'currentScore'),
        highScore: any(named: 'highScore'),
      )).thenReturn(false);
  when(() => mock.canShowSecondChance(
        currentScore: any(named: 'currentScore'),
        averageScore: any(named: 'averageScore'),
      )).thenReturn(false);
}

Future<LocalRepository> _buildFakeRepo() async {
  SharedPreferences.setMockInitialValues({
    'onboarding_done': true,
    'tutorial_done': true,
    'colorblind_prompt_shown': true,
    'analytics_enabled': true,
  });
  final prefs = await SharedPreferences.getInstance();
  return LocalRepository(prefs, secureStorage: FakeSecureStorage());
}

Widget buildGameScreenApp({
  GameMode mode = GameMode.classic,
  List<Override> extraOverrides = const [],
}) {
  final mockAnalytics = MockAnalyticsService();
  final mockAdManager = MockAdManager();
  _stubAnalytics(mockAnalytics);
  _stubAdManager(mockAdManager);

  final router = GoRouter(
    initialLocation: '/game/classic',
    routes: [
      GoRoute(
        path: '/game/:mode',
        builder: (context, state) => GameScreen(mode: mode),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const SizedBox(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      streakProvider.overrideWith((ref) async => 0),
      analyticsServiceProvider.overrideWithValue(mockAnalytics),
      adManagerProvider.overrideWithValue(mockAdManager),
      localRepositoryProvider.overrideWith((ref) async => _buildFakeRepo()),
      ...extraOverrides,
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('GameGridBuilder — grid cell count', () {
    testWidgets('renders correct number of cells for default 8x10 grid',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final cellWidgets = find.byType(GameCellWidget);
      expect(cellWidgets, findsNWidgets(
        GameConstants.gridRows * GameConstants.gridCols,
      ));
    });

    testWidgets('grid renders inside LayoutBuilder', (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LayoutBuilder), findsWidgets);
      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('GameGridBuilder — cell rendering', () {
    testWidgets('empty cells have GestureDetector for tapping',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // All cells should have GestureDetector wrapping
      final cellWidgets = find.byType(GameCellWidget);
      expect(cellWidgets, findsWidgets);

      // Verify each cell widget has a GestureDetector descendant
      final firstCell = cellWidgets.first;
      final gestureDetector = find.descendant(
        of: firstCell,
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetector, findsOneWidget);
    });

    testWidgets('cells have Semantics labels', (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Empty cells should have 'Empty R, C' semantics
      final semantics = find.bySemanticsLabel(RegExp(r'^Empty \d+, \d+$'));
      expect(semantics, findsWidgets);
    });
  });

  group('GameGridBuilder — ShapeHand and PowerUpToolbar rendered', () {
    testWidgets('ShapeHand is rendered below grid', (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ShapeHand), findsOneWidget);
    });

    testWidgets('PowerUpToolbar is rendered between grid and hand',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PowerUpToolbar), findsOneWidget);
    });
  });

  group('GameGridBuilder — cell types (unit-level)', () {
    test('Cell with CellType.stone reports isEmpty=false', () {
      final cell = Cell(type: CellType.stone);
      expect(cell.isEmpty, isFalse);
    });

    test('Cell with CellType.stone does not accept placement', () {
      final cell = Cell(type: CellType.stone);
      expect(cell.canAccept(GelColor.red), isFalse);
    });

    test('Cell with CellType.ice has iceLayer > 0', () {
      final cell = Cell(type: CellType.ice, iceLayer: 2);
      expect(cell.iceLayer, equals(2));
      expect(cell.isEmpty, isTrue); // ice cell with no color is empty
    });

    test('Cell with CellType.ice cracks down on crackIce()', () {
      final cell = Cell(type: CellType.ice, iceLayer: 2);
      cell.crackIce();
      expect(cell.iceLayer, equals(1));
      expect(cell.type, equals(CellType.ice));

      cell.crackIce();
      expect(cell.iceLayer, equals(0));
      expect(cell.type, equals(CellType.normal));
    });

    test('Cell with CellType.locked only accepts matching color', () {
      final cell = Cell(type: CellType.locked, lockedColor: GelColor.red);
      expect(cell.canAccept(GelColor.red), isTrue);
      expect(cell.canAccept(GelColor.blue), isFalse);
    });

    test('Cell with CellType.normal accepts any color', () {
      final cell = Cell(type: CellType.normal);
      expect(cell.canAccept(GelColor.red), isTrue);
      expect(cell.canAccept(GelColor.blue), isTrue);
      expect(cell.canAccept(GelColor.yellow), isTrue);
    });

    test('Cell with color is not empty', () {
      final cell = Cell(color: GelColor.red);
      expect(cell.isEmpty, isFalse);
      expect(cell.canAccept(GelColor.blue), isFalse); // occupied
    });

    test('Cell.clearColor resets color to null', () {
      final cell = Cell(color: GelColor.red);
      cell.clearColor();
      expect(cell.color, isNull);
      expect(cell.isEmpty, isTrue);
    });

    test('Cell.copy creates independent copy', () {
      final original = Cell(
        color: GelColor.red,
        type: CellType.ice,
        iceLayer: 2,
      );
      final copy = original.copy();

      expect(copy.color, equals(original.color));
      expect(copy.type, equals(original.type));
      expect(copy.iceLayer, equals(original.iceLayer));

      // Modifying copy should not affect original
      copy.color = GelColor.blue;
      expect(original.color, equals(GelColor.red));
    });
  });

  group('GameGridBuilder — GridManager operations', () {
    test('GridManager default grid is 8x10', () {
      final gm = GridManager();
      expect(gm.rows, equals(GameConstants.gridRows));
      expect(gm.cols, equals(GameConstants.gridCols));
    });

    test('GridManager custom size works', () {
      final gm = GridManager(rows: 6, cols: 6);
      expect(gm.rows, equals(6));
      expect(gm.cols, equals(6));
    });

    test('filledCells starts at 0', () {
      final gm = GridManager();
      expect(gm.filledCells, equals(0));
    });

    test('place fills cells and increases filledCells count', () {
      final gm = GridManager();
      gm.place([(0, 0), (0, 1)], GelColor.red);

      expect(gm.filledCells, equals(2));
      expect(gm.getCell(0, 0).color, equals(GelColor.red));
      expect(gm.getCell(0, 1).color, equals(GelColor.red));
    });

    test('canPlace returns false for out-of-bounds coordinates', () {
      final gm = GridManager(rows: 8, cols: 8);
      expect(gm.canPlace([(-1, 0)]), isFalse);
      expect(gm.canPlace([(0, -1)]), isFalse);
      expect(gm.canPlace([(8, 0)]), isFalse);
      expect(gm.canPlace([(0, 8)]), isFalse);
    });

    test('canPlace returns false for occupied cells', () {
      final gm = GridManager();
      gm.place([(0, 0)], GelColor.red);
      expect(gm.canPlace([(0, 0)]), isFalse);
    });
  });
}
