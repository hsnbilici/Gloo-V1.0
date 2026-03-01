/// Supabase `meta_states` tablosundan donen meta-game state kaydi.
class MetaState {
  final String userId;
  final Map<String, dynamic>? islandState;
  final Map<String, dynamic>? characterState;
  final Map<String, dynamic>? seasonPassState;
  final Map<String, dynamic>? questProgress;
  final String? questDate;
  final int? gelEnergy;
  final int? totalEarnedEnergy;
  final DateTime? updatedAt;

  const MetaState({
    required this.userId,
    this.islandState,
    this.characterState,
    this.seasonPassState,
    this.questProgress,
    this.questDate,
    this.gelEnergy,
    this.totalEarnedEnergy,
    this.updatedAt,
  });

  factory MetaState.fromMap(Map<String, dynamic> map) {
    return MetaState(
      userId: map['user_id'] as String? ?? '',
      islandState: map['island_state'] as Map<String, dynamic>?,
      characterState: map['character_state'] as Map<String, dynamic>?,
      seasonPassState: map['season_pass_state'] as Map<String, dynamic>?,
      questProgress: map['quest_progress'] as Map<String, dynamic>?,
      questDate: map['quest_date'] as String?,
      gelEnergy: map['gel_energy'] as int?,
      totalEarnedEnergy: map['total_earned_energy'] as int?,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }
}
