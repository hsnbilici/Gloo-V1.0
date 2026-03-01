/// Supabase `pvp_matches` tablosundan donen mac kaydi.
class PvpMatch {
  final String id;
  final String player1Id;
  final String? player2Id;
  final int seed;
  final String status;
  final int? player1Score;
  final int? player2Score;
  final String? winnerId;
  final DateTime? createdAt;

  const PvpMatch({
    required this.id,
    required this.player1Id,
    this.player2Id,
    required this.seed,
    required this.status,
    this.player1Score,
    this.player2Score,
    this.winnerId,
    this.createdAt,
  });

  factory PvpMatch.fromMap(Map<String, dynamic> map) {
    return PvpMatch(
      id: map['id'] as String? ?? '',
      player1Id: map['player1_id'] as String? ?? '',
      player2Id: map['player2_id'] as String?,
      seed: map['seed'] as int? ?? 0,
      status: map['status'] as String? ?? 'unknown',
      player1Score: map['player1_score'] as int?,
      player2Score: map['player2_score'] as int?,
      winnerId: map['winner_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
