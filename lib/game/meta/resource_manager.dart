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

// ─── Karakter Sistemi ────────────────────────────────────────────────────────

/// Kostüm parçası kategorileri.
enum CostumeSlot { hat, glasses, accessory }

/// Kostüm parçası tanımı.
class CostumePiece {
  const CostumePiece({
    required this.id,
    required this.slot,
    required this.name,
    this.isPremium = false,
  });

  final String id;
  final CostumeSlot slot;
  final String name;
  final bool isPremium;
}

/// Karakter yetenek ağacı.
enum TalentType {
  betterHand, // %5 daha küçük şekil olasılığı (dalbaşma: +%5)
  colorMaster, // Sentez %10 daha fazla puan
  fastHands, // Time Trial'da +5sn başlangıç
  zenGuru, // Zen modda pasif Jel Özü üretimi
}

class TalentDef {
  const TalentDef({
    required this.type,
    required this.name,
    required this.maxLevel,
    required this.costPerLevel,
    required this.description,
  });

  final TalentType type;
  final String name;
  final int maxLevel;
  final int costPerLevel;
  final String description;
}

const Map<TalentType, TalentDef> kTalents = {
  TalentType.betterHand: TalentDef(
    type: TalentType.betterHand,
    name: 'Daha İyi El',
    maxLevel: 3,
    costPerLevel: 100,
    description: '%5 daha küçük şekil olasılığı',
  ),
  TalentType.colorMaster: TalentDef(
    type: TalentType.colorMaster,
    name: 'Renk Ustası',
    maxLevel: 3,
    costPerLevel: 100,
    description: 'Sentez %10 daha fazla puan',
  ),
  TalentType.fastHands: TalentDef(
    type: TalentType.fastHands,
    name: 'Hızlı Eller',
    maxLevel: 2,
    costPerLevel: 120,
    description: 'Time Trial +5sn başlangıç',
  ),
  TalentType.zenGuru: TalentDef(
    type: TalentType.zenGuru,
    name: 'Zen Guru',
    maxLevel: 2,
    costPerLevel: 80,
    description: 'Zen modda pasif Jel Özü üretimi',
  ),
};

/// Oyuncunun karakter durumu.
class CharacterState {
  CharacterState();

  final Set<String> _unlockedCostumes = {};
  final Map<CostumeSlot, String?> _equipped = {};
  final Map<TalentType, int> _talentLevels = {};

  Set<String> get unlockedCostumes => _unlockedCostumes;

  bool isCostumeUnlocked(String costumeId) =>
      _unlockedCostumes.contains(costumeId);

  void unlockCostume(String costumeId) => _unlockedCostumes.add(costumeId);

  String? getEquipped(CostumeSlot slot) => _equipped[slot];

  void equip(CostumeSlot slot, String? costumeId) =>
      _equipped[slot] = costumeId;

  int getTalentLevel(TalentType type) => _talentLevels[type] ?? 0;

  bool upgradeTalent(TalentType type, ResourceManager resources) {
    final def = kTalents[type]!;
    final level = getTalentLevel(type);
    if (level >= def.maxLevel) return false;
    final cost = def.costPerLevel * (level + 1);
    if (!resources.spend(cost)) return false;
    _talentLevels[type] = level + 1;
    return true;
  }

  /// Yetenek bonus'u hesapla.
  double getBetterHandBonus() => getTalentLevel(TalentType.betterHand) * 0.05;
  double getColorMasterBonus() => getTalentLevel(TalentType.colorMaster) * 0.10;
  int getFastHandsBonus() => getTalentLevel(TalentType.fastHands) * 5;
  int getZenGuruPassiveRate() => getTalentLevel(TalentType.zenGuru) * 1;

  Map<String, dynamic> toMap() => {
        'costumes': _unlockedCostumes.toList(),
        'equipped': _equipped.map((k, v) => MapEntry(k.name, v)),
        'talents': _talentLevels.map((k, v) => MapEntry(k.name, v)),
      };

  void loadFromMap(Map<String, dynamic> map) {
    final costumes = map['costumes'];
    if (costumes is List) {
      _unlockedCostumes.addAll(costumes.cast<String>());
    }
    final equipped = map['equipped'];
    if (equipped is Map) {
      for (final entry in equipped.entries) {
        try {
          final slot = CostumeSlot.values.byName(entry.key as String);
          _equipped[slot] = entry.value as String?;
        } catch (_) {}
      }
    }
    final talents = map['talents'];
    if (talents is Map) {
      for (final entry in talents.entries) {
        try {
          final type = TalentType.values.byName(entry.key as String);
          _talentLevels[type] = entry.value as int;
        } catch (_) {}
      }
    }
  }
}

// ─── Sezon Pası ──────────────────────────────────────────────────────────────

/// Sezon pası tier ödül türleri.
enum SeasonRewardType { gelOzu, costume, decoration, energy }

/// Sezon pası tier ödülü.
class SeasonReward {
  const SeasonReward({
    required this.type,
    required this.amount,
    this.itemId,
    this.isPremium = false,
  });

