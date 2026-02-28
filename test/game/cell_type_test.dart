import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/game/world/cell_type.dart';

void main() {
  // ─── CellType enum ─────────────────────────────────────────────────────

  group('CellType', () {
    test('has 6 values', () {
      expect(CellType.values.length, 6);
    });
  });

  // ─── Cell ───────────────────────────────────────────────────────────────

  group('Cell', () {
    test('default cell is normal and empty', () {
      final cell = Cell();
      expect(cell.type, CellType.normal);
      expect(cell.color, isNull);
      expect(cell.isEmpty, isTrue);
      expect(cell.iceLayer, 0);
      expect(cell.lockedColor, isNull);
    });

    test('cell with color is not empty', () {
      final cell = Cell(color: GelColor.red);
      expect(cell.isEmpty, isFalse);
    });

    test('stone cell is never empty', () {
      final cell = Cell(type: CellType.stone);
      expect(cell.isEmpty, isFalse);
    });

    test('canAccept returns false for stone', () {
      final cell = Cell(type: CellType.stone);
      expect(cell.canAccept(GelColor.red), isFalse);
    });

    test('canAccept returns false when cell has color', () {
      final cell = Cell(color: GelColor.red);
      expect(cell.canAccept(GelColor.blue), isFalse);
    });

    test('canAccept returns true for empty normal cell', () {
      final cell = Cell();
      expect(cell.canAccept(GelColor.red), isTrue);
    });

    test('locked cell accepts only matching color', () {
      final cell = Cell(type: CellType.locked, lockedColor: GelColor.red);
      expect(cell.canAccept(GelColor.red), isTrue);
      expect(cell.canAccept(GelColor.blue), isFalse);
    });

    test('ice cell accepts any color when empty', () {
      final cell = Cell(type: CellType.ice, iceLayer: 1);
      expect(cell.canAccept(GelColor.red), isTrue);
    });

    test('gravity cell accepts any color when empty', () {
      final cell = Cell(type: CellType.gravity);
      expect(cell.canAccept(GelColor.blue), isTrue);
    });

    test('rainbow cell accepts any color when empty', () {
      final cell = Cell(type: CellType.rainbow);
      expect(cell.canAccept(GelColor.yellow), isTrue);
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

    test('crackIce does nothing for non-ice cell', () {
      final cell = Cell(type: CellType.normal);
      cell.crackIce();
      expect(cell.type, CellType.normal);
    });

    test('clearColor sets color to null', () {
      final cell = Cell(color: GelColor.red);
      cell.clearColor();
      expect(cell.color, isNull);
    });

    test('copy creates deep copy', () {
      final cell = Cell(
        color: GelColor.red,
        type: CellType.ice,
        iceLayer: 2,
        lockedColor: GelColor.blue,
      );
      final copy = cell.copy();
      expect(copy.color, cell.color);
      expect(copy.type, cell.type);
      expect(copy.iceLayer, cell.iceLayer);
      expect(copy.lockedColor, cell.lockedColor);
      // Modify original, copy should not change
      cell.color = GelColor.yellow;
      expect(copy.color, GelColor.red);
    });

    test('toString includes type and color', () {
      final cell = Cell(color: GelColor.red, type: CellType.ice, iceLayer: 1);
      final str = cell.toString();
      expect(str, contains('ice'));
      expect(str, contains('red'));
    });
  });
}
