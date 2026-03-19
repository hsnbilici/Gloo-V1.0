import 'dart:math';

import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../pvp/matchmaking.dart';
import 'cell_type.dart';

/// Geriye uyumluluk: eski kod Grid tipini kullanıyorsa GelColor? listesi döner.
typedef Grid = List<List<GelColor?>>;

class LineClearResult {
  const LineClearResult({
    required this.clearedRows,
    required this.clearedCols,
    required this.clearedCellColors,
    this.crackedIceCells = const [],
  });

  final List<int> clearedRows;
  final List<int> clearedCols;

  /// Silinmeden önce yakalanan (satır, sütun) → renk haritası.
  final Map<(int, int), GelColor> clearedCellColors;

  /// Buz katmanı kırılan hücrelerin pozisyonları.
  final List<(int, int)> crackedIceCells;
  int get totalLines => clearedRows.length + clearedCols.length;
}

class GridManager {
  GridManager({int? rows, int? cols})
      : _rows = rows ?? GameConstants.gridRows,
        _cols = cols ?? GameConstants.gridCols {
    _initGrid();
  }

  final int _rows;
  final int _cols;
  late List<List<Cell>> _cells;

  int get rows => _rows;
  int get cols => _cols;

  /// Hücre matrisine doğrudan erişim.
  List<List<Cell>> get cells => _cells;

  /// Önbelleklenmiş GelColor? grid — mutasyon sonrası invalidate edilir.
  Grid? _cachedGrid;

  /// Geriye uyumluluk: GelColor? tabanlı grid döner (eski kodla çalışır).
  Grid get grid {
    _cachedGrid ??=
        _cells.map((row) => row.map((c) => c.color).toList()).toList();
    return _cachedGrid!;
  }

  void _invalidateCache() {
    _cachedGrid = null;
  }

  int get filledCells {
    int count = 0;
    for (final row in _cells) {
      for (final cell in row) {
        if (cell.color != null) count++;
      }
    }
    return count;
  }

  int get totalCells {
    int count = 0;
    for (final row in _cells) {
      for (final cell in row) {
        if (cell.type != CellType.stone) count++;
      }
    }
    return count;
  }

  void _initGrid() {
    _cells = List.generate(
      _rows,
      (_) => List.generate(_cols, (_) => Cell()),
    );
  }

  /// Belirli bir hücreyi döner.
  Cell getCell(int row, int col) => _cells[row][col];

  bool isCellEmpty(int row, int col) => _cells[row][col].isEmpty;

  /// Verilen hücrelere yerleştirme yapılabilir mi?
  /// Stone hücreler ve dolu hücreler reddedilir.
  /// Locked hücreler yalnızca doğru renkle kabul eder.
  bool canPlace(List<(int, int)> cells, [GelColor? color]) {
    for (final (r, c) in cells) {
      if (r < 0 || r >= _rows) return false;
      if (c < 0 || c >= _cols) return false;
      final cell = _cells[r][c];
      if (color != null) {
        if (!cell.canAccept(color)) return false;
      } else {
        if (!cell.isEmpty) return false;
      }
    }
    return true;
  }

  void place(List<(int, int)> cells, GelColor color) {
    for (final (r, c) in cells) {
      _cells[r][c].color = color;
    }
    _invalidateCache();
  }

  LineClearResult detectAndClear() {
    final clearedRows = <int>[];
    final clearedCols = <int>[];

    // Tam satırları bul (stone hücreler dahil değil — sadece oynanabilir hücreler)
    for (int r = 0; r < _rows; r++) {
      bool full = true;
      bool hasPlayable = false;
      for (int c = 0; c < _cols; c++) {
        final cell = _cells[r][c];
        if (cell.type == CellType.stone) continue;
        hasPlayable = true;
        if (cell.color == null) {
          full = false;
          break;
        }
      }
      if (full && hasPlayable) clearedRows.add(r);
    }

    // Tam sütunları bul
    for (int c = 0; c < _cols; c++) {
      bool full = true;
      bool hasPlayable = false;
      for (int r = 0; r < _rows; r++) {
        final cell = _cells[r][c];
        if (cell.type == CellType.stone) continue;
        hasPlayable = true;
        if (cell.color == null) {
          full = false;
          break;
        }
      }
      if (full && hasPlayable) clearedCols.add(c);
    }

    // Silinmeden önce renkleri yakala (burst animasyonu için)
    final clearedCellColors = <(int, int), GelColor>{};
    final crackedIceCells = <(int, int)>[];

    for (final r in clearedRows) {
      for (int c = 0; c < _cols; c++) {
        final cell = _cells[r][c];
        if (cell.type == CellType.stone) continue;
        if (cell.color != null) clearedCellColors[(r, c)] = cell.color!;
      }
    }
    for (final c in clearedCols) {
      for (int r = 0; r < _rows; r++) {
        final cell = _cells[r][c];
        if (cell.type == CellType.stone) continue;
        if (cell.color != null) clearedCellColors[(r, c)] = cell.color!;
      }
    }

    // Temizle — buz hücreleri kırılır, normal hücreler silinir
    for (final (r, c) in clearedCellColors.keys) {
      final cell = _cells[r][c];
      if (cell.type == CellType.ice && cell.iceLayer > 0) {
        cell.crackIce();
        cell.clearColor();
        crackedIceCells.add((r, c));
      } else {
        cell.clearColor();
      }
    }

    if (clearedCellColors.isNotEmpty) _invalidateCache();

    return LineClearResult(
      clearedRows: clearedRows,
      clearedCols: clearedCols,
      clearedCellColors: clearedCellColors,
      crackedIceCells: crackedIceCells,
    );
  }