  final SeasonRewardType type;
  final int amount;
  final String? itemId;
  final bool isPremium;
}

/// Sezon pası tier tanımı.
class SeasonTier {
  const SeasonTier({
    required this.tier,
    required this.xpRequired,
    required this.freeReward,
    this.premiumReward,
  });

  final int tier;
  final int xpRequired;
  final SeasonReward freeReward;
  final SeasonReward? premiumReward;
}

/// Sezon pası durumu.
class SeasonPassState {
  SeasonPassState();

  int _currentXp = 0;
  int _claimedFreeTier = 0;
  int _claimedPremiumTier = 0;

  int get currentXp => _currentXp;
  int get claimedFreeTier => _claimedFreeTier;
  int get claimedPremiumTier => _claimedPremiumTier;

  void addXp(int amount) => _currentXp += amount;

  int getCurrentTier(List<SeasonTier> tiers) {
    int tier = 0;
    int accumulated = 0;
    for (final t in tiers) {
      accumulated += t.xpRequired;
      if (_currentXp >= accumulated) {
        tier = t.tier;
      } else {
        break;
      }
    }
    return tier;
  }

  bool canClaimFree(int tier) => tier > _claimedFreeTier;
  bool canClaimPremium(int tier) => tier > _claimedPremiumTier;

  void claimFree(int tier) {
    if (tier > _claimedFreeTier) _claimedFreeTier = tier;
  }

  void claimPremium(int tier) {
    if (tier > _claimedPremiumTier) _claimedPremiumTier = tier;
  }

  Map<String, int> toMap() => {
        'xp': _currentXp,
        'free_tier': _claimedFreeTier,
        'premium_tier': _claimedPremiumTier,
      };

  void loadFromMap(Map<String, int> map) {
    _currentXp = map['xp'] ?? 0;
    _claimedFreeTier = map['free_tier'] ?? 0;
    _claimedPremiumTier = map['premium_tier'] ?? 0;
  }
}

// ─── Günlük / Haftalık Görevler ──────────────────────────────────────────────

/// Görev türleri.
enum QuestType {
  clearLines, // "5 satırı tek hamlelede temizle"
  makeSyntheses, // "3 renk sentezi yap"
  reachCombo, // "Kombo zinciri 4+ yap"
  completeDailyPuzzle, // "Daily Puzzle'ı tamamla"
  playGames, // "3 oyun oyna"
  useColorSynthesis, // "Belirli renk sentezle"
  reachScore, // "1000+ skor yap"
}

/// Görev tanımı.
class Quest {
  const Quest({
    required this.type,
    required this.description,
    required this.targetCount,
    required this.xpReward,
    required this.gelReward,
    this.isWeekly = false,
  });

  final QuestType type;
  final String description;
  final int targetCount;
  final int xpReward;
  final int gelReward;
  final bool isWeekly;
}

/// Günlük görev şablonları (3/gün).
const List<Quest> kDailyQuestPool = [
  Quest(
      type: QuestType.clearLines,
      description: '10 satır temizle',
      targetCount: 10,
      xpReward: 50,
      gelReward: 3),
  Quest(
      type: QuestType.makeSyntheses,
      description: '5 renk sentezi yap',
      targetCount: 5,
      xpReward: 60,
      gelReward: 4),
  Quest(
      type: QuestType.reachCombo,
      description: 'Medium+ kombo yap',
      targetCount: 1,
      xpReward: 40,
      gelReward: 2),
  Quest(
      type: QuestType.completeDailyPuzzle,
      description: 'Günlük bulmacayı tamamla',
      targetCount: 1,
      xpReward: 80,
      gelReward: 5),
  Quest(
      type: QuestType.playGames,
      description: '3 oyun oyna',
      targetCount: 3,
      xpReward: 30,
      gelReward: 2),
  Quest(
      type: QuestType.reachScore,
      description: '800+ skor yap',
      targetCount: 1,
      xpReward: 50,
      gelReward: 3),
];

/// Haftalık görev şablonları (5/hafta).
const List<Quest> kWeeklyQuestPool = [
  Quest(
      type: QuestType.clearLines,
      description: '100 satır temizle',
      targetCount: 100,
      xpReward: 200,
      gelReward: 15,
      isWeekly: true),
  Quest(
      type: QuestType.makeSyntheses,
      description: '30 renk sentezi yap',
      targetCount: 30,
      xpReward: 250,
      gelReward: 20,
      isWeekly: true),
  Quest(
      type: QuestType.reachCombo,
      description: 'Epic kombo yap',
      targetCount: 1,
      xpReward: 150,
      gelReward: 10,
      isWeekly: true),
  Quest(
      type: QuestType.playGames,
      description: '20 oyun oyna',
      targetCount: 20,
      xpReward: 180,
      gelReward: 12,
      isWeekly: true),
  Quest(
      type: QuestType.reachScore,
      description: '5000+ skor yap',
      targetCount: 1,
      xpReward: 300,
      gelReward: 25,
      isWeekly: true),
];
