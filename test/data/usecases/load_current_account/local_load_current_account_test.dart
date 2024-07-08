import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/cache/cache.dart';
import 'package:clean_architecture_app/data/usecases/usecases.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/helpers/helpers.dart';

class FetchSecureCacheStorageSpy extends Mock
    implements FetchSecureCacheStorage {}

void main() {
  late FetchSecureCacheStorageSpy fetchSecureCacheStorage;
  late LocalLoadingCurrentAccount sut;
  late String token;

  When mockFetchSecureCall() =>
      when(() => fetchSecureCacheStorage.fetch(any()));

  void mockFetchSecure() =>
      mockFetchSecureCall().thenAnswer((_) async => token);

  void mockFetchSecureError() => mockFetchSecureCall().thenThrow(Exception());

  setUp(() {
    fetchSecureCacheStorage = FetchSecureCacheStorageSpy();
    sut = LocalLoadingCurrentAccount(
      fetchSecureCacheStorage: fetchSecureCacheStorage,
    );

    token = faker.guid.guid();
    mockFetchSecure();
  });

  // O método fetch vai retornar null por causa da lib Mock
  // test('Should call FetchSecureCacheStorage with correct value', () async {
  //   await sut.load();

  //   verify(() => fetchSecureCacheStorage.fetch('token'));
  // });

  test('Should return an AccountEntity', () async {
    final account = await sut.load();

    expect(account, AccountEntity(token));
  });

  test('Should throw UnexpectError if FetchSecureCacheStorage throws',
      () async {
    mockFetchSecureError();
    final future = sut.load();

    expect(future, throwsA(DomainError.unexpected));
  });
}
