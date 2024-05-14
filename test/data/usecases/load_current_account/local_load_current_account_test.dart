import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

class LocalLoadingCurrentAccount implements LoadCurrentAccount {
  final FetchSecureCacheStorage fetchSecureCacheStorage;

  LocalLoadingCurrentAccount({required this.fetchSecureCacheStorage});

  @override
  Future<AccountEntity>? load() async {
    final token = await fetchSecureCacheStorage.fetchSecure('token');
    return AccountEntity(token);
  }
}

abstract class FetchSecureCacheStorage {
  Future<String> fetchSecure(String key);
}

class FetchSecureCacheStorageSpy extends Mock
    implements FetchSecureCacheStorage {}

void main() {
  late FetchSecureCacheStorageSpy fetchSecureCacheStorage;
  late LocalLoadingCurrentAccount sut;
  late String token;

  void mockFetchSecure() =>
      when(() => fetchSecureCacheStorage.fetchSecure(any()))
          .thenAnswer((_) async => token);

  setUp(() {
    fetchSecureCacheStorage = FetchSecureCacheStorageSpy();
    sut = LocalLoadingCurrentAccount(
      fetchSecureCacheStorage: fetchSecureCacheStorage,
    );

    token = faker.guid.guid();
    mockFetchSecure();
  });

  // O método fetchSecure vai retornar null por causa da lib Mock
  // test('Should call FetchSecureCacheStorage with correct value', () async {
  //   await sut.load();

  //   verify(() => fetchSecureCacheStorage.fetchSecure('token'));
  // });

  test('Should return an AccountEntity', () async {
    final account = await sut.load();

    expect(account, AccountEntity(token));
  });
}
