import 'package:shared_preferences/shared_preferences.dart';

import 'data_models.dart';
import 'secure_storage_interface.dart';

/// Kullanıcı profili, kullanıcı adı ve COPPA yaş doğrulama verilerini yönetir.
class ProfileRepository {
  ProfileRepository(this._prefs, this._secure);

  final SharedPreferences _prefs;
  final SecureStorageInterface _secure;

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

  // ─── COPPA yaş kapısı ────────────────────────────────────────────────────

  Future<bool> getAgeVerified() async {
    final secure = await _secure.read(key: 'age_verified');
    if (secure != null) return secure == 'true';
    return _prefs.getBool('age_verified') ?? false;
  }

  Future<bool> getIsChild() async {
    final secure = await _secure.read(key: 'is_child');
    if (secure != null) return secure == 'true';
    return _prefs.getBool('is_child') ?? false;
  }

  Future<void> setAgeVerified({required bool isChild}) async {
    await _secure.write(key: 'age_verified', value: 'true');
    await _secure.write(key: 'is_child', value: isChild.toString());
    await _prefs.remove('age_verified');
    await _prefs.remove('is_child');
  }
}
