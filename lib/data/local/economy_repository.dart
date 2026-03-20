import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage_interface.dart';

/// Jel Özü, Jel Enerjisi, açılmış ürünler, bekleyen doğrulama ve
/// itfa edilmiş kodları yönetir.
class EconomyRepository {
  EconomyRepository(this._prefs, this._secure);

  final SharedPreferences _prefs;
  final SecureStorageInterface _secure;

  // ─── Jel Özü (Soft Currency) ─────────────────────────────────────────────

  Future<int> getGelOzu() async {
    final secure = await _secure.read(key: 'gel_ozu');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('gel_ozu') ?? 0;
  }

  Future<void> saveGelOzu(int value) async {
    await _secure.write(key: 'gel_ozu', value: value.toString());
    await _prefs.remove('gel_ozu');
  }

  Future<int> getLifetimeEarnings() async {
    final secure = await _secure.read(key: 'lifetime_earnings');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('lifetime_earnings') ?? 0;
  }

  Future<void> saveLifetimeEarnings(int value) async {
    await _secure.write(key: 'lifetime_earnings', value: value.toString());
    await _prefs.remove('lifetime_earnings');
  }

  // ─── Jel Enerjisi (Meta-game Resource) ───────────────────────────────────

  Future<int> getGelEnergy() async {
    final secure = await _secure.read(key: 'gel_energy');
    if (secure != null) return int.tryParse(secure) ?? 0;
    return _prefs.getInt('gel_energy') ?? 0;
  }

  Future<void> saveGelEnergy(int value) async {
    await _secure.write(key: 'gel_energy', value: value.toString());
    await _prefs.remove('gel_energy');
  }

  int getTotalEarnedEnergy() => _prefs.getInt('total_earned_energy') ?? 0;

  Future<void> saveTotalEarnedEnergy(int value) async {
    await _prefs.setInt('total_earned_energy', value);
  }

  // ─── IAP Pending Verification ────────────────────────────────────────────

  Future<List<String>> getPendingVerification() async {
    final secure = await _secure.read(key: 'pending_verification');
    if (secure != null && secure.isNotEmpty) {
      return secure.split(',');
    }
    return _prefs.getStringList('pending_verification') ?? [];
  }

  Future<Map<String, String>> getPendingVerificationMap() async {
    final secure = await _secure.read(key: 'pending_verification_map');
    if (secure != null && secure.isNotEmpty) {
      final decoded = json.decode(secure);
      return Map<String, String>.from(decoded as Map);
    }
    final legacy = await getPendingVerification();
    if (legacy.isNotEmpty) {
      final map = {for (final id in legacy) id: ''};
      await savePendingVerificationMap(map);
      return map;
    }
    return {};
  }

  Future<void> savePendingVerificationMap(Map<String, String> pending) async {
    if (pending.isEmpty) {
      await _secure.write(key: 'pending_verification_map', value: null);
    } else {
      await _secure.write(
          key: 'pending_verification_map', value: json.encode(pending));
    }
    await _secure.write(key: 'pending_verification', value: null);
    await _prefs.remove('pending_verification');
  }

  Future<void> savePendingVerification(List<String> productIds) async {
    await _secure.write(
        key: 'pending_verification', value: productIds.join(','));
    await _prefs.remove('pending_verification');
  }

  // ─── Redeem Code ─────────────────────────────────────────────────────────

  Future<List<String>> getRedeemedCodes() async {
    final secure = await _secure.read(key: 'redeemed_codes');
    if (secure != null && secure.isNotEmpty) {
      return secure.split(',');
    }
    return _prefs.getStringList('redeemed_codes') ?? [];
  }

  Future<void> addRedeemedCode(String code) async {
    final current = await getRedeemedCodes();
    if (!current.contains(code)) {
      current.add(code);
      await _secure.write(key: 'redeemed_codes', value: current.join(','));
      await _prefs.remove('redeemed_codes');
    }
  }

  // ─── Subscription Timestamps ─────────────────────────────────────────────

  Future<int?> getSubscriptionTimestamp(String productId) async {
    final value = await _secure.read(key: 'sub_ts_$productId');
    if (value != null) return int.tryParse(value);
    return null;
  }

  Future<void> saveSubscriptionTimestamp(String productId, int epochMs) async {
    await _secure.write(key: 'sub_ts_$productId', value: epochMs.toString());
  }

  Future<void> removeSubscriptionTimestamp(String productId) async {
    await _secure.write(key: 'sub_ts_$productId', value: null);
  }

  // ─── Unlocked Products ───────────────────────────────────────────────────

  Future<List<String>> getUnlockedProducts() async {
    final secure = await _secure.read(key: 'unlocked_products');
    if (secure != null && secure.isNotEmpty) {
      return secure.split(',');
    }
    return _prefs.getStringList('unlocked_products') ?? [];
  }

  Future<void> addUnlockedProducts(List<String> productIds) async {
    final current = await getUnlockedProducts();
    final updated = {...current, ...productIds}.toList();
    await _secure.write(key: 'unlocked_products', value: updated.join(','));
    await _prefs.remove('unlocked_products');
  }
}
