// Basit veri modelleri — Isar yerine SharedPreferences kullanılıyor (demo)

class Score {
  Score({required this.mode, required this.value, required this.timestamp});

  final String mode;
  final int value;
  final DateTime timestamp;
}

class UserProfile {
  UserProfile({required this.username});

  String username;
  String platform = 'unknown';
  DateTime createdAt = DateTime.now();

  bool sfxEnabled = true;
  bool musicEnabled = true;
  bool hapticsEnabled = true;
  bool adsRemoved = false;

  int currentStreak = 0;
  DateTime? lastPlayedDate;
}
