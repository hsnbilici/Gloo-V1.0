import 'dart:math';

import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../world/grid_manager.dart';

/// Tek bir oyun parçasını tanımlar: hücre koordinatları ve görünen ad.
/// Koordinatlar (0,0) sol-üst köşeye göre offset'tir.
class GelShape {
  const GelShape({required this.cells, required this.name});

  final List<(int row, int col)> cells;
  final String name;

  /// Sınırlayıcı kutu yüksekliği (satır sayısı).
  int get rowCount => cells.fold(0, (acc, c) => c.$1 > acc ? c.$1 : acc) + 1;

  /// Sınırlayıcı kutu genişliği (sütun sayısı).
  int get colCount => cells.fold(0, (acc, c) => c.$2 > acc ? c.$2 : acc) + 1;

  /// Hücre sayısı.
  int get cellCount => cells.length;

  /// Parçanın tüm hücrelerini (anchorRow, anchorCol) ankerine göre döner.
  List<(int, int)> at(int anchorRow, int anchorCol) =>
      [for (final c in cells) (c.$1 + anchorRow, c.$2 + anchorCol)];

  /// Şekli 90 derece saat yönünde döndürür.
  GelShape rotated() {
    final rotated = [for (final c in cells) (c.$2, -c.$1)];
    // Negatif offset'leri düzelt — tüm koordinatları 0'a normalize et
    final minRow = rotated.fold(0, (acc, c) => c.$1 < acc ? c.$1 : acc);
    final minCol = rotated.fold(0, (acc, c) => c.$2 < acc ? c.$2 : acc);
    return GelShape(
      cells: [for (final c in rotated) (c.$1 - minRow, c.$2 - minCol)],
      name: '${name}_r',
    );
  }
}

/// Şekil büyüklük kategorisi (RNG ağırlıklandırması için).
enum ShapeSize { small, medium, large }

/// Oyunda kullanılan tüm şekiller.
const List<GelShape> kAllShapes = [
  // 1 hücre
  GelShape(cells: [(0, 0)], name: 'dot'),

  // 2 hücre
  GelShape(cells: [(0, 0), (0, 1)], name: 'h2'),
  GelShape(cells: [(0, 0), (1, 0)], name: 'v2'),

  // 3 hücre — yatay / dikey
  GelShape(cells: [(0, 0), (0, 1), (0, 2)], name: 'h3'),
  GelShape(cells: [(0, 0), (1, 0), (2, 0)], name: 'v3'),

  // 3 hücre — L varyantları
  GelShape(cells: [(0, 0), (1, 0), (1, 1)], name: 'l3a'),
  GelShape(cells: [(0, 1), (1, 0), (1, 1)], name: 'l3b'),
  GelShape(cells: [(0, 0), (0, 1), (1, 0)], name: 'l3c'),
  GelShape(cells: [(0, 0), (0, 1), (1, 1)], name: 'l3d'),

  // 4 hücre — 2×2 kare
  GelShape(cells: [(0, 0), (0, 1), (1, 0), (1, 1)], name: 'sq'),

  // 4 hücre — yatay / dikey çubuk
  GelShape(cells: [(0, 0), (0, 1), (0, 2), (0, 3)], name: 'h4'),
  GelShape(cells: [(0, 0), (1, 0), (2, 0), (3, 0)], name: 'v4'),

  // 4 hücre — T
  GelShape(cells: [(0, 0), (0, 1), (0, 2), (1, 1)], name: 'T'),

  // 4 hücre — L / J
  GelShape(cells: [(0, 0), (1, 0), (2, 0), (2, 1)], name: 'L'),
  GelShape(cells: [(0, 1), (1, 1), (2, 0), (2, 1)], name: 'J'),

  // 4 hücre — S / Z
  GelShape(cells: [(0, 0), (0, 1), (1, 1), (1, 2)], name: 'S'),
  GelShape(cells: [(0, 1), (0, 2), (1, 0), (1, 1)], name: 'Z'),
];

/// Küçük şekiller (1-2 hücre).
final List<GelShape> kSmallShapes = [
  for (final s in kAllShapes)
    if (s.cellCount <= 2) s
];

