import '../../core/constants/color_constants.dart';
import '../world/cell_type.dart';
import '../world/grid_manager.dart';
import 'level_data.dart';

/// Seviye ilerleme tanımları.
///
/// Kademeli öğrenme (scaffold learning):
/// - 1-20: Sadece normal hücreler, artan ızgara boyutu
/// - 21-50: Buz hücreleri (1 katman) tanıtımı
/// - 51-100: Buz (2 katman) + kilitli hücreler
/// - 101-200: Taş engeller + harita formları
/// - 200+: Yerçekimi + gökkuşağı + karma engeller
///
/// Her 10 seviyede 1 "breathing room" — kolay seviye (Retention için kritik).
class LevelProgression {
  /// Mevcut seviyeyi döner. Seviye yoksa null döner.
  static LevelData? getLevel(int levelId) {
    if (levelId < 1) return null;

    // Önceden tanımlı seviyeler
    if (levelId <= _predefinedLevels.length) {
      return _predefinedLevels[levelId - 1];
    }

    // Prosedürel üretim (50+ seviyeler)
    return _generateProceduralLevel(levelId);
  }

  /// Toplam tanımlı seviye sayısı.
  static int get totalPredefinedLevels => _predefinedLevels.length;

  /// Breathing room seviyesi mi? (Her 10 seviyede 1)
  static bool isBreathingRoom(int levelId) => levelId % 10 == 0;

  /// Seviye prosedürel olarak üretilir (50+ seviyeler için).
  static LevelData _generateProceduralLevel(int levelId) {
    // Zorluk eğrisi
    final difficulty = (levelId / 300).clamp(0.0, 1.0);

    // Breathing room: kolay seviye
    if (isBreathingRoom(levelId)) {
      return LevelData(
        id: levelId,
        rows: 8,
        cols: 6,
        targetScore: 300 + levelId * 5,
      );
    }

    // Izgara boyutu: kademeli artış
    final rows = (8 + (difficulty * 4).round()).clamp(6, 12);
    final cols = (6 + (difficulty * 4).round()).clamp(6, 10);

    // Özel hücreler
    final specialCells = <(int, int), CellConfig>{};

    // 51+: Buz hücreleri (2 katman)
    if (levelId > 50) {
      final iceCount = (difficulty * 6).round().clamp(1, 8);
      _addRandomSpecialCells(
        specialCells, rows, cols, iceCount,
        const CellConfig(type: CellType.ice, iceLayer: 2),
        levelId,
      );
    }
    // 21-50: Buz hücreleri (1 katman)
    else if (levelId > 20) {
      final iceCount = ((levelId - 20) / 10).round().clamp(1, 4);
      _addRandomSpecialCells(
        specialCells, rows, cols, iceCount,
        const CellConfig(type: CellType.ice, iceLayer: 1),
        levelId,
      );
    }

    // 51+: Kilitli hücreler
    if (levelId > 50) {
      final lockCount = (difficulty * 3).round().clamp(0, 4);
      final colors = [GelColor.red, GelColor.blue, GelColor.yellow, GelColor.white];
      for (int i = 0; i < lockCount; i++) {
        final color = colors[i % colors.length];
        _addRandomSpecialCells(
          specialCells, rows, cols, 1,
          CellConfig(type: CellType.locked, lockedColor: color),
          levelId * 100 + i,
        );
      }
    }

    // 101+: Taş engeller
    MapShape shape = MapShape.rectangle;
    if (levelId > 100) {
      final stoneCount = (difficulty * 5).round().clamp(1, 6);
      _addRandomSpecialCells(
        specialCells, rows, cols, stoneCount,
        const CellConfig(type: CellType.stone),
        levelId * 200,
      );

      // Harita formları (rastgele)
      final shapeIndex = levelId % 5;
      shape = MapShape.values[shapeIndex.clamp(0, MapShape.values.length - 1)];
    }

    // 200+: Yerçekimi hücreleri
    if (levelId > 200) {
      final gravCount = (difficulty * 3).round().clamp(1, 4);
      _addRandomSpecialCells(
        specialCells, rows, cols, gravCount,
        const CellConfig(type: CellType.gravity),
        levelId * 300,
      );
    }

    return LevelData(
      id: levelId,
      rows: rows,
      cols: cols,
      specialCells: specialCells,
      targetScore: 500 + levelId * 15,
      maxMoves: levelId > 100 ? 30 + (levelId ~/ 10) : null,
      shape: shape,
    );
  }

