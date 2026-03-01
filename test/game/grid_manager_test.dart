import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/game/world/cell_type.dart';
import 'package:gloo/game/world/grid_manager.dart';

void main() {
  // ─── Olusturma & Temel Ozellikler ──────────────────────────────────────────

  group('GridManager creation', () {
    test('default grid is 10 rows x 8 cols', () {
      final gm = GridManager();
      expect(gm.rows, 10);
      expect(gm.cols, 8);
    });

    test('custom size grid', () {
      final gm = GridManager(rows: 6, cols: 6);
      expect(gm.rows, 6);
      expect(gm.cols, 6);
      expect(gm.cells.length, 6);
      expect(gm.cells[0].length, 6);
    });

    test('initially all cells are empty', () {
      final gm = GridManager(rows: 4, cols: 4);
      expect(gm.filledCells, 0);
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          expect(gm.isCellEmpty(r, c), isTrue);
        }
      }
    });

    test('totalCells excludes stone cells', () {
      final gm = GridManager(rows: 3, cols: 3);
      expect(gm.totalCells, 9);
      gm.setStone(0, 0);
      gm.setStone(1, 1);
      expect(gm.totalCells, 7);
    });
  });

  // ─── Yerlestirme (place) ───────────────────────────────────────────────────

  group('GridManager.place', () {
    test('places color into specified cells', () {
      final gm = GridManager(rows: 4, cols: 4);
      gm.place([(0, 0), (0, 1), (1, 0)], GelColor.red);

      expect(gm.getCell(0, 0).color, GelColor.red);
      expect(gm.getCell(0, 1).color, GelColor.red);
      expect(gm.getCell(1, 0).color, GelColor.red);
      expect(gm.getCell(1, 1).color, isNull);
    });

    test('filledCells count updates after placement', () {
      final gm = GridManager(rows: 4, cols: 4);
      gm.place([(0, 0), (0, 1)], GelColor.blue);
      expect(gm.filledCells, 2);
    });

    test('grid property returns GelColor grid', () {
      final gm = GridManager(rows: 2, cols: 2);
      gm.place([(0, 0)], GelColor.yellow);
      final grid = gm.grid;
      expect(grid[0][0], GelColor.yellow);
      expect(grid[0][1], isNull);
    });
  });

  // ─── canPlace Dogrulama ────────────────────────────────────────────────────

  group('GridManager.canPlace', () {
    test('returns true for empty cells within bounds', () {
      final gm = GridManager(rows: 4, cols: 4);
      expect(gm.canPlace([(0, 0), (1, 1)]), isTrue);
    });

    test('returns false if any cell is out of bounds', () {
      final gm = GridManager(rows: 4, cols: 4);
      expect(gm.canPlace([(-1, 0)]), isFalse);
      expect(gm.canPlace([(0, 4)]), isFalse);
      expect(gm.canPlace([(4, 0)]), isFalse);
      expect(gm.canPlace([(0, -1)]), isFalse);
    });

    test('returns false if any cell is already occupied', () {
      final gm = GridManager(rows: 4, cols: 4);
      gm.place([(1, 1)], GelColor.red);
      expect(gm.canPlace([(1, 1)]), isFalse);
      expect(gm.canPlace([(0, 0), (1, 1)]), isFalse);
    });

    test('returns false for stone cells', () {
      final gm = GridManager(rows: 4, cols: 4);
      gm.setStone(2, 2);
      expect(gm.canPlace([(2, 2)]), isFalse);
    });

    test('locked cell accepts only matching color', () {
      final gm = GridManager(rows: 4, cols: 4);
      gm.setCellType(1, 1, CellType.locked, lockedColor: GelColor.blue);
      expect(gm.canPlace([(1, 1)], GelColor.blue), isTrue);
      expect(gm.canPlace([(1, 1)], GelColor.red), isFalse);
    });

    test('ice cell accepts any color', () {
      final gm = GridManager(rows: 4, cols: 4);
      gm.setCellType(1, 1, CellType.ice, iceLayer: 2);
      expect(gm.canPlace([(1, 1)], GelColor.green), isTrue);
    });

    test('gravity cell accepts any color when empty', () {
      final gm = GridManager(rows: 4, cols: 4);
      gm.setCellType(1, 1, CellType.gravity);
      expect(gm.canPlace([(1, 1)], GelColor.red), isTrue);
    });
  });

  // ─── Satir/Sutun Temizleme (detectAndClear) ───────────────────────────────

  group('GridManager.detectAndClear', () {
    test('clears a full row', () {
      final gm = GridManager(rows: 3, cols: 3);
      // Ilk satiri doldur
      for (int c = 0; c < 3; c++) {
        gm.place([(0, c)], GelColor.red);
      }
      final result = gm.detectAndClear();
      expect(result.clearedRows, [0]);
      expect(result.clearedCols, isEmpty);
      expect(result.totalLines, 1);
      // Temizlendikten sonra bos olmali
      for (int c = 0; c < 3; c++) {
        expect(gm.getCell(0, c).color, isNull);
      }
    });

    test('clears a full column', () {
      final gm = GridManager(rows: 3, cols: 3);
      for (int r = 0; r < 3; r++) {
        gm.place([(r, 1)], GelColor.blue);
      }
      final result = gm.detectAndClear();
      expect(result.clearedRows, isEmpty);
      expect(result.clearedCols, [1]);
      expect(result.totalLines, 1);
    });

    test('clears both row and column simultaneously', () {
      final gm = GridManager(rows: 3, cols: 3);
      // Satir 0 ve sutun 0 doldur (kesisim: 0,0)
      for (int c = 0; c < 3; c++) {
        gm.place([(0, c)], GelColor.red);
      }
      for (int r = 1; r < 3; r++) {
        gm.place([(r, 0)], GelColor.blue);
      }
      final result = gm.detectAndClear();
      expect(result.clearedRows, [0]);
      expect(result.clearedCols, [0]);
      expect(result.totalLines, 2);
    });

    test('does not clear incomplete row', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.place([(0, 0), (0, 1)], GelColor.red);
      // 0,2 bos
      final result = gm.detectAndClear();
      expect(result.totalLines, 0);
    });

    test('stone cells are skipped in row check', () {
      final gm = GridManager(rows: 3, cols: 4);
      gm.setStone(0, 2); // 0,2 tas
      // Geri kalan 3 hucreyi doldur (0,0 / 0,1 / 0,3)
      gm.place([(0, 0)], GelColor.red);
      gm.place([(0, 1)], GelColor.blue);
      gm.place([(0, 3)], GelColor.yellow);
      final result = gm.detectAndClear();
      expect(result.clearedRows, [0]);
    });

    test('stone cells are skipped in column check', () {
      final gm = GridManager(rows: 4, cols: 3);
      gm.setStone(1, 0); // 1,0 tas
      gm.place([(0, 0)], GelColor.red);
      gm.place([(2, 0)], GelColor.blue);
      gm.place([(3, 0)], GelColor.yellow);
      final result = gm.detectAndClear();
      expect(result.clearedCols, [0]);
    });

    test('clearedCellColors contains pre-clear colors', () {
      final gm = GridManager(rows: 2, cols: 2);
      gm.place([(0, 0)], GelColor.red);
      gm.place([(0, 1)], GelColor.blue);
      final result = gm.detectAndClear();
      expect(result.clearedCellColors[(0, 0)], GelColor.red);
      expect(result.clearedCellColors[(0, 1)], GelColor.blue);
    });

    test('multiple rows cleared at once', () {
      final gm = GridManager(rows: 3, cols: 3);
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          gm.place([(r, c)], GelColor.red);
        }
      }
      final result = gm.detectAndClear();
      expect(result.clearedRows.length, 3);
      expect(result.clearedCols.length, 3);
    });
  });

  // ─── Buz Kirma ─────────────────────────────────────────────────────────────

  group('Ice cracking during clear', () {
    test('ice layer 2 cracks to 1 on clear', () {
      final gm = GridManager(rows: 2, cols: 2);
      gm.setCellType(0, 0, CellType.ice, iceLayer: 2);
      // Satir 0 doldur
      gm.place([(0, 0)], GelColor.red);
      gm.place([(0, 1)], GelColor.blue);
      final result = gm.detectAndClear();

      expect(result.crackedIceCells, contains((0, 0)));
      expect(gm.getCell(0, 0).type, CellType.ice);
      expect(gm.getCell(0, 0).iceLayer, 1);
      expect(gm.getCell(0, 0).color, isNull);
    });

    test('ice layer 1 cracks to normal on clear', () {
      final gm = GridManager(rows: 2, cols: 2);
      gm.setCellType(0, 0, CellType.ice, iceLayer: 1);
      gm.place([(0, 0)], GelColor.red);
      gm.place([(0, 1)], GelColor.blue);
      final result = gm.detectAndClear();

      expect(result.crackedIceCells, contains((0, 0)));
      expect(gm.getCell(0, 0).type, CellType.normal);
      expect(gm.getCell(0, 0).iceLayer, 0);
    });

    test('non-ice cells are simply cleared', () {
      final gm = GridManager(rows: 2, cols: 2);
      gm.place([(0, 0)], GelColor.red);
      gm.place([(0, 1)], GelColor.blue);
      final result = gm.detectAndClear();

      expect(result.crackedIceCells, isEmpty);
      expect(gm.getCell(0, 0).color, isNull);
    });
  });

  // ─── Yercekimi (applyGravity) ──────────────────────────────────────────────

  group('GridManager.applyGravity', () {
    test('drops blocks above gravity cell downward', () {
      final gm = GridManager(rows: 4, cols: 3);
      gm.setCellType(3, 1, CellType.gravity);
      // r=1, c=1 dolu, r=2 ve r=3 bos
      gm.place([(1, 1)], GelColor.red);
      final moves = gm.applyGravity();

      expect(moves, isNotEmpty);
      // Blok asagi inmeli
      expect(gm.getCell(3, 1).color, GelColor.red);
      expect(gm.getCell(1, 1).color, isNull);
    });

    test('no moves when no gravity cells exist', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.place([(0, 0)], GelColor.red);
      final moves = gm.applyGravity();
      expect(moves, isEmpty);
    });

    test('gravity stops at stone cell', () {
      final gm = GridManager(rows: 4, cols: 3);
      gm.setCellType(3, 0, CellType.gravity);
      gm.setStone(2, 0); // Tas engel
      gm.place([(0, 0)], GelColor.blue);
      // Stone var — scan stone'da break eder, blok yerinde kalir
      gm.applyGravity();
      // Blok stone'un ustune dusmez (scan break)
      expect(gm.getCell(3, 0).color, isNull);
    });
  });

  // ─── clearArea (Bomb power-up) ─────────────────────────────────────────────

  group('GridManager.clearArea', () {
    test('clears 3x3 area around center', () {
      final gm = GridManager(rows: 5, cols: 5);
      // 3x3 alanini doldur (merkez: 2,2)
      for (int r = 1; r <= 3; r++) {
        for (int c = 1; c <= 3; c++) {
          gm.place([(r, c)], GelColor.red);
        }
      }
      final cleared = gm.clearArea(2, 2, 1);
      expect(cleared.length, 9);
      for (int r = 1; r <= 3; r++) {
        for (int c = 1; c <= 3; c++) {
          expect(gm.getCell(r, c).color, isNull);
        }
      }
    });

    test('clears only non-stone cells', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.setStone(1, 1); // Merkez tas
      gm.place([(0, 0)], GelColor.red);
      gm.place([(0, 1)], GelColor.blue);
      gm.place([(0, 2)], GelColor.yellow);
      gm.place([(1, 0)], GelColor.green);
      gm.place([(1, 2)], GelColor.orange);
      gm.place([(2, 0)], GelColor.red);
      gm.place([(2, 1)], GelColor.blue);
      gm.place([(2, 2)], GelColor.yellow);

      final cleared = gm.clearArea(1, 1, 1);
      expect(cleared.length, 8); // 9 - 1 stone = 8
      expect(cleared.containsKey((1, 1)), isFalse);
    });

    test('handles edge of grid (clips to bounds)', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.place([(0, 0)], GelColor.red);
      gm.place([(0, 1)], GelColor.blue);
      gm.place([(1, 0)], GelColor.green);
      gm.place([(1, 1)], GelColor.yellow);

      final cleared = gm.clearArea(0, 0, 1);
      expect(cleared.length, 4);
    });

    test('returns empty map when area has no filled cells', () {
      final gm = GridManager(rows: 3, cols: 3);
      final cleared = gm.clearArea(1, 1, 1);
      expect(cleared, isEmpty);
    });

    test('cracks ice in clearArea', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.setCellType(1, 1, CellType.ice, iceLayer: 2);
      gm.place([(1, 1)], GelColor.red);
      final cleared = gm.clearArea(1, 1, 1);

      expect(cleared.containsKey((1, 1)), isTrue);
      expect(gm.getCell(1, 1).iceLayer, 1);
      expect(gm.getCell(1, 1).color, isNull);
    });
  });

  // ─── undoPlace ─────────────────────────────────────────────────────────────

  group('GridManager.undoPlace', () {
    test('removes color from specified cells', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.place([(0, 0), (0, 1), (1, 0)], GelColor.red);
      expect(gm.filledCells, 3);

      gm.undoPlace([(0, 0), (0, 1), (1, 0)]);
      expect(gm.filledCells, 0);
      expect(gm.getCell(0, 0).color, isNull);
    });
  });

  // ─── setCell & setCellType ─────────────────────────────────────────────────

  group('GridManager.setCell and setCellType', () {
    test('setCell changes cell color', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.setCell(1, 1, GelColor.purple);
      expect(gm.getCell(1, 1).color, GelColor.purple);
      gm.setCell(1, 1, null);
      expect(gm.getCell(1, 1).color, isNull);
    });

    test('setCellType configures cell type', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.setCellType(0, 0, CellType.ice, iceLayer: 2);
      expect(gm.getCell(0, 0).type, CellType.ice);
      expect(gm.getCell(0, 0).iceLayer, 2);
    });

    test('setCellType with locked color', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.setCellType(0, 0, CellType.locked, lockedColor: GelColor.blue);
      expect(gm.getCell(0, 0).type, CellType.locked);
      expect(gm.getCell(0, 0).lockedColor, GelColor.blue);
    });
  });

  // ─── reset ─────────────────────────────────────────────────────────────────

  group('GridManager.reset', () {
    test('clears all cells', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.place([(0, 0), (1, 1), (2, 2)], GelColor.red);
      gm.setCellType(0, 1, CellType.ice, iceLayer: 1);
      gm.reset();

      expect(gm.filledCells, 0);
      expect(gm.getCell(0, 1).type, CellType.normal);
    });
  });

  // ─── initFromSpecialCells ──────────────────────────────────────────────────

  group('GridManager.initFromSpecialCells', () {
    test('configures cells from map', () {
      final gm = GridManager(rows: 4, cols: 4);
      gm.initFromSpecialCells({
        (0, 0): const CellConfig(type: CellType.ice, iceLayer: 2),
        (1, 1): const CellConfig(type: CellType.stone),
        (2, 2):
            const CellConfig(type: CellType.locked, lockedColor: GelColor.red),
        (3, 3): const CellConfig(type: CellType.gravity),
      });

      expect(gm.getCell(0, 0).type, CellType.ice);
      expect(gm.getCell(0, 0).iceLayer, 2);
      expect(gm.getCell(1, 1).type, CellType.stone);
      expect(gm.getCell(2, 2).type, CellType.locked);
      expect(gm.getCell(2, 2).lockedColor, GelColor.red);
      expect(gm.getCell(3, 3).type, CellType.gravity);
    });

    test('ignores out-of-bounds entries', () {
      final gm = GridManager(rows: 3, cols: 3);
      gm.initFromSpecialCells({
        (5, 5): const CellConfig(type: CellType.stone),
      });
      // Hata firlatmamali
      expect(gm.totalCells, 9);
    });
  });

  // ─── Cell sinifi ───────────────────────────────────────────────────────────

  group('Cell', () {
    test('isEmpty returns true for normal empty cell', () {
      final cell = Cell();
      expect(cell.isEmpty, isTrue);
    });

    test('isEmpty returns false for stone cell', () {
      final cell = Cell(type: CellType.stone);
      expect(cell.isEmpty, isFalse);
    });

    test('isEmpty returns false for filled cell', () {
      final cell = Cell(color: GelColor.red);
      expect(cell.isEmpty, isFalse);
    });

    test('canAccept rejects stone cells', () {
      final cell = Cell(type: CellType.stone);
      expect(cell.canAccept(GelColor.red), isFalse);
    });

    test('canAccept rejects occupied cells', () {
      final cell = Cell(color: GelColor.blue);
      expect(cell.canAccept(GelColor.red), isFalse);
    });

    test('canAccept allows matching locked color', () {
      final cell = Cell(type: CellType.locked, lockedColor: GelColor.blue);
      expect(cell.canAccept(GelColor.blue), isTrue);
      expect(cell.canAccept(GelColor.red), isFalse);
    });

    test('canAccept allows any color on normal empty cell', () {
      final cell = Cell();
      expect(cell.canAccept(GelColor.red), isTrue);
      expect(cell.canAccept(GelColor.blue), isTrue);
    });

    test('crackIce reduces ice layer', () {
      final cell = Cell(type: CellType.ice, iceLayer: 2);
      cell.crackIce();
      expect(cell.iceLayer, 1);
      expect(cell.type, CellType.ice);
    });

    test('crackIce converts to normal when layer reaches 0', () {
      final cell = Cell(type: CellType.ice, iceLayer: 1);
      cell.crackIce();
      expect(cell.iceLayer, 0);
      expect(cell.type, CellType.normal);
    });

    test('crackIce does nothing on non-ice cell', () {
      final cell = Cell(type: CellType.normal);
      cell.crackIce();
      expect(cell.type, CellType.normal);
    });

    test('clearColor sets color to null', () {
      final cell = Cell(color: GelColor.red);
      cell.clearColor();
      expect(cell.color, isNull);
    });

    test('copy creates independent clone', () {
      final cell = Cell(color: GelColor.red, type: CellType.ice, iceLayer: 2);
      final clone = cell.copy();
      expect(clone.color, GelColor.red);
      expect(clone.type, CellType.ice);
      expect(clone.iceLayer, 2);

      clone.color = GelColor.blue;
      expect(cell.color, GelColor.red); // Original unchanged
    });
  });

  // ─── LineClearResult ───────────────────────────────────────────────────────

  group('LineClearResult', () {
    test('totalLines sums rows and cols', () {
      const result = LineClearResult(
        clearedRows: [0, 2],
        clearedCols: [1],
        clearedCellColors: {},
      );
      expect(result.totalLines, 3);
    });

    test('empty result has zero totalLines', () {
      const result = LineClearResult(
        clearedRows: [],
        clearedCols: [],
        clearedCellColors: {},
      );
      expect(result.totalLines, 0);
    });
  });
}
