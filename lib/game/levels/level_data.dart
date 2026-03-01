import '../../core/constants/color_constants.dart';
import '../world/cell_type.dart';
import '../world/grid_manager.dart';

/// Harita formu — ızgaranın şeklini belirler.
enum MapShape {
  /// Standart dikdörtgen.
  rectangle,

  /// Kenarlardaki köşeler taş ile kapatılır → elmas.
  diamond,

  /// Ortadaki artı alan aktif, kenarlar taş.
  cross,

  /// L formunda aktif alan.
  lShape,

  /// Dar uzun geçit.
  corridor,
}

/// Tek bir seviyenin tanımı.
class LevelData {
  const LevelData({
    required this.id,
    this.rows = 10,
    this.cols = 8,
    this.specialCells = const {},
    this.availableColors,
    required this.targetScore,
    this.maxMoves,
    this.shape = MapShape.rectangle,
    this.description,
  });

  /// Seviye numarası (1-tabanlı).
  final int id;

  /// Izgara boyutları.
  final int rows;
  final int cols;

  /// Özel hücreler: pozisyon → konfigürasyon.
  final Map<(int, int), CellConfig> specialCells;

  /// Kullanılabilir renkler (null → tüm birincil renkler).
  final List<GelColor>? availableColors;

  /// Seviye geçiş skoru.
  final int targetScore;

  /// Hamle sınırı (null → sınırsız).
  final int? maxMoves;

  /// Harita formu.
  final MapShape shape;

  /// Seviye açıklaması (opsiyonel, öğretici seviyeler için).
  final String? description;

  /// Harita formuna göre stone hücrelerini hesaplar.
  Map<(int, int), CellConfig> computeShapeCells() {
    final stones = <(int, int), CellConfig>{};
    const stoneConfig = CellConfig(type: CellType.stone);

    switch (shape) {
      case MapShape.rectangle:
        break; // Hiç stone yok

      case MapShape.diamond:
        // Elmas formu: her satırda kenarlardaki hücreler stone
        for (int r = 0; r < rows; r++) {
          final dist = (r - rows ~/ 2).abs();
          final margin = (dist * cols / rows).round();
          for (int c = 0; c < margin; c++) {
            stones[(r, c)] = stoneConfig;
            stones[(r, cols - 1 - c)] = stoneConfig;
          }
        }

      case MapShape.cross:
        // Artı formu: 4 köşe bloğu stone
        final armWidth = (cols * 0.35).round();
        final armHeight = (rows * 0.35).round();
        for (int r = 0; r < rows; r++) {
          for (int c = 0; c < cols; c++) {
            final inVerticalArm =
                c >= (cols - armWidth) ~/ 2 && c < (cols + armWidth) ~/ 2;
            final inHorizontalArm =
                r >= (rows - armHeight) ~/ 2 && r < (rows + armHeight) ~/ 2;
            if (!inVerticalArm && !inHorizontalArm) {
              stones[(r, c)] = stoneConfig;
            }
          }
        }

      case MapShape.lShape:
        // L formu: sağ üst köşe stone
        final cutRows = (rows * 0.4).round();
        final cutCols = (cols * 0.4).round();
        for (int r = 0; r < cutRows; r++) {
          for (int c = cols - cutCols; c < cols; c++) {
            stones[(r, c)] = stoneConfig;
          }
        }

      case MapShape.corridor:
        // Dar geçit: sol ve sağ kenarlar stone (orta 3-4 sütun aktif)
        final corridorWidth = 4.clamp(2, cols - 2);
        final margin = (cols - corridorWidth) ~/ 2;
        for (int r = 0; r < rows; r++) {
          for (int c = 0; c < margin; c++) {
            stones[(r, c)] = stoneConfig;
          }
          for (int c = cols - margin; c < cols; c++) {
            stones[(r, c)] = stoneConfig;
          }
        }
    }

    return stones;
  }

  /// Tüm özel hücreleri birleştirir (harita formu + seviye tanımı).
  Map<(int, int), CellConfig> allSpecialCells() {
    final merged = <(int, int), CellConfig>{};
    merged.addAll(computeShapeCells());
    merged.addAll(specialCells); // Seviye tanımı öncelik alır
    return merged;
  }
}
