/// Supabase `leaderboard_view` uzerinden donen skor kaydi.
///
/// Sorgu: `leaderboard_view(id, user_id, mode, score, created_at, username)`
class LeaderboardEntry {
  final String id;
  final String userId;
  final String mode;
  final int score;
  final DateTime? createdAt;
  final String username;

  const LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.mode,
    required this.score,
    this.createdAt,
    required this.username,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      mode: map['mode'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      username: map['username'] as String? ?? 'Player',
    );
  }
}
