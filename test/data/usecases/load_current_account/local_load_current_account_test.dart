import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class LocalLoadingCurrentAccount {
  final FetchSecureCacheStorage fetchSecureCacheStorage;

  LocalLoadingCurrentAccount({required this.fetchSecureCacheStorage});

  Future<void>? load(String key) async {
    await fetchSecureCacheStorage.fetchSecure(key);
  }
}

abstract class FetchSecureCacheStorage {
  Future<void>? fetchSecure(String key);
}

class FetchSecureCacheStorageSpy extends Mock
    implements FetchSecureCacheStorage {}

void main() {
  test('Should call FetchSecureCacheStorage with correct value', () async {
    final fetchSecureCacheStorage = FetchSecureCacheStorageSpy();
    final sut = LocalLoadingCurrentAccount(
      fetchSecureCacheStorage: fetchSecureCacheStorage,
    );
    await sut.load('token');

    verify(() => fetchSecureCacheStorage.fetchSecure('token'));
  });
}
