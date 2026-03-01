import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/game/economy/currency_manager.dart';
import 'package:gloo/game/shapes/gel_shape.dart';
import 'package:gloo/game/systems/powerup_system.dart';
import 'package:gloo/game/world/grid_manager.dart';

void main() {
  late CurrencyManager currency;
  late PowerUpSystem system;

  setUp(() {
    currency = CurrencyManager(initialBalance: 100);
    system = PowerUpSystem(currencyManager: currency);
  });

  // ─── PowerUpDef constants ───────────────────────────────────────────────

  group('PowerUpDef constants', () {
    test('all 6 power-ups are defined', () {
      expect(kPowerUpDefs.length, 6);
      expect(kPowerUpDefs.containsKey(PowerUpType.rotate), isTrue);
      expect(kPowerUpDefs.containsKey(PowerUpType.bomb), isTrue);
      expect(kPowerUpDefs.containsKey(PowerUpType.peek), isTrue);
      expect(kPowerUpDefs.containsKey(PowerUpType.undo), isTrue);
      expect(kPowerUpDefs.containsKey(PowerUpType.rainbow), isTrue);
      expect(kPowerUpDefs.containsKey(PowerUpType.freeze), isTrue);
    });

    test('costs match CurrencyCosts', () {
      expect(kPowerUpDefs[PowerUpType.rotate]!.cost, CurrencyCosts.rotate);
      expect(kPowerUpDefs[PowerUpType.bomb]!.cost, CurrencyCosts.bomb);
      expect(kPowerUpDefs[PowerUpType.peek]!.cost, CurrencyCosts.peek);
      expect(kPowerUpDefs[PowerUpType.undo]!.cost, CurrencyCosts.undo);
      expect(kPowerUpDefs[PowerUpType.rainbow]!.cost, CurrencyCosts.rainbow);
      expect(kPowerUpDefs[PowerUpType.freeze]!.cost, CurrencyCosts.freeze);
    });

    test('undo has maxPerGame = 1', () {
      expect(kPowerUpDefs[PowerUpType.undo]!.maxPerGame, 1);
    });

    test('freeze has maxPerGame = 1', () {
      expect(kPowerUpDefs[PowerUpType.freeze]!.maxPerGame, 1);
    });

    test('bomb has cooldown of 1 move', () {
      expect(kPowerUpDefs[PowerUpType.bomb]!.cooldownMoves, 1);
    });

    test('rainbow has cooldown of 2 moves', () {
      expect(kPowerUpDefs[PowerUpType.rainbow]!.cooldownMoves, 2);
    });
  });

  // ─── canUse ─────────────────────────────────────────────────────────────

  group('canUse', () {
    test('returns true when balance sufficient and no cooldown', () {
      expect(system.canUse(PowerUpType.rotate), isTrue);
    });

    test('returns false when balance insufficient', () {
      currency = CurrencyManager(initialBalance: 0);
      system = PowerUpSystem(currencyManager: currency);
      expect(system.canUse(PowerUpType.rotate), isFalse);
    });

    test('returns false during cooldown', () {
      system.useRotate(const GelShape(cells: [(0, 0)], name: 'dot'));
      // Bomb has cooldown of 1
      system.useBomb(GridManager(rows: 4, cols: 4), 1, 1);
      expect(system.canUse(PowerUpType.bomb), isFalse);
    });

    test('returns false when max usage reached', () {
      // Undo has maxPerGame = 1
      system.recordPlacement([(0, 0)], GelColor.red);
      system.useUndo(GridManager(rows: 4, cols: 4));
      // Need new placement for second undo attempt
      system.recordPlacement([(1, 0)], GelColor.blue);
      expect(system.canUse(PowerUpType.undo), isFalse);
    });
  });

  // ─── useRotate ──────────────────────────────────────────────────────────

  group('useRotate', () {
    test('returns rotated shape', () {
      const shape = GelShape(cells: [(0, 0), (0, 1)], name: 'h2');
      final result = system.useRotate(shape);
      expect(result, isNotNull);
      expect(result!.rotatedShape.cells.length, 2);
      expect(result.rotatedShape.name, 'h2_r');
    });

    test('deducts cost from balance', () {
      const shape = GelShape(cells: [(0, 0)], name: 'dot');
      final before = currency.balance;
      system.useRotate(shape);
      expect(currency.balance, before - CurrencyCosts.rotate);
    });

    test('fires onPowerUpUsed callback', () {
      PowerUpType? firedType;
      system.onPowerUpUsed = (type, result) => firedType = type;
      system.useRotate(const GelShape(cells: [(0, 0)], name: 'dot'));
      expect(firedType, PowerUpType.rotate);
    });

    test('returns null when cannot afford', () {
      currency = CurrencyManager(initialBalance: 0);
      system = PowerUpSystem(currencyManager: currency);
      final result =
          system.useRotate(const GelShape(cells: [(0, 0)], name: 'dot'));
      expect(result, isNull);
    });
  });

  // ─── useBomb ────────────────────────────────────────────────────────────

  group('useBomb', () {
    test('clears 3x3 area around center', () {
      final grid = GridManager(rows: 6, cols: 6);
      // Place colors in 3x3 area
      for (int r = 1; r <= 3; r++) {
        for (int c = 1; c <= 3; c++) {
          grid.setCell(r, c, GelColor.red);
        }
      }
      final result = system.useBomb(grid, 2, 2);
      expect(result, isNotNull);
      expect(result!.clearedCells.isNotEmpty, isTrue);
      // Center and surroundings should be cleared
      expect(grid.getCell(2, 2).color, isNull);
    });

    test('deducts bomb cost', () {
      final grid = GridManager(rows: 4, cols: 4);
      final before = currency.balance;
      system.useBomb(grid, 1, 1);
      expect(currency.balance, before - CurrencyCosts.bomb);
    });

    test('sets cooldown after use', () {
      final grid = GridManager(rows: 4, cols: 4);
      system.useBomb(grid, 1, 1);
      expect(system.getCooldown(PowerUpType.bomb), 1);
      expect(system.canUse(PowerUpType.bomb), isFalse);
    });
  });

  // ─── usePeek ────────────────────────────────────────────────────────────

  group('usePeek', () {
    test('returns upcoming shapes', () {
      final upcoming = [
        (const GelShape(cells: [(0, 0)], name: 'dot'), GelColor.red),
        (const GelShape(cells: [(0, 0), (0, 1)], name: 'h2'), GelColor.blue),
      ];
      final result = system.usePeek(upcoming);
      expect(result, isNotNull);
      expect(result!.upcomingShapes.length, 2);
      expect(system.peekedShapes, isNotNull);
    });

    test('deducts peek cost', () {
      final before = currency.balance;
      system.usePeek([]);
      expect(currency.balance, before - CurrencyCosts.peek);
    });
  });

  // ─── useUndo ────────────────────────────────────────────────────────────

  group('useUndo', () {
    test('restores last placed cells', () {
      final grid = GridManager(rows: 4, cols: 4);
      grid.place([(0, 0), (0, 1)], GelColor.red);
      system.recordPlacement([(0, 0), (0, 1)], GelColor.red);
      final result = system.useUndo(grid);
      expect(result, isNotNull);
      expect(result!.restoredCells, [(0, 0), (0, 1)]);
      expect(grid.getCell(0, 0).color, isNull);
      expect(grid.getCell(0, 1).color, isNull);
    });

    test('returns null when no previous placement', () {
      final grid = GridManager(rows: 4, cols: 4);
      final result = system.useUndo(grid);
      expect(result, isNull);
    });

    test('clears placement record after undo', () {
      final grid = GridManager(rows: 4, cols: 4);
      grid.place([(0, 0)], GelColor.red);
      system.recordPlacement([(0, 0)], GelColor.red);
      system.useUndo(grid);
      expect(system.lastPlacedColor, isNull);
    });

    test('cannot use undo twice (maxPerGame = 1)', () {
      final grid = GridManager(rows: 4, cols: 4);
      grid.place([(0, 0)], GelColor.red);
      system.recordPlacement([(0, 0)], GelColor.red);
      system.useUndo(grid);

      grid.place([(1, 0)], GelColor.blue);
      system.recordPlacement([(1, 0)], GelColor.blue);
      final secondResult = system.useUndo(grid);
      expect(secondResult, isNull);
    });
  });

  // ─── useRainbow ─────────────────────────────────────────────────────────

  group('useRainbow', () {
    test('returns result when affordable', () {
      final result = system.useRainbow();
      expect(result, isNotNull);
    });

    test('deducts rainbow cost', () {
      final before = currency.balance;
      system.useRainbow();
      expect(currency.balance, before - CurrencyCosts.rainbow);
    });

    test('sets cooldown of 2', () {
      system.useRainbow();
      expect(system.getCooldown(PowerUpType.rainbow), 2);
    });
  });

  // ─── useFreeze ──────────────────────────────────────────────────────────

  group('useFreeze', () {
    test('returns FreezeResult with 10 seconds', () {
      final result = system.useFreeze();
      expect(result, isNotNull);
      expect(result!.frozenSeconds, 10);
    });

    test('cannot use freeze twice (maxPerGame = 1)', () {
      system.useFreeze();
      final second = system.useFreeze();
      expect(second, isNull);
    });
  });

  // ─── onMoveCompleted (cooldown decay) ───────────────────────────────────

  group('onMoveCompleted', () {
    test('decrements cooldown by 1', () {
      system.useRainbow(); // cooldown = 2
      expect(system.getCooldown(PowerUpType.rainbow), 2);
      system.onMoveCompleted();
      expect(system.getCooldown(PowerUpType.rainbow), 1);
      system.onMoveCompleted();
      expect(system.getCooldown(PowerUpType.rainbow), 0);
    });

    test('cooldown does not go below 0', () {
      system.onMoveCompleted();
      expect(system.getCooldown(PowerUpType.rotate), 0);
    });
  });

  // ─── recordPlacement ────────────────────────────────────────────────────

  group('recordPlacement', () {
    test('stores cells and color for undo', () {
      system.recordPlacement([(2, 3), (2, 4)], GelColor.blue);
      expect(system.lastPlacedColor, GelColor.blue);
    });
  });

  // ─── reset ──────────────────────────────────────────────────────────────

  group('reset', () {
    test('clears all state', () {
      system.useRotate(const GelShape(cells: [(0, 0)], name: 'dot'));
      system.recordPlacement([(0, 0)], GelColor.red);
      system.reset();
      expect(system.lastPlacedColor, isNull);
      expect(system.peekedShapes, isNull);
      expect(system.getCooldown(PowerUpType.rotate), 0);
      expect(system.getUsageCount(PowerUpType.rotate), 0);
    });
  });

  // ─── grantFreePowerUp ───────────────────────────────────────────────────

  group('grantFreePowerUp', () {
    test('resets cooldown and fires callback', () {
      system.useRainbow(); // sets cooldown
      expect(system.getCooldown(PowerUpType.rainbow), 2);

      PowerUpResult? firedResult;
      system.onPowerUpUsed = (type, result) => firedResult = result;
      system.grantFreePowerUp(PowerUpType.rainbow);

      expect(system.getCooldown(PowerUpType.rainbow), 0);
      expect(firedResult, isA<GrantedResult>());
    });
  });
}
