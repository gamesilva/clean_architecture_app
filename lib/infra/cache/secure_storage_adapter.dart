import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/cache/cache.dart';

class SecureStorageAdapter
    implements SaveSecureChacheStorage, FetchSecureCacheStorage {
  final FlutterSecureStorage secureStorage;

  SecureStorageAdapter({required this.secureStorage});
  @override
  Future<void>? saveSecure({
    required String key,
    required String value,
  }) async {
    await secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?>? fetchSecure(String key) async {
    return await secureStorage.read(key: key);
  }
}
