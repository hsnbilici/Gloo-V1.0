import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/shapes/gel_shape.dart';

void main() {
  group('Drag anchor — _dragAnchor logic', () {
    // Simulate _dragAnchor: center offset for 3+ cells, clamp for 1-2
    (int, int) dragAnchor(GelShape shape, int row, int col,
        {int gridRows = 10, int gridCols = 8}) {
      final maxRow = gridRows - shape.rowCount;
      final maxCol = gridCols - shape.colCount;
      if (shape.cellCount <= 2) {
        return (row.clamp(0, maxRow), col.clamp(0, maxCol));
      }
      final centeredRow = row - shape.rowCount ~/ 2;
      final centeredCol = col - shape.colCount ~/ 2;
      return (centeredRow.clamp(0, maxRow), centeredCol.clamp(0, maxCol));
    }

    // Simulate clampAnchor: no center offset (tap path)
    (int, int) tapAnchor(GelShape shape, int row, int col,
        {int gridRows = 10, int gridCols = 8}) {
      final maxRow = gridRows - shape.rowCount;
      final maxCol = gridCols - shape.colCount;
      return (row.clamp(0, maxRow), col.clamp(0, maxCol));
    }

    for (final shape in kAllShapes) {
      test('${shape.name}: drag anchor keeps all cells within 8x10 grid', () {
        const gridRows = 10;
        const gridCols = 8;

        // Test every possible pointer position
        for (int r = 0; r < gridRows; r++) {
          for (int c = 0; c < gridCols; c++) {
            final (ar, ac) = dragAnchor(shape, r, c);
            final cells = shape.at(ar, ac);

            for (final (cr, cc) in cells) {
              expect(cr, greaterThanOrEqualTo(0),
                  reason:
                      '${shape.name} at pointer ($r,$c) → anchor ($ar,$ac): cell ($cr,$cc) row < 0');
              expect(cr, lessThan(gridRows),
                  reason:
                      '${shape.name} at pointer ($r,$c) → anchor ($ar,$ac): cell ($cr,$cc) row >= $gridRows');
              expect(cc, greaterThanOrEqualTo(0),
                  reason:
                      '${shape.name} at pointer ($r,$c) → anchor ($ar,$ac): cell ($cr,$cc) col < 0');
              expect(cc, lessThan(gridCols),
                  reason:
                      '${shape.name} at pointer ($r,$c) → anchor ($ar,$ac): cell ($cr,$cc) col >= $gridCols');
            }
          }
        }
      });

      test('${shape.name}: drag and tap anchors produce valid placements', () {
        const gridRows = 10;
        const gridCols = 8;
        const midR = 5;
        const midC = 4;

        // Drag anchor at grid center
        final (dar, dac) = dragAnchor(shape, midR, midC);
        final dragCells = shape.at(dar, dac);
        for (final (cr, cc) in dragCells) {
          expect(cr, inInclusiveRange(0, gridRows - 1));
          expect(cc, inInclusiveRange(0, gridCols - 1));
        }

        // Tap anchor at grid center
        final (tar, tac) = tapAnchor(shape, midR, midC);
        final tapCells = shape.at(tar, tac);
        for (final (cr, cc) in tapCells) {
          expect(cr, inInclusiveRange(0, gridRows - 1));
          expect(cc, inInclusiveRange(0, gridCols - 1));
        }
      });

      test('${shape.name}: 1-2 cell shapes have same drag and tap anchor', () {
        if (shape.cellCount > 2) return; // skip 3-4 cell shapes

        const gridRows = 10;
        const gridCols = 8;

        for (int r = 0; r < gridRows; r++) {
          for (int c = 0; c < gridCols; c++) {
            final drag = dragAnchor(shape, r, c);
            final tap = tapAnchor(shape, r, c);
            expect(drag, equals(tap),
                reason:
                    '${shape.name} at ($r,$c): drag=$drag tap=$tap should be equal for small shapes');
          }
        }
      });
    }

    // Test rotated shapes too
    test('rotated shapes: all cells within grid after drag anchor', () {
      const gridRows = 10;
      const gridCols = 8;

      for (final shape in kAllShapes) {
        final rotated = shape.rotated();
        for (int r = 0; r < gridRows; r++) {
          for (int c = 0; c < gridCols; c++) {
            final (ar, ac) = dragAnchor(rotated, r, c);
            final cells = rotated.at(ar, ac);
            for (final (cr, cc) in cells) {
              expect(cr, inInclusiveRange(0, gridRows - 1),
                  reason: '${rotated.name} at ($r,$c) cell ($cr,$cc) row OOB');
              expect(cc, inInclusiveRange(0, gridCols - 1),
                  reason: '${rotated.name} at ($r,$c) cell ($cr,$cc) col OOB');
            }
          }
        }
      }
    });

    // Dynamic grid sizes (Level mode)
    test('all shapes valid on 6x6 grid (smallest level)', () {
      const gridRows = 6;
      const gridCols = 6;

      for (final shape in kAllShapes) {
        if (shape.rowCount > gridRows || shape.colCount > gridCols) continue;
        for (int r = 0; r < gridRows; r++) {
          for (int c = 0; c < gridCols; c++) {
            final (ar, ac) = dragAnchor(shape, r, c,
                gridRows: gridRows, gridCols: gridCols);
            final cells = shape.at(ar, ac);
            for (final (cr, cc) in cells) {
              expect(cr, inInclusiveRange(0, gridRows - 1));
              expect(cc, inInclusiveRange(0, gridCols - 1));
            }
          }
        }
      }
    });
  });
}
