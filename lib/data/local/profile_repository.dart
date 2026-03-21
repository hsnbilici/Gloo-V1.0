import 'package:shared_preferences/shared_preferences.dart';

import 'data_models.dart';

/// Kullanıcı profili ve kullanıcı adı verilerini yönetir.
class ProfileRepository {
  ProfileRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<UserProfile?> getProfile() async {
    final username = _prefs.getString('username');
    if (username == null) return null;
    final profile = UserProfile(username: username);
    profile.sfxEnabled = _prefs.getBool('sfx') ?? true;
    profile.musicEnabled = _prefs.getBool('music') ?? true;
    profile.hapticsEnabled = _prefs.getBool('haptics') ?? true;
    profile.currentStreak = _prefs.getInt('streak_count') ?? 0;
    return profile;
  }

  Future<void> saveProfile(UserProfile profile) async {
    final error = UserProfile.validateUsername(profile.username);
    if (error != null) return;
    await _prefs.setString('username', profile.username.trim());
    await _prefs.setBool('sfx', profile.sfxEnabled);
    await _prefs.setBool('music', profile.musicEnabled);
    await _prefs.setBool('haptics', profile.hapticsEnabled);
    await _prefs.setInt('streak_count', profile.currentStreak);
  }
}
