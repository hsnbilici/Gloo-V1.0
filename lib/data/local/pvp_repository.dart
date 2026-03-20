import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage_interface.dart';

/// ELO puanı ve PvP kazanma/kaybetme istatistiklerini yönetir.
class PvpRepository {
  PvpRepository(this._prefs, this._secure);

  final SharedPreferences _prefs;
  final SecureStorageInterface _secure;

  Future<int> getElo() async {
    final secure = await _secure.read(key: 'elo');
    if (secure != null) return int.tryParse(secure) ?? 1000;
    return _prefs.getInt('elo') ?? 1000;
  }

  Future<void> saveElo(int value) async {
    await _secure.write(key: 'elo', value: value.toString());
    await _prefs.remove('elo');
  }

  Future<int> getPvpWins() async {
    final secure = await _secure.read(key: 'pvp_wins');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('pvp_wins') ?? 0;
  }

  Future<int> getPvpLosses() async {
    final secure = await _secure.read(key: 'pvp_losses');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('pvp_losses') ?? 0;
  }

  Future<void> recordPvpResult({required bool isWin}) async {
    if (isWin) {
      final wins = await getPvpWins();
      await _secure.write(key: 'pvp_wins', value: (wins + 1).toString());
      await _prefs.remove('pvp_wins');
    } else {
      final losses = await getPvpLosses();
      await _secure.write(key: 'pvp_losses', value: (losses + 1).toString());
      await _prefs.remove('pvp_losses');
    }
  }
}
