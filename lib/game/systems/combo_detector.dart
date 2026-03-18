import '../../core/models/combo_types.dart';

export '../../core/models/combo_types.dart';

class ComboDetector {
  int _currentChain = 0;
  DateTime? _lastClearTime;

  static const Duration _comboWindow = Duration(milliseconds: 1500);

  ComboEvent registerClear(int linesCleared) {
    final now = DateTime.now();

    // Kombo penceresi dışındaysa zinciri sıfırla
    if (_lastClearTime != null &&
        now.difference(_lastClearTime!) > _comboWindow) {
      _currentChain = 0;
    }

    _currentChain += linesCleared;
    _lastClearTime = now;

    return _buildEvent(_currentChain);
  }

  void reset() {
    _currentChain = 0;
    _lastClearTime = null;
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
