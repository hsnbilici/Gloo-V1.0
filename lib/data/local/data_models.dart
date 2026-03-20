// Basit veri modelleri — Isar yerine SharedPreferences kullanılıyor (demo)

class Score {
  Score({required this.mode, required this.value, required this.timestamp});

  final String mode;
  final int value;
  final DateTime timestamp;
}

class UserProfile {
  UserProfile({required this.username});

  static const int maxUsernameLength = 20;
  static final RegExp _validPattern = RegExp(r'^[a-zA-Z0-9_]+$');

  /// Returns null if [name] is valid, or an error key string if invalid.
  /// Error keys: 'empty', 'tooLong', 'invalidChars'
  static String? validateUsername(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'empty';
    if (trimmed.length > maxUsernameLength) return 'tooLong';
    if (!_validPattern.hasMatch(trimmed)) return 'invalidChars';
    return null;
  }

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
