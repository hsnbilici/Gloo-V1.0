import 'resource_manager.dart';

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
