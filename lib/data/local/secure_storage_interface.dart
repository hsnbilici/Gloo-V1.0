import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorage için thin interface — test'te fake, production'da FlutterSecureStorage.
abstract class SecureStorageInterface {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String? value});
  Future<void> deleteAll();
}

/// Production implementasyonu — FlutterSecureStorage'ı sarar.
class SecureStorageImpl implements SecureStorageInterface {
  final FlutterSecureStorage _storage;
  const SecureStorageImpl([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
