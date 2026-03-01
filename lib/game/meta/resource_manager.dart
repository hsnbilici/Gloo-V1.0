export 'island_state.dart';
export 'character_state.dart';
export 'season_pass.dart';
export 'quests.dart';

/// Jel Enerjisi — meta-game kaynak sistemi.
///
/// Temizlenen her satır = 1 Jel Enerjisi.
/// Jel Enerjisi, ada binası, karakter gelişimi ve sezon pasında kullanılır.
class ResourceManager {
  ResourceManager({int initialEnergy = 0}) : _energy = initialEnergy;

  int _energy;
  int _totalEarnedLifetime = 0;

  int get energy => _energy;
  int get totalEarnedLifetime => _totalEarnedLifetime;

  void Function(int newEnergy)? onEnergyChanged;

  void earnFromLineClear(int lineCount) {
    _energy += lineCount;
    _totalEarnedLifetime += lineCount;
    onEnergyChanged?.call(_energy);
  }

  bool spend(int amount) {
    if (_energy < amount) return false;
    _energy -= amount;
    onEnergyChanged?.call(_energy);
    return true;
  }

  bool canAfford(int cost) => _energy >= cost;

  void setEnergy(int value) {
    _energy = value;
    onEnergyChanged?.call(_energy);
  }

  void setTotalEarned(int value) => _totalEarnedLifetime = value;
}
