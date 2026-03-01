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
