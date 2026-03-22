import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/game/meta/resource_manager.dart';

void main() {
  // ─── ResourceManager ────────────────────────────────────────────────────

  group('ResourceManager', () {
    late ResourceManager rm;

    setUp(() {
      rm = ResourceManager(initialEnergy: 50);
    });

    test('initial energy is set correctly', () {
      expect(rm.energy, 50);
    });

    test('default initial energy is 0', () {
      final rm2 = ResourceManager();
      expect(rm2.energy, 0);
    });

    test('earnFromLineClear adds energy per line', () {
      rm.earnFromLineClear(3);
      expect(rm.energy, 53);
      expect(rm.totalEarnedLifetime, 3);
    });

    test('spend deducts energy', () {
      expect(rm.spend(20), isTrue);
      expect(rm.energy, 30);
    });

    test('spend returns false when insufficient', () {
      expect(rm.spend(100), isFalse);
      expect(rm.energy, 50);
    });

    test('canAfford checks correctly', () {
      expect(rm.canAfford(50), isTrue);
      expect(rm.canAfford(51), isFalse);
    });

    test('setEnergy overrides current value', () {
      rm.setEnergy(999);
      expect(rm.energy, 999);
    });

    test('setTotalEarned sets lifetime total', () {
      rm.setTotalEarned(1000);
      expect(rm.totalEarnedLifetime, 1000);
    });

    test('onEnergyChanged fires on earn', () {
      int? newEnergy;
      rm.onEnergyChanged = (e) => newEnergy = e;
      rm.earnFromLineClear(5);
      expect(newEnergy, 55);
    });

    test('onEnergyChanged fires on spend', () {
      int? newEnergy;
      rm.onEnergyChanged = (e) => newEnergy = e;
      rm.spend(10);
      expect(newEnergy, 40);
    });
  });

  // ─── IslandState ────────────────────────────────────────────────────────

  group('IslandState', () {
    late IslandState island;
    late ResourceManager resources;

    setUp(() {
      island = IslandState();
      resources = ResourceManager(initialEnergy: 1000);
    });

    test('initial building levels are 0', () {
      for (final type in BuildingType.values) {
        expect(island.getBuildingLevel(type), 0);
      }
    });

    test('canBuild returns true when under max level', () {
      expect(island.canBuild(BuildingType.gelFactory), isTrue);
    });

    test('upgrade increments level and spends resources', () {
      final cost = island.getUpgradeCost(BuildingType.gelFactory);
      final before = resources.energy;
      expect(island.upgrade(BuildingType.gelFactory, resources), isTrue);
      expect(island.getBuildingLevel(BuildingType.gelFactory), 1);
      expect(resources.energy, before - cost);
    });

    test('cannot upgrade beyond max level', () {
      // Arena max level = 1
      island.upgrade(BuildingType.arena, resources);
      expect(island.canBuild(BuildingType.arena), isFalse);
      expect(island.upgrade(BuildingType.arena, resources), isFalse);
    });

    test('cannot upgrade without sufficient resources', () {
      final poorResources = ResourceManager(initialEnergy: 0);
      expect(island.upgrade(BuildingType.gelFactory, poorResources), isFalse);
    });

    test('passiveGelPerHour scales with gelFactory level', () {
      expect(island.passiveGelPerHour, 0);
      island.upgrade(BuildingType.gelFactory, resources);
      expect(island.passiveGelPerHour, 2);
      island.upgrade(BuildingType.gelFactory, resources);
      expect(island.passiveGelPerHour, 4);
    });

    test('isPvpUnlocked is false until arena built', () {
      expect(island.isPvpUnlocked, isFalse);
      island.upgrade(BuildingType.arena, resources);
      expect(island.isPvpUnlocked, isTrue);
    });

    test('isSeasonUnlocked is false until harbor built', () {
      expect(island.isSeasonUnlocked, isFalse);
      island.upgrade(BuildingType.harbor, resources);
      expect(island.isSeasonUnlocked, isTrue);
    });

    test('toMap and loadFromMap round-trip', () {
      island.upgrade(BuildingType.gelFactory, resources);
      island.upgrade(BuildingType.arena, resources);
      final map = island.toMap();

      final loaded = IslandState();
      loaded.loadFromMap(map);
      expect(loaded.getBuildingLevel(BuildingType.gelFactory), 1);
      expect(loaded.getBuildingLevel(BuildingType.arena), 1);
      expect(loaded.getBuildingLevel(BuildingType.asmrTower), 0);
    });

    test('loadFromMap ignores unknown keys', () {
      final island2 = IslandState();
      island2.loadFromMap({'unknownBuilding': 5});
      // No exception thrown
    });
  });

  // ─── Building ───────────────────────────────────────────────────────────

  group('Building', () {
    test('costForLevel calculates correctly', () {
      final building = kBuildings[BuildingType.gelFactory]!;
      // baseCost=50, costMultiplier=1.5, exponential: baseCost * pow(multiplier, level)
      expect(building.costForLevel(1), (50 * 1.5).round()); // 75
      expect(building.costForLevel(2), (50 * 1.5 * 1.5).round()); // 113
    });

    test('all 5 building types defined', () {
      expect(kBuildings.length, 5);
    });
  });

  // ─── CharacterState ─────────────────────────────────────────────────────

  group('CharacterState', () {
    late CharacterState character;
    late ResourceManager resources;

    setUp(() {
      character = CharacterState();
      resources = ResourceManager(initialEnergy: 5000);
    });

    test('initially no costumes unlocked', () {
      expect(character.unlockedCostumes, isEmpty);
    });

    test('unlockCostume adds to set', () {
      character.unlockCostume('hat_01');
      expect(character.isCostumeUnlocked('hat_01'), isTrue);
      expect(character.isCostumeUnlocked('hat_02'), isFalse);
    });

    test('equip and getEquipped work', () {
      character.equip(CostumeSlot.hat, 'hat_01');
      expect(character.getEquipped(CostumeSlot.hat), 'hat_01');
      expect(character.getEquipped(CostumeSlot.glasses), isNull);
    });

    test('talent levels start at 0', () {
      for (final type in TalentType.values) {
        expect(character.getTalentLevel(type), 0);
      }
    });

    test('upgradeTalent increments level and spends', () {
      expect(character.upgradeTalent(TalentType.betterHand, resources), isTrue);
      expect(character.getTalentLevel(TalentType.betterHand), 1);
    });

    test('cannot upgrade talent beyond max', () {
      // fastHands maxLevel = 2
      character.upgradeTalent(TalentType.fastHands, resources);
      character.upgradeTalent(TalentType.fastHands, resources);
      expect(character.upgradeTalent(TalentType.fastHands, resources), isFalse);
    });

    test('bonus calculations', () {
      character.upgradeTalent(TalentType.betterHand, resources);
      expect(character.getBetterHandBonus(), 0.05);

      character.upgradeTalent(TalentType.colorMaster, resources);
      expect(character.getColorMasterBonus(), 0.10);

      character.upgradeTalent(TalentType.fastHands, resources);
      expect(character.getFastHandsBonus(), 5);

      character.upgradeTalent(TalentType.zenGuru, resources);
      expect(character.getZenGuruPassiveRate(), 1);
    });

    test('toMap and loadFromMap round-trip', () {
      character.unlockCostume('hat_01');
      character.equip(CostumeSlot.hat, 'hat_01');
      character.upgradeTalent(TalentType.betterHand, resources);
      final map = character.toMap();

      final loaded = CharacterState();
      loaded.loadFromMap(map);
      expect(loaded.isCostumeUnlocked('hat_01'), isTrue);
      expect(loaded.getEquipped(CostumeSlot.hat), 'hat_01');
      expect(loaded.getTalentLevel(TalentType.betterHand), 1);
    });
  });

  // ─── SeasonPassState ────────────────────────────────────────────────────

  group('SeasonPassState', () {
    late SeasonPassState pass;

    setUp(() {
      pass = SeasonPassState();
    });

    test('initial XP is 0', () {
      expect(pass.currentXp, 0);
    });

    test('addXp increases XP', () {
      pass.addXp(100);
      expect(pass.currentXp, 100);
    });

    test('getCurrentTier calculates based on accumulated XP', () {
      final tiers = [
        const SeasonTier(
          tier: 1,
          xpRequired: 50,
          freeReward: SeasonReward(type: SeasonRewardType.gelOzu, amount: 10),
        ),
        const SeasonTier(
          tier: 2,
          xpRequired: 100,
          freeReward: SeasonReward(type: SeasonRewardType.gelOzu, amount: 20),
        ),
        const SeasonTier(
          tier: 3,
          xpRequired: 150,
          freeReward: SeasonReward(type: SeasonRewardType.energy, amount: 5),
        ),
      ];

      expect(pass.getCurrentTier(tiers), 0); // 0 XP
      pass.addXp(50);
      expect(pass.getCurrentTier(tiers), 1); // exactly 50
      pass.addXp(100);
      expect(pass.getCurrentTier(tiers), 2); // 150 >= 50+100
    });

    test('canClaimFree and claimFree work', () {
      expect(pass.canClaimFree(1), isTrue);
      pass.claimFree(1);
      expect(pass.canClaimFree(1), isFalse);
      expect(pass.canClaimFree(2), isTrue);
    });

    test('canClaimPremium and claimPremium work', () {
      expect(pass.canClaimPremium(1), isTrue);
      pass.claimPremium(1);
      expect(pass.canClaimPremium(1), isFalse);
    });

    test('toMap and loadFromMap round-trip', () {
      pass.addXp(200);
      pass.claimFree(3);
      pass.claimPremium(2);
      final map = pass.toMap();

      final loaded = SeasonPassState();
      loaded.loadFromMap(map);
      expect(loaded.currentXp, 200);
      expect(loaded.claimedFreeTier, 3);
      expect(loaded.claimedPremiumTier, 2);
    });
  });

  // ─── Quest definitions ──────────────────────────────────────────────────

  group('Quest definitions', () {
    test('daily quest pool has entries', () {
      expect(kDailyQuestPool, isNotEmpty);
      expect(kDailyQuestPool.length, 12);
    });

    test('weekly quest pool has entries', () {
      expect(kWeeklyQuestPool, isNotEmpty);
      expect(kWeeklyQuestPool.length, 5);
    });

    test('all weekly quests have isWeekly = true', () {
      for (final quest in kWeeklyQuestPool) {
        expect(quest.isWeekly, isTrue);
      }
    });

    test('all daily quests have isWeekly = false', () {
      for (final quest in kDailyQuestPool) {
        expect(quest.isWeekly, isFalse);
      }
    });

    test('all quests have positive rewards', () {
      for (final quest in [...kDailyQuestPool, ...kWeeklyQuestPool]) {
        expect(quest.xpReward, greaterThan(0));
        expect(quest.gelReward, greaterThan(0));
        expect(quest.targetCount, greaterThan(0));
      }
    });
  });
}
