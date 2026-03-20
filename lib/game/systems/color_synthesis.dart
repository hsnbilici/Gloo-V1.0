import '../../core/constants/color_constants.dart';
import '../../core/utils/color_mixer.dart';

class SynthesisResult {
  const SynthesisResult({
    required this.resultColor,
    required this.positions,
    required this.isChain,
  });

  final GelColor resultColor;
  final List<(int row, int col)> positions;
  final bool isChain;
}

class ColorSynthesisSystem {
  /// Izgarada bitişik eşleşen renk çiftlerini tarar ve sentez listesi döner.
  ///
  /// [modifiedCells] verilirse yalnızca bu hücreler ve komşuları taranır
  /// (O(k) — k = değişen hücre sayısı). `null` ise tam ızgara taranır (O(n²)).
  List<SynthesisResult> findSyntheses(
    List<List<GelColor?>> grid, {
    Set<(int, int)>? modifiedCells,
  }) {
    final results = <SynthesisResult>[];
    final rows = grid.length;
    final cols = grid[0].length;

    if (modifiedCells != null) {
      // Değişen hücrelerin 3×3 komşuluğundaki yatay/dikey çiftleri tara
      final visited = <(int, int, int, int)>{};
      for (final (mr, mc) in modifiedCells) {
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final r = mr + dr;
            final c = mc + dc;
            if (r < 0 || r >= rows || c < 0 || c >= cols) continue;

            // Yatay çift: (r,c)-(r,c+1)
            if (c + 1 < cols && visited.add((r, c, r, c + 1))) {
              final a = grid[r][c];
              final b = grid[r][c + 1];
              if (a != null && b != null) {
                final mixed = ColorMixer.mix(a, b);
                if (mixed != null) {
                  results.add(SynthesisResult(
                    resultColor: mixed,
                    positions: [(r, c), (r, c + 1)],
                    isChain: false,
                  ));
                }
              }
            }

            // Dikey çift: (r,c)-(r+1,c)
            if (r + 1 < rows && visited.add((r, c, r + 1, c))) {
              final a = grid[r][c];
              final b = grid[r + 1][c];
              if (a != null && b != null) {
                final mixed = ColorMixer.mix(a, b);
                if (mixed != null) {
                  results.add(SynthesisResult(
                    resultColor: mixed,
                    positions: [(r, c), (r + 1, c)],
                    isChain: false,
                  ));
                }
              }
            }
          }
        }
      }
      return results;
    }

    // Tam ızgara taraması (modifiedCells == null)

    // Yatay tarama
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols - 1; c++) {
        final a = grid[r][c];
        final b = grid[r][c + 1];
        if (a == null || b == null) continue;

        final mixed = ColorMixer.mix(a, b);
        if (mixed != null) {
          results.add(SynthesisResult(
            resultColor: mixed,
            positions: [(r, c), (r, c + 1)],
            isChain: false,
          ));
        }
      }
    }

    // Dikey tarama
    for (int r = 0; r < rows - 1; r++) {
      for (int c = 0; c < cols; c++) {
        final a = grid[r][c];
        final b = grid[r + 1][c];
        if (a == null || b == null) continue;

        final mixed = ColorMixer.mix(a, b);
        if (mixed != null) {
          results.add(SynthesisResult(
            resultColor: mixed,
            positions: [(r, c), (r + 1, c)],
            isChain: false,
          ));
        }
      }
    }

    return results;
  }

  /// Izgara üzerinde sentezi uygular, etkilenen hücreleri döner.
  List<List<GelColor?>> applySynthesis(
    List<List<GelColor?>> grid,
    SynthesisResult synthesis,
  ) {
    final newGrid = grid.map((row) => List<GelColor?>.from(row)).toList();

    // İlk pozisyona sentez rengini yaz, diğerlerini temizle
    final first = synthesis.positions.first;
    newGrid[first.$1][first.$2] = synthesis.resultColor;

    for (int i = 1; i < synthesis.positions.length; i++) {
      final pos = synthesis.positions[i];
      newGrid[pos.$1][pos.$2] = null;
    }

    return newGrid;
  }
}