  /// Deterministik rastgele özel hücre yerleşimi.
  static void _addRandomSpecialCells(
    Map<(int, int), CellConfig> cells,
    int rows,
    int cols,
    int count,
    CellConfig config,
    int seed,
  ) {
    var s = seed;
    int added = 0;
    int attempts = 0;
    while (added < count && attempts < 100) {
      s = (s * 1103515245 + 12345) & 0x7fffffff; // LCG
      final r = s % rows;
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      final c = s % cols;
      if (!cells.containsKey((r, c))) {
        cells[(r, c)] = config;
        added++;
      }
      attempts++;
    }
  }
}

// ─── İlk 50 seviye tanımları ─────────────────────────────────────────────────

final List<LevelData> _predefinedLevels = [
  // --- Bölüm 1: Temel öğrenme (1-10) ---
  const LevelData(id: 1,  rows: 6,  cols: 6,  targetScore: 200,
      description: 'Jel bloklarını ızgaraya yerleştir!'),
  const LevelData(id: 2,  rows: 6,  cols: 6,  targetScore: 250),
  const LevelData(id: 3,  rows: 6,  cols: 6,  targetScore: 300),
  const LevelData(id: 4,  rows: 7,  cols: 6,  targetScore: 350),
  const LevelData(id: 5,  rows: 7,  cols: 7,  targetScore: 400),
  const LevelData(id: 6,  rows: 7,  cols: 7,  targetScore: 450),
  const LevelData(id: 7,  rows: 8,  cols: 7,  targetScore: 500),
  const LevelData(id: 8,  rows: 8,  cols: 7,  targetScore: 550),
  const LevelData(id: 9,  rows: 8,  cols: 8,  targetScore: 600),
  // Breathing room
  const LevelData(id: 10, rows: 6,  cols: 6,  targetScore: 300),

  // --- Bölüm 2: Standart oyun (11-20) ---
  const LevelData(id: 11, rows: 8,  cols: 8,  targetScore: 650),
  const LevelData(id: 12, rows: 8,  cols: 8,  targetScore: 700),
  const LevelData(id: 13, rows: 9,  cols: 8,  targetScore: 750),
  const LevelData(id: 14, rows: 9,  cols: 8,  targetScore: 800),
  const LevelData(id: 15, rows: 9,  cols: 8,  targetScore: 850),
  const LevelData(id: 16, rows: 10, cols: 8,  targetScore: 900),
  const LevelData(id: 17, rows: 10, cols: 8,  targetScore: 950),
  const LevelData(id: 18, rows: 10, cols: 8,  targetScore: 1000),
  const LevelData(id: 19, rows: 10, cols: 8,  targetScore: 1050),
  // Breathing room
  const LevelData(id: 20, rows: 8,  cols: 6,  targetScore: 500),

  // --- Bölüm 3: Buz tanıtımı (21-30) ---
  const LevelData(id: 21, rows: 8, cols: 8, targetScore: 800,
      description: 'Buz hücreleri! Satır temizleyerek kır.',
      specialCells: {(3, 3): CellConfig(type: CellType.ice, iceLayer: 1)}),
  const LevelData(id: 22, rows: 8, cols: 8, targetScore: 850,
      specialCells: {
        (2, 4): CellConfig(type: CellType.ice, iceLayer: 1),
        (5, 2): CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 23, rows: 9, cols: 8, targetScore: 900,
      specialCells: {
        (1, 1): CellConfig(type: CellType.ice, iceLayer: 1),
        (4, 6): CellConfig(type: CellType.ice, iceLayer: 1),
        (7, 3): CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 24, rows: 9, cols: 8, targetScore: 950,
      specialCells: {
        (0, 0): CellConfig(type: CellType.ice, iceLayer: 1),
        (0, 7): CellConfig(type: CellType.ice, iceLayer: 1),
        (8, 0): CellConfig(type: CellType.ice, iceLayer: 1),
        (8, 7): CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 25, rows: 9, cols: 8, targetScore: 1000),
  const LevelData(id: 26, rows: 10, cols: 8, targetScore: 1050,
      specialCells: {
        (2, 2): CellConfig(type: CellType.ice, iceLayer: 1),
        (2, 5): CellConfig(type: CellType.ice, iceLayer: 1),
        (7, 2): CellConfig(type: CellType.ice, iceLayer: 1),
        (7, 5): CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  LevelData(id: 27, rows: 10, cols: 8, targetScore: 1100,
      specialCells: {
        for (int c = 2; c <= 5; c++)
          (4, c): const CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  LevelData(id: 28, rows: 10, cols: 8, targetScore: 1150,
      specialCells: {
        for (int r = 3; r <= 6; r++)
          (r, 3): const CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 29, rows: 10, cols: 8, targetScore: 1200),
  // Breathing room
  const LevelData(id: 30, rows: 7, cols: 7, targetScore: 600),

  // --- Bölüm 4: Daha fazla buz (31-40) ---
  const LevelData(id: 31, rows: 10, cols: 8, targetScore: 1100,
      specialCells: {
        (1, 1): CellConfig(type: CellType.ice, iceLayer: 1),
        (1, 6): CellConfig(type: CellType.ice, iceLayer: 1),
        (5, 3): CellConfig(type: CellType.ice, iceLayer: 1),
        (5, 4): CellConfig(type: CellType.ice, iceLayer: 1),
        (8, 1): CellConfig(type: CellType.ice, iceLayer: 1),
        (8, 6): CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  LevelData(id: 32, rows: 10, cols: 8, targetScore: 1150,
      specialCells: {
        // Çapraz buz dizilimi
        for (int i = 0; i < 5; i++)
          (i * 2, i + 1): const CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 33, rows: 10, cols: 8, targetScore: 1200),
  LevelData(id: 34, rows: 10, cols: 8, targetScore: 1250,
      specialCells: {
        // Kenar buzları
        for (int c = 0; c < 8; c++)
          (0, c): const CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  LevelData(id: 35, rows: 10, cols: 8, targetScore: 1300,
      specialCells: {
        for (int r = 0; r < 10; r++)
          (r, 0): const CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 36, rows: 10, cols: 8, targetScore: 1350),
  LevelData(id: 37, rows: 10, cols: 8, targetScore: 1400,
      specialCells: {
        // 3x3 buz bloğu ortada
        for (int r = 3; r <= 5; r++)
          for (int c = 2; c <= 4; c++)
            (r, c): const CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 38, rows: 10, cols: 8, targetScore: 1450),
  LevelData(id: 39, rows: 10, cols: 8, targetScore: 1500,
      specialCells: {
        // Satranç tahtası deseni
        for (int r = 2; r <= 7; r++)
          for (int c = 1; c <= 6; c++)
            if ((r + c) % 2 == 0)
              (r, c): const CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  // Breathing room
  const LevelData(id: 40, rows: 8, cols: 6, targetScore: 700),

  // --- Bölüm 5: Karmaşıklık artışı (41-50) ---
  const LevelData(id: 41, rows: 10, cols: 8, targetScore: 1300,
      maxMoves: 40,
      specialCells: {
        (2, 2): CellConfig(type: CellType.ice, iceLayer: 1),
        (2, 5): CellConfig(type: CellType.ice, iceLayer: 1),
        (7, 2): CellConfig(type: CellType.ice, iceLayer: 1),
        (7, 5): CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  LevelData(id: 42, rows: 10, cols: 8, targetScore: 1350,
      maxMoves: 38,
      specialCells: {
        for (int c = 0; c < 8; c += 2)
          (4, c): const CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 43, rows: 10, cols: 8, targetScore: 1400, maxMoves: 36),
  const LevelData(id: 44, rows: 10, cols: 8, targetScore: 1450,
      maxMoves: 35,
      specialCells: {
        // X şeklinde buz
        (2, 2): CellConfig(type: CellType.ice, iceLayer: 1),
        (2, 5): CellConfig(type: CellType.ice, iceLayer: 1),
        (4, 3): CellConfig(type: CellType.ice, iceLayer: 1),
        (4, 4): CellConfig(type: CellType.ice, iceLayer: 1),
        (6, 2): CellConfig(type: CellType.ice, iceLayer: 1),
        (6, 5): CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 45, rows: 10, cols: 8, targetScore: 1500, maxMoves: 34),
  LevelData(id: 46, rows: 10, cols: 8, targetScore: 1550,
      maxMoves: 33,
      specialCells: {
        for (int r = 1; r <= 8; r += 3)
          for (int c = 1; c <= 6; c += 3)
            (r, c): const CellConfig(type: CellType.ice, iceLayer: 1),
      }),
  const LevelData(id: 47, rows: 10, cols: 8, targetScore: 1600, maxMoves: 32),
  LevelData(id: 48, rows: 10, cols: 8, targetScore: 1650,
      maxMoves: 30,
      specialCells: {
        // Üst ve alt buz kenarları
        for (int c = 0; c < 8; c++) ...<(int, int), CellConfig>{
          (0, c): const CellConfig(type: CellType.ice, iceLayer: 1),
          (9, c): const CellConfig(type: CellType.ice, iceLayer: 1),
        },
      }),
  const LevelData(id: 49, rows: 10, cols: 8, targetScore: 1700, maxMoves: 28),
  // Breathing room — Bölüm sonu
  const LevelData(id: 50, rows: 8, cols: 7, targetScore: 800),
];
