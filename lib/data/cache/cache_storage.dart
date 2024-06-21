abstract class CacheStorage {
  Future<dynamic>? fetch(String key) async {}
  Future<void>? delete(String key) async {}
  Future<void>? save({required String key, required dynamic value}) async {}
}
