/// Eşleştirme isteği.
class MatchRequest {
  const MatchRequest({
    required this.userId,
    required this.elo,
    required this.region,
    required this.timestamp,
  });

  final String userId;
  final int elo;
  final String region;
  final DateTime timestamp;

  /// Bekleme süresi (saniye).
  int get waitSeconds => DateTime.now().difference(timestamp).inSeconds;
}

/// Eşleştirme sonucu.
class MatchResult {
  const MatchResult({
    required this.matchId,
    required this.player1Id,
    required this.player2Id,
    required this.seed,
    required this.isBot,
    this.opponentElo,
  });

  final String matchId;
  final String player1Id;
  final String player2Id;
  final int seed;
  final bool isBot;
  final int? opponentElo;
}
