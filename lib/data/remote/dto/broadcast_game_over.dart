/// Oyun bitis broadcast payload'u.
class BroadcastGameOver {
  final String? userId;
  final int score;

  const BroadcastGameOver({
    required this.userId,
    required this.score,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'score': score,
      };

  factory BroadcastGameOver.fromMap(Map<String, dynamic> map) =>
      BroadcastGameOver(
        userId: map['user_id'] as String?,
        score: map['score'] as int? ?? 0,
      );
}