  /// Yerçekimi uygula — gravity hücrelerin üstündeki bloklar aşağı düşer.
  List<(int, int, int, int)> applyGravity() {
    final moves = <(int, int, int, int)>[]; // (fromR, fromC, toR, toC)

    for (int c = 0; c < _cols; c++) {
      // Alttan yukarı tara — gravity hücrelerini bul
      for (int r = _rows - 1; r >= 0; r--) {
        if (_cells[r][c].type != CellType.gravity) continue;

        // Bu gravity hücresinin üstündeki boşlukları doldur
        int writeRow = r;
        for (int scanRow = r; scanRow >= 0; scanRow--) {
          final scanCell = _cells[scanRow][c];
          if (scanCell.type == CellType.stone) break;
          if (scanCell.color != null && scanRow != writeRow) {
            moves.add((scanRow, c, writeRow, c));
            _cells[writeRow][c].color = scanCell.color;
            scanCell.clearColor();
          }
          if (_cells[writeRow][c].color != null) writeRow--;
        }
      }
    }
    if (moves.isNotEmpty) _invalidateCache();
    return moves;
  }

  void setCell(int row, int col, GelColor? color) {
    _cells[row][col].color = color;
    _invalidateCache();
  }

  /// Hücre türünü ayarla (seviye yükleme için).
  void setCellType(int row, int col, CellType type,
      {int iceLayer = 0, GelColor? lockedColor}) {
    final cell = _cells[row][col];
    cell.type = type;
    cell.iceLayer = iceLayer;
    cell.lockedColor = lockedColor;
  }

  /// Belirli hücreleri stone olarak işaretle (harita formu için).
  void setStone(int row, int col) {
    _cells[row][col]
      ..type = CellType.stone
      ..color = null;
    _invalidateCache();
  }

  void reset() {
    _initGrid();
    _invalidateCache();
  }

  /// Seviye verisinden ızgarayı yapılandır.
  void initFromSpecialCells(Map<(int, int), CellConfig> specialCells) {
    for (final entry in specialCells.entries) {
      final (r, c) = entry.key;
      final config = entry.value;
      if (r >= 0 && r < _rows && c >= 0 && c < _cols) {
        setCellType(r, c, config.type,
            iceLayer: config.iceLayer, lockedColor: config.lockedColor);
      }
    }
  }

  /// 3×3 alan temizle (Bomb power-up için). Merkez hücresinden çevreyi siler.
  Map<(int, int), GelColor> clearArea(
      int centerRow, int centerCol, int radius) {
    final cleared = <(int, int), GelColor>{};
    for (int r = centerRow - radius; r <= centerRow + radius; r++) {
      for (int c = centerCol - radius; c <= centerCol + radius; c++) {
        if (r < 0 || r >= _rows || c < 0 || c >= _cols) continue;
        final cell = _cells[r][c];
        if (cell.type == CellType.stone) continue;
        if (cell.color != null) {
          cleared[(r, c)] = cell.color!;
          cell.clearColor();
          if (cell.type == CellType.ice) cell.crackIce();
        }
      }
    }
    if (cleared.isNotEmpty) _invalidateCache();
    return cleared;
  }

  /// Son yerleştirmeyi geri al (Undo power-up için).
  void undoPlace(List<(int, int)> cells) {
    for (final (r, c) in cells) {
      _cells[r][c].clearColor();
    }
    _invalidateCache();
  }

  // ── PvP: Rakipten gelen engel uygulama ──────────────────────────────────

  static final _rng = Random();

  /// Rastgele bos bir hucreye engel uygular (PvP duel — rakipten gelen).
  void applyRandomObstacle(ObstacleType obstacleType) {
    // Bos hucreleri bul
    final emptyCells = <(int, int)>[];
    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        if (_cells[r][c].isEmpty && _cells[r][c].type == CellType.normal) {
          emptyCells.add((r, c));
        }
      }
    }
    if (emptyCells.isEmpty) return;

    final (row, col) = emptyCells[_rng.nextInt(emptyCells.length)];
    switch (obstacleType) {
      case ObstacleType.ice:
        setCellType(row, col, CellType.ice, iceLayer: 1);
      case ObstacleType.locked:
        final randomColor = kPrimaryColors[_rng.nextInt(kPrimaryColors.length)];
        setCellType(row, col, CellType.locked, lockedColor: randomColor);
      case ObstacleType.stone:
        setStone(row, col);
    }
  }
}

/// Seviye verisi için hücre konfigürasyonu.
class CellConfig {
  const CellConfig({
    required this.type,
    this.iceLayer = 0,
    this.lockedColor,
  });

  final CellType type;
  final int iceLayer;
  final GelColor? lockedColor;
}
