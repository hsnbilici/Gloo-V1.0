import '../../core/models/combo_types.dart';

export '../../core/models/combo_types.dart';

class ComboDetector {
  int _currentChain = 0;

  ComboEvent registerClear(int linesCleared) {
    _currentChain += linesCleared;
    return _buildEvent(_currentChain);
  }

  /// Temizleme olmayan bir hamle yapıldığında kombo zincirini sıfırlar.
  void recordMoveWithoutClear() {
    _currentChain = 0;
  }

  /// Son kombo zincirinin büyüklüğü. Near-miss hesaplamasında kullanılır.
  int get lastComboSize => _currentChain;

  void reset() {
    _currentChain = 0;
  }

  ComboEvent _buildEvent(int chain) {
    if (chain <= 0) return ComboEvent.none;

    final (tier, multiplier) = switch (chain) {
      <= 2 => (ComboTier.small, 1.2),
      <= 4 => (ComboTier.medium, 1.5),
      <= 7 => (ComboTier.large, 2.0),
      _ => (ComboTier.epic, 3.0),
    };

    return ComboEvent(size: chain, tier: tier, multiplier: multiplier);
  }
}
