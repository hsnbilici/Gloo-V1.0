import 'resource_manager.dart';

// ─── Gloo Adası — Base Building ──────────────────────────────────────────────

/// Ada binası türleri.
enum BuildingType {
  gelFactory,
  asmrTower,
  colorLab,
  arena,
  harbor,
}

/// Ada binası tanımı.
class Building {
  const Building({
    required this.type,
    required this.name,
    required this.maxLevel,
    required this.baseCost,
    required this.costMultiplier,
    this.description,
  });

  final BuildingType type;
  final String name;
  final int maxLevel;
  final int baseCost;
  final double costMultiplier;
  final String? description;

  /// Belirtilen seviyeye yükseltme maliyeti.
  int costForLevel(int level) => (baseCost * (costMultiplier * level)).round();
}

/// Tüm ada binaları.
const Map<BuildingType, Building> kBuildings = {
  BuildingType.gelFactory: Building(
    type: BuildingType.gelFactory,
    name: 'Jel Fabrikası',
    maxLevel: 5,
    baseCost: 50,
    costMultiplier: 1.5,
    description: 'Pasif Jel Özü üretimi',
  ),
  BuildingType.asmrTower: Building(
    type: BuildingType.asmrTower,
    name: 'ASMR Kulesi',
    maxLevel: 3,
    baseCost: 80,
    costMultiplier: 2.0,
    description: 'Yeni ses paketlerini açar',
  ),
  BuildingType.colorLab: Building(
    type: BuildingType.colorLab,
    name: 'Renk Laboratuvarı',
    maxLevel: 3,
    baseCost: 100,
    costMultiplier: 2.0,
    description: 'Yeni sentez kombinasyonları',
  ),
  BuildingType.arena: Building(
    type: BuildingType.arena,
    name: 'Meydan',
    maxLevel: 1,
    baseCost: 200,
    costMultiplier: 1.0,
    description: 'PvP modunu açar',
  ),
  BuildingType.harbor: Building(
    type: BuildingType.harbor,
    name: 'Liman',
    maxLevel: 1,
    baseCost: 150,
    costMultiplier: 1.0,
    description: 'Sezonluk etkinliklere erişim',
  ),
};

/// Oyuncunun ada durumu.
class IslandState {
  IslandState();

  final Map<BuildingType, int> _buildingLevels = {};

  int getBuildingLevel(BuildingType type) => _buildingLevels[type] ?? 0;

  bool canBuild(BuildingType type) {
    final building = kBuildings[type]!;
    return getBuildingLevel(type) < building.maxLevel;
  }

  int getUpgradeCost(BuildingType type) {
    final building = kBuildings[type]!;
    final level = getBuildingLevel(type);
    return building.costForLevel(level + 1);
  }

  bool upgrade(BuildingType type, ResourceManager resources) {
    if (!canBuild(type)) return false;
    final cost = getUpgradeCost(type);
    if (!resources.spend(cost)) return false;
    _buildingLevels[type] = getBuildingLevel(type) + 1;
    return true;
  }

  /// Jel Fabrikası pasif üretim miktarı (saat başına).
  int get passiveGelPerHour => getBuildingLevel(BuildingType.gelFactory) * 2;

  /// PvP modu açık mı?
  bool get isPvpUnlocked => getBuildingLevel(BuildingType.arena) > 0;

  /// Sezonluk etkinlikler açık mı?
  bool get isSeasonUnlocked => getBuildingLevel(BuildingType.harbor) > 0;

  /// Tüm bina seviyelerini harita olarak döner (kalıcılık için).
  Map<String, int> toMap() =>
      _buildingLevels.map((k, v) => MapEntry(k.name, v));

  /// Haritadan yükle.
  void loadFromMap(Map<String, int> map) {
    for (final entry in map.entries) {
      try {
        final type = BuildingType.values.byName(entry.key);
        _buildingLevels[type] = entry.value;
      } catch (_) {
        // Bilinmeyen anahtar — atla
      }
    }
  }
}
