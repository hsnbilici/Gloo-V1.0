import 'game_mode.dart';

enum ChallengeType {
  scoreBattle,
  liveDuel;

  static ChallengeType fromString(String s) => switch (s) {
    'score_battle' => scoreBattle,
    'live_duel' => liveDuel,
    _ => scoreBattle,
  };

  String toDbString() => switch (this) {
    scoreBattle => 'score_battle',
    liveDuel => 'live_duel',
  };
}

enum ChallengeStatus {
  pending,
  active,
  completed,
  expired,
  declined,
  cancelled;

  static ChallengeStatus fromString(String s) {
    for (final v in values) {
      if (v.name == s) return v;
    }
    return pending;
  }
}

enum ChallengeOutcome {
  win,
  loss,
  draw;

  static ChallengeOutcome fromString(String s) => switch (s) {
    'win' => win,
    'loss' => loss,
    'draw' => draw,
    _ => draw,
  };
}

class Challenge {
  const Challenge({
    required this.id,
    required this.senderId,
    this.recipientId,
    required this.senderUsername,
    this.recipientUsername,
    required this.mode,
    required this.type,
    this.seed,
    required this.wager,
    this.senderScore,
    this.recipientScore,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      recipientId: map['recipient_id'] as String?,
      senderUsername: map['sender_username'] as String,
      recipientUsername: map['recipient_username'] as String?,
      mode: GameMode.fromString(map['mode'] as String),
      type: ChallengeType.fromString(map['challenge_type'] as String? ?? 'score_battle'),
      seed: map['seed'] as int?,
      wager: map['wager'] as int,
      senderScore: map['sender_score'] as int?,
      recipientScore: map['recipient_score'] as int?,
      status: ChallengeStatus.fromString(map['status'] as String),
      expiresAt: DateTime.parse(map['expires_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  final String id;
  final String senderId;
  final String? recipientId;
  final String senderUsername;
  final String? recipientUsername;
  final GameMode mode;
  final ChallengeType type;
  final int? seed;
  final int wager;
  final int? senderScore;
  final int? recipientScore;
  final ChallengeStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get hasWager => wager > 0;

  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

class ChallengeResult {
  const ChallengeResult({
    required this.outcome,
    required this.senderScore,
    required this.recipientScore,
    required this.gelReward,
  });

  factory ChallengeResult.fromMap(Map<String, dynamic> map) {
    return ChallengeResult(
      outcome: ChallengeOutcome.fromString(map['outcome'] as String),
      senderScore: map['sender_score'] as int,
      recipientScore: map['recipient_score'] as int,
      gelReward: map['gel_reward'] as int,
    );
  }

  final ChallengeOutcome outcome;
  final int senderScore;
  final int recipientScore;
  final int gelReward;
}