/// Orta şekiller (3 hücre).
final List<GelShape> kMediumShapes = [
  for (final s in kAllShapes)
    if (s.cellCount == 3) s
];

/// Büyük şekiller (4+ hücre).
final List<GelShape> kLargeShapes = [
  for (final s in kAllShapes)
    if (s.cellCount >= 4) s
];

/// Rastgele el (hand) oluşturucu — Smart Seed RNG destekli.
class ShapeGenerator {
  static final _rng = Random();

  // ─── Merhamet Mekanizması durumu ──────────────────────────────────────────
  static int _consecutiveLosses = 0;
  static int _movesSinceLastClear = 0;

  static void recordLoss() => _consecutiveLosses++;
  static void recordWin() => _consecutiveLosses = 0;
  static void recordClear() => _movesSinceLastClear = 0;
  static void recordMoveWithoutClear() => _movesSinceLastClear++;

  static (GelShape, GelColor) _randomPiece() {
    final shape = kAllShapes[_rng.nextInt(kAllShapes.length)];
    final color = kPrimaryColors[_rng.nextInt(kPrimaryColors.length)];
    return (shape, color);
  }

  /// [GameConstants.shapesInHand] adet rastgele parça üretir.
  static List<(GelShape, GelColor)> generateHand() =>
      List.generate(GameConstants.shapesInHand, (_) => _randomPiece());

  /// Akıllı el üretimi: zorluk, adalet ve merhamet mekanizması dahil.
  static List<(GelShape, GelColor)> generateSmartHand({
    required GridManager gridManager,
    required double difficulty,
    int gamesPlayed = 0,
  }) {
    // Merhamet: 3 ardışık kayıp → zorluk düşürme
    var effectiveDifficulty = difficulty;
    if (_consecutiveLosses >= 3) {
      effectiveDifficulty *= 0.7;
    }

    // Merhamet: 5 hamle temizleme yok → kurtarıcı el
    final forceMercy = _movesSinceLastClear >= 5;

    final candidates = <(GelShape, GelColor)>[];
    final grid = gridManager.grid;

    for (int i = 0; i < GameConstants.shapesInHand; i++) {
      if (forceMercy && i == 0) {
        // Kurtarıcı şekil: küçük + sentez dostu renk
        final shape = kSmallShapes[_rng.nextInt(kSmallShapes.length)];
        final color = _weightedRandomColor(grid);
        candidates.add((shape, color));
      } else {
        final shape = _weightedRandomShape(effectiveDifficulty);
        final color = _weightedRandomColor(grid);
        candidates.add((shape, color));
      }
    }

    // Adalet kontrolü: en az 1 yerleştirilebilir şekil garantisi
    if (!_canAnyBePlaced(gridManager, candidates)) {
      candidates[0] = _findPlaceableShape(gridManager);
    }

    return candidates;
  }

  /// Ağırlıklı rastgele şekil seçimi (zorluğa göre).
  static GelShape _weightedRandomShape(double difficulty) {
    final roll = _rng.nextDouble();

    // Zorluk 0.0-0.3: %60 küçük, %30 orta, %10 büyük
    // Zorluk 0.3-0.7: %30 küçük, %40 orta, %30 büyük
    // Zorluk 0.7-1.0: %10 küçük, %30 orta, %60 büyük
    final (smallW, mediumW) = switch (difficulty) {
      < 0.3 => (0.60, 0.30),
      < 0.7 => (0.30, 0.40),
      _ => (0.10, 0.30),
    };

    late final List<GelShape> pool;
    if (roll < smallW) {
      pool = kSmallShapes;
    } else if (roll < smallW + mediumW) {
      pool = kMediumShapes;
    } else {
      pool = kLargeShapes;
    }

    return pool[_rng.nextInt(pool.length)];
  }

