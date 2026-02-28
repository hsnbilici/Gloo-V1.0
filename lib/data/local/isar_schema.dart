import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late DateTime createdAt;

  bool sfxEnabled = true;
  bool musicEnabled = true;
  bool hapticsEnabled = true;
  bool adsRemoved = false;

  int currentStreak = 0;
  DateTime? lastPlayedDate;
}

// SharedPreferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});
