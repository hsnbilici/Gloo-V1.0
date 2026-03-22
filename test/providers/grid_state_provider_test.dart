import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/features/game_screen/cell_render_data.dart';
import 'package:gloo/game/world/cell_type.dart';
import 'package:gloo/providers/grid_state_provider.dart';

void main() {
  // ─── GridStateNotifier ──────────────────────────────────────────────────

  group('GridStateNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('initial state is empty map', () {
      final state = container.read(gridStateProvider);
      expect(state, isEmpty);
      expect(state, isA<Map<(int, int), CellRenderData>>());
    });

    test('updateCells sets cell data', () {
      const cell = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );
      final cells = <(int, int), CellRenderData>{(0, 0): cell};

      container.read(gridStateProvider.notifier).updateCells(cells);

      final state = container.read(gridStateProvider);
      expect(state.length, 1);
      expect(state[(0, 0)], cell);
    });

    test('updateCells replaces entire state', () {
      const cellA = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );
      const cellB = CellRenderData(
        color: GelColor.blue,
        type: CellType.normal,
        iceLayer: 0,
      );

      final notifier = container.read(gridStateProvider.notifier);

      notifier.updateCells({(0, 0): cellA});
      expect(container.read(gridStateProvider).length, 1);

      notifier.updateCells({(1, 1): cellB, (2, 2): cellA});
      final state = container.read(gridStateProvider);
      expect(state.length, 2);
      expect(state[(0, 0)], isNull);
      expect(state[(1, 1)], cellB);
      expect(state[(2, 2)], cellA);
    });

    test('updateCells with empty map clears state', () {
      const cell = CellRenderData(
        color: GelColor.yellow,
        type: CellType.normal,
        iceLayer: 0,
      );
      final notifier = container.read(gridStateProvider.notifier);

      notifier.updateCells({(0, 0): cell});
      expect(container.read(gridStateProvider), isNotEmpty);

      notifier.updateCells(const {});
      expect(container.read(gridStateProvider), isEmpty);
    });

    // ─── Delta Check ────────────────────────────────────────────────────

    test('updateCells skips update when cells are identical', () {
      const cell = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );
      final cells = {(0, 0): cell};

      final notifier = container.read(gridStateProvider.notifier);
      notifier.updateCells(cells);

      final firstState = container.read(gridStateProvider);

      // Update with identical content — should be same reference (no rebuild).
      notifier.updateCells({(0, 0): cell});
      final secondState = container.read(gridStateProvider);

      expect(identical(firstState, secondState), isTrue);
    });

    test('updateCells detects changed cell value', () {
      const cellA = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );
      const cellB = CellRenderData(
        color: GelColor.blue,
        type: CellType.normal,
        iceLayer: 0,
      );

      final notifier = container.read(gridStateProvider.notifier);
      notifier.updateCells({(0, 0): cellA});
      final firstState = container.read(gridStateProvider);

      notifier.updateCells({(0, 0): cellB});
      final secondState = container.read(gridStateProvider);

      expect(identical(firstState, secondState), isFalse);
      expect(secondState[(0, 0)]?.color, GelColor.blue);
    });

    test('updateCells detects size change', () {
      const cell = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );

      final notifier = container.read(gridStateProvider.notifier);
      notifier.updateCells({(0, 0): cell});
      final firstState = container.read(gridStateProvider);

      notifier.updateCells({(0, 0): cell, (1, 0): cell});
      final secondState = container.read(gridStateProvider);

      expect(identical(firstState, secondState), isFalse);
      expect(secondState.length, 2);
    });

    // ─── Select-based Lookups ───────────────────────────────────────────

    test('select reads specific cell by (row, col)', () {
      const cell = CellRenderData(
        color: GelColor.green,
        type: CellType.ice,
        iceLayer: 2,
      );
      container.read(gridStateProvider.notifier).updateCells({
        (3, 5): cell,
        (0, 0): const CellRenderData(
          color: GelColor.red,
          type: CellType.normal,
          iceLayer: 0,
        ),
      });

      // Simulate the select pattern used in production widgets.
      final selected = container.read(
        gridStateProvider.select((state) => state[(3, 5)]),
      );
      expect(selected, cell);
      expect(selected?.color, GelColor.green);
      expect(selected?.type, CellType.ice);
      expect(selected?.iceLayer, 2);
    });

    test('select returns null for absent cell', () {
      container.read(gridStateProvider.notifier).updateCells({
        (0, 0): const CellRenderData(
          color: GelColor.red,
          type: CellType.normal,
          iceLayer: 0,
        ),
      });

      final selected = container.read(
        gridStateProvider.select((state) => state[(9, 9)]),
      );
      expect(selected, isNull);
    });

    // ─── CellRenderData Properties ──────────────────────────────────────

    test('stores cells with all CellRenderData properties', () {
      const cell = CellRenderData(
        color: GelColor.purple,
        type: CellType.locked,
        iceLayer: 1,
        lockedColor: GelColor.blue,
        isPreview: true,
        previewValid: true,
        previewSlotColor: GelColor.yellow,
        isRecentlyPlaced: true,
        waveDistance: 3,
        isInteractive: true,
        isNearlyFullRow: true,
      );

      container.read(gridStateProvider.notifier).updateCells({(4, 7): cell});
      final stored = container.read(gridStateProvider)[(4, 7)]!;

      expect(stored.color, GelColor.purple);
      expect(stored.type, CellType.locked);
      expect(stored.iceLayer, 1);
      expect(stored.lockedColor, GelColor.blue);
      expect(stored.isPreview, isTrue);
      expect(stored.previewValid, isTrue);
      expect(stored.previewSlotColor, GelColor.yellow);
      expect(stored.isRecentlyPlaced, isTrue);
      expect(stored.waveDistance, 3);
      expect(stored.isInteractive, isTrue);
      expect(stored.isNearlyFullRow, isTrue);
    });

    test('stores cells with various CellTypes', () {
      final notifier = container.read(gridStateProvider.notifier);
      final cells = <(int, int), CellRenderData>{};
      for (final (i, type) in CellType.values.indexed) {
        cells[(i, 0)] = CellRenderData(
          color: null,
          type: type,
          iceLayer: type == CellType.ice ? 1 : 0,
        );
      }
      notifier.updateCells(cells);

      final state = container.read(gridStateProvider);
      expect(state.length, CellType.values.length);
      for (final (i, type) in CellType.values.indexed) {
        expect(state[(i, 0)]?.type, type);
      }
    });

    // ─── Listener Notification ──────────────────────────────────────────

    test('notifies listeners on state change', () {
      var callCount = 0;
      container.listen(gridStateProvider, (_, __) => callCount++);

      final notifier = container.read(gridStateProvider.notifier);

      notifier.updateCells({
        (0, 0): const CellRenderData(
          color: GelColor.red,
          type: CellType.normal,
          iceLayer: 0,
        ),
      });
      expect(callCount, 1);

      // Same content — delta check should skip.
      notifier.updateCells({
        (0, 0): const CellRenderData(
          color: GelColor.red,
          type: CellType.normal,
          iceLayer: 0,
        ),
      });
      expect(callCount, 1);

      // Changed content — should notify.
      notifier.updateCells({
        (0, 0): const CellRenderData(
          color: GelColor.blue,
          type: CellType.normal,
          iceLayer: 0,
        ),
      });
      expect(callCount, 2);
    });
  });

  // ─── CellRenderData Equality ────────────────────────────────────────────

  group('CellRenderData equality', () {
    test('equal when all fields match', () {
      const a = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );
      const b = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('not equal when color differs', () {
      const a = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );
      const b = CellRenderData(
        color: GelColor.blue,
        type: CellType.normal,
        iceLayer: 0,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when type differs', () {
      const a = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );
      const b = CellRenderData(
        color: GelColor.red,
        type: CellType.ice,
        iceLayer: 1,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when isPreview differs', () {
      const a = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
      );
      const b = CellRenderData(
        color: GelColor.red,
        type: CellType.normal,
        iceLayer: 0,
        isPreview: true,
      );
      expect(a, isNot(equals(b)));
    });

    test('null color cells are equal', () {
      const a = CellRenderData(
        color: null,
        type: CellType.normal,
        iceLayer: 0,
      );
      const b = CellRenderData(
        color: null,
        type: CellType.normal,
        iceLayer: 0,
      );
      expect(a, equals(b));
    });

    test('not equal when isNearlyFullRow differs', () {
      const a = CellRenderData(
        color: null,
        type: CellType.normal,
        iceLayer: 0,
      );
      const b = CellRenderData(
        color: null,
        type: CellType.normal,
        iceLayer: 0,
        isNearlyFullRow: true,
      );
      expect(a, isNot(equals(b)));
    });

    test('equal when isNearlyFullRow matches', () {
      const a = CellRenderData(
        color: null,
        type: CellType.normal,
        iceLayer: 0,
        isNearlyFullRow: true,
      );
      const b = CellRenderData(
        color: null,
        type: CellType.normal,
        iceLayer: 0,
        isNearlyFullRow: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