  /// Izgaradaki renk dağılımına göre ağırlıklı renk seçimi.
  /// Az bulunan birincil renkler daha yüksek ağırlık alır → sentez fırsatı.
  static GelColor _weightedRandomColor(Grid grid) {
    // Izgaradaki renk dağılımını analiz et
    final colorCounts = <GelColor, int>{};
    for (final color in kPrimaryColors) {
      colorCounts[color] = 0;
    }
    for (final row in grid) {
      for (final cell in row) {
        if (cell != null && kPrimaryColors.contains(cell)) {
          colorCounts[cell] = (colorCounts[cell] ?? 0) + 1;
        }
      }
    }

    final totalColors = colorCounts.values.fold(0, (a, b) => a + b);
    if (totalColors == 0) {
      // Boş ızgara — tamamen rastgele
      return kPrimaryColors[_rng.nextInt(kPrimaryColors.length)];
    }

    // Ters ağırlıklandırma: az bulunan renklere daha yüksek şans
    final weights = <GelColor, double>{};
    for (final entry in colorCounts.entries) {
      final ratio = entry.value / totalColors;
      // 1 - ratio → az olan renk yüksek ağırlık alır
      // 0.3 base → tamamen yok olmayı engeller
      weights[entry.key] = 0.3 + (1.0 - ratio) * 0.7;
    }

    // Ağırlıklı rastgele seçim
    final totalWeight = weights.values.fold(0.0, (a, b) => a + b);
    var roll = _rng.nextDouble() * totalWeight;
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll <= 0) return entry.key;
    }

    return kPrimaryColors.last;
  }

  /// Eldeki şekillerden herhangi biri ızgaraya yerleştirilebilir mi?
  static bool _canAnyBePlaced(
    GridManager gridManager,
    List<(GelShape, GelColor)> candidates,
  ) {
    for (final (shape, color) in candidates) {
      final maxR = gridManager.rows - shape.rowCount;
      final maxC = gridManager.cols - shape.colCount;
      for (int r = 0; r <= maxR; r++) {
        for (int c = 0; c <= maxC; c++) {
          if (gridManager.canPlace(shape.at(r, c), color)) return true;
        }
      }
    }
    return false;
  }

  /// Izgaraya yerleştirilebilir garanti bir şekil bul.
  static (GelShape, GelColor) _findPlaceableShape(GridManager gridManager) {
    // Önce küçük şekillerden dene
    for (final pool in [kSmallShapes, kMediumShapes, kLargeShapes]) {
      final shuffled = List<GelShape>.from(pool)..shuffle(_rng);
      for (final shape in shuffled) {
        for (final color in kPrimaryColors) {
          final maxR = gridManager.rows - shape.rowCount;
          final maxC = gridManager.cols - shape.colCount;
          for (int r = 0; r <= maxR; r++) {
            for (int c = 0; c <= maxC; c++) {
              if (gridManager.canPlace(shape.at(r, c), color)) {
                return (shape, color);
              }
            }
          }
        }
      }
    }
    // Fallback: dot her zaman sığar
    return (
      kAllShapes.first,
      kPrimaryColors[_rng.nextInt(kPrimaryColors.length)]
    );
  }

  /// Zorluk eğrisi hesapla.
  static double getDifficulty({required int score, int gamesPlayed = 0}) {
    final baseDifficulty = (score / 5000).clamp(0.0, 0.8);
    final experienceBonus = (gamesPlayed / 50).clamp(0.0, 0.2);
    return (baseDifficulty + experienceBonus).clamp(0.0, 0.95);
  }

  /// Günün tarihinden türetilen seed ile deterministik el oluşturur.
  /// Aynı seed → aynı el (tüm oyuncular aynı başlangıç parçalarını görür).
  static List<(GelShape, GelColor)> generateSeededHand(int seed) {
    final rng = Random(seed);
    return List.generate(
      GameConstants.shapesInHand,
      (_) {
        final shape = kAllShapes[rng.nextInt(kAllShapes.length)];
        final color = kPrimaryColors[rng.nextInt(kPrimaryColors.length)];
        return (shape, color);
      },
    );
  }

  /// Sonraki seeded el — Daily Puzzle'da hamle bazlı deterministik RNG.
  static List<(GelShape, GelColor)> generateNextSeededHand({
    required int baseSeed,
    required int handIndex,
    required int moveCount,
  }) {
    final seed = baseSeed * 31 + handIndex * 7 + moveCount;
    return generateSeededHand(seed);
  }

  /// Bugünün tarihinden seed üretir: yyyymmdd formatında tamsayı.
  static int todaySeed() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }
}
