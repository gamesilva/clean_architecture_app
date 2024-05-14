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
  late FetchSecureCacheStorageSpy fetchSecureCacheStorage;
  late LocalLoadingCurrentAccount sut;

  setUp(() {
    fetchSecureCacheStorage = FetchSecureCacheStorageSpy();
    sut = LocalLoadingCurrentAccount(
      fetchSecureCacheStorage: fetchSecureCacheStorage,
    );
  });
  test('Should call FetchSecureCacheStorage with correct value', () async {
    await sut.load('token');

    verify(() => fetchSecureCacheStorage.fetchSecure('token'));
  });
}
