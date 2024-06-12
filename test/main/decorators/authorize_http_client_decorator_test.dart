import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/cache/cache.dart';

class AuthorizeHttpClientDecorator {
  final FetchSecureCacheStorage fetchSecureCacheStorage;

  AuthorizeHttpClientDecorator({required this.fetchSecureCacheStorage});
  Future<void> request() async {
    await fetchSecureCacheStorage.fetchSecure('token');
  }
}

class FetchSecureCacheStorageSpy extends Mock
    implements FetchSecureCacheStorage {}

void main() {
  test('Should call FetchSecureCacheStorage with correct key', () async {
    final fetchSecureCacheStorage = FetchSecureCacheStorageSpy();
    final sut = AuthorizeHttpClientDecorator(
        fetchSecureCacheStorage: fetchSecureCacheStorage);

    await sut.request();

    verify(() => fetchSecureCacheStorage.fetchSecure('token')).called(1);
  });
}
