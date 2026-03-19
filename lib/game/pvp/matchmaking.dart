import 'dart:math';

import '../../core/l10n/app_strings.dart';
import '../../core/models/match_models.dart';
export '../../core/models/match_models.dart';

/// ELO ligleri.
enum EloLeague {
  bronze, // 0-999
  silver, // 1000-1499
  gold, // 1500-1999
  diamond, // 2000-2499
  glooMaster, // 2500+
}

/// ELO lig bilgisi.
extension EloLeagueInfo on EloLeague {
  String leagueName(AppStrings l) => switch (this) {
        EloLeague.bronze => l.leagueBronze,
        EloLeague.silver => l.leagueSilver,
        EloLeague.gold => l.leagueGold,
        EloLeague.diamond => l.leagueDiamond,
        EloLeague.glooMaster => l.leagueGlooMaster,
      };

  int get minElo => switch (this) {
        EloLeague.bronze => 0,
        EloLeague.silver => 1000,
        EloLeague.gold => 1500,
        EloLeague.diamond => 2000,
        EloLeague.glooMaster => 2500,
      };

  static EloLeague fromElo(int elo) {
    if (elo >= 2500) return EloLeague.glooMaster;
    if (elo >= 2000) return EloLeague.diamond;
    if (elo >= 1500) return EloLeague.gold;
    if (elo >= 1000) return EloLeague.silver;
    return EloLeague.bronze;
  }
}

/// Düello maç sonucu.
enum DuelOutcome { win, loss, draw }

/// Maç sonuç verisi.
class DuelResult {
  const DuelResult({
    required this.outcome,
    required this.playerScore,
    required this.opponentScore,
    required this.eloChange,
    required this.gelReward,
  });

  final DuelOutcome outcome;
  final int playerScore;
  final int opponentScore;
  final int eloChange;
  final int gelReward;
}

/// ELO hesaplama sistemi.
class EloSystem {
  static const int initialElo = 1000;
  static const int kFactor = 32;

  /// ELO değişimini hesaplar.
  static int calculateChange({
    required int playerElo,
    required int opponentElo,
    required DuelOutcome outcome,
  }) {
    final expected = 1.0 / (1.0 + pow(10, (opponentElo - playerElo) / 400));
    final actual = switch (outcome) {
      DuelOutcome.win => 1.0,
      DuelOutcome.loss => 0.0,
      DuelOutcome.draw => 0.5,
    };
    return (kFactor * (actual - expected)).round();
  }

  /// Ödül hesapla.
  static int calculateGelReward(DuelOutcome outcome) => switch (outcome) {
        DuelOutcome.win => 10,
        DuelOutcome.loss => 3,
        DuelOutcome.draw => 5,
      };
}

/// Satır temizleme ve kombo bazlı engel oluşturucu.
class ObstacleGenerator {
  /// Temizleme sonucuna göre gönderilecek engelleri hesaplar.
  static List<ObstaclePacket> fromLineClear({
    required int linesCleared,
    required String comboTier,
  }) {
    final packets = <ObstaclePacket>[];

    // Temel: her temizleme → 1 buz
    packets.add(ObstaclePacket(type: ObstacleType.ice, count: linesCleared));

    // 2+ satır → ek kilitli hücre
    if (linesCleared >= 2) {
      packets.add(const ObstaclePacket(type: ObstacleType.locked, count: 1));
    }

    // Kombo bonusu
    switch (comboTier) {
      case 'medium':
        packets.add(const ObstaclePacket(type: ObstacleType.ice, count: 2));
        packets.add(const ObstaclePacket(type: ObstacleType.stone, count: 1));
      case 'large':
        packets.add(const ObstaclePacket(type: ObstacleType.ice, count: 3));
        packets.add(const ObstaclePacket(type: ObstacleType.stone, count: 2));
      case 'epic':
        packets.add(const ObstaclePacket(
            type: ObstacleType.ice, count: 9, areaSize: 3));
      default:
        break;
    }

    return packets;
  }
}

/// Eşleştirme yöneticisi — yerel mantık (Supabase Realtime ile entegre edilecek).
class MatchmakingManager {
  static const int maxWaitSeconds = 30;
  static const int eloRange = 200;
  static const int eloRangeExpansion = 100; // 10sn sonra genişletme

  /// Eşleştirme kriterleri uygun mu?
  static bool isCompatible(MatchRequest a, MatchRequest b) {
    final eloDiff = (a.elo - b.elo).abs();
    final maxRange = eloRange +
        (a.waitSeconds > 10 ? eloRangeExpansion : 0) +
        (b.waitSeconds > 10 ? eloRangeExpansion : 0);
    return eloDiff <= maxRange;
  }

  /// Bot eslestirme icin guvenli rastgele seed uretir.
  /// Gercek PvP maclarda seed sunucu tarafinda uretilir (DB DEFAULT).
  static int generateBotMatchSeed() {
    final rng = Random.secure();
    // 32-bit guvenli random (Dart int 64-bit, ama seed olarak yeterli)
    return rng.nextInt(1 << 32);
  }

  /// Bot zorluk seviyesi (ELO bazlı).
  static double botDifficulty(int playerElo) {
    return (playerElo / 2500).clamp(0.2, 0.95);
  }
}

/// Asenkron düello durumu.
class AsyncDuelState {
  AsyncDuelState({
    required this.matchId,
    required this.seed,
    required this.durationSeconds,
  });

  final String matchId;
  final int seed;
  final int durationSeconds;

  int? playerScore;
  int? opponentScore;
  bool isPlayerDone = false;
  bool isOpponentDone = false;

  bool get isComplete => isPlayerDone && isOpponentDone;

  DuelOutcome? get outcome {
    if (!isComplete) return null;
    if (playerScore == opponentScore) return DuelOutcome.draw;
    return playerScore! > opponentScore! ? DuelOutcome.win : DuelOutcome.loss;
  }
}
