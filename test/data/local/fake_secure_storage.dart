import 'package:gloo/data/local/secure_storage_interface.dart';

class FakeSecureStorage implements SecureStorageInterface {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> deleteAll() async => _store.clear();
}
