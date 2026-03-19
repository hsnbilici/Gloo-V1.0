/// PvP engel türleri.
enum ObstacleType {
  ice, // Buz hücresi
  locked, // Kilitli hücre
  stone, // Taş engel
}

/// Rakibe gönderilen engel paketi.
class ObstaclePacket {
  const ObstaclePacket({
    required this.type,
    required this.count,
    this.areaSize,
  });

  final ObstacleType type;
  final int count;

  /// Buz alanı için boyut (epic kombo: 3×3).
  final int? areaSize;
}

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
