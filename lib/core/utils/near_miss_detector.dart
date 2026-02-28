import 'dart:math' as math;

import '../constants/color_constants.dart';
import '../constants/game_constants.dart';

enum NearMissType { standard, critical }

class NearMissEvent {
  const NearMissEvent({required this.score, required this.type});

  final double score;
  final NearMissType type;

  bool get isCritical => type == NearMissType.critical;
}

class NearMissDetector {
  NearMissEvent? evaluate({
    required int filledCells,
    required int totalCells,
    required int lastComboSize,
    required int availableMoves,
    required List<List<GelColor?>> grid,
  }) {
    final fillRatio = filledCells / totalCells;
    final normalizedCombo = _normalizeCombo(lastComboSize);
    final colorDiversity = _colorDiversityEntropy(grid);
    final normalizedMoves = _normalizeMoves(availableMoves);

    final score = (fillRatio * 0.4) +
        (normalizedCombo * 0.3) +
        ((1.0 - colorDiversity) * 0.2) +
        (normalizedMoves * 0.1);

    if (score > GameConstants.nearMissThreshold) {
      return NearMissEvent(
        score: score,
        type: score > GameConstants.criticalNearMissThreshold
            ? NearMissType.critical
            : NearMissType.standard,
      );
    }

    return null;
  }

  /// Shannon entropy ile renk homojenliğini ölçer.
  /// Yüksek entropy = çok çeşitli renkler = düşük near-miss riski.
  double _colorDiversityEntropy(List<List<GelColor?>> grid) {
    final counts = <GelColor, int>{};

    for (final row in grid) {
      for (final cell in row) {
        if (cell != null) {
          counts[cell] = (counts[cell] ?? 0) + 1;
        }
      }
    }

    if (counts.isEmpty) return 1.0;

    final total = counts.values.fold(0, (a, b) => a + b);
    double entropy = 0.0;

    for (final count in counts.values) {
      final p = count / total;
      if (p > 0) entropy -= p * math.log(p);
    }

    // Normalize: maksimum entropy = log(renk sayısı)
    final maxEntropy = math.log(GelColor.values.length);
    return (entropy / maxEntropy).clamp(0.0, 1.0);
  }

  double _normalizeCombo(int comboSize) {
    // 5+ kombo maksimum puan
    return (comboSize / 5.0).clamp(0.0, 1.0);
  }

  double _normalizeMoves(int availableMoves) {
    // Az hamle = yüksek near-miss riski. 0 hamle = 1.0
    if (availableMoves == 0) return 1.0;
    return (1.0 - (availableMoves / 10.0)).clamp(0.0, 1.0);
  }
}
