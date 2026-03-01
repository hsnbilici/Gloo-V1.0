/// Skor guncelleme broadcast payload'u.
class BroadcastScore {
  final String? userId;
  final int score;
  final String timestamp;

  const BroadcastScore({
    required this.userId,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'score': score,
        'timestamp': timestamp,
      };

  factory BroadcastScore.fromMap(Map<String, dynamic> map) => BroadcastScore(
        userId: map['user_id'] as String?,
        score: map['score'] as int? ?? 0,
        timestamp: map['timestamp'] as String? ?? '',
      );
}
