import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/helpers/helpers.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

class LocalSaveCurrentAccount implements SaveCurrentAccount {
  final SaveSecureChacheStorage saveSecureChacheStorage;

  LocalSaveCurrentAccount({required this.saveSecureChacheStorage});

  @override
  Future<void>? save(AccountEntity account) async {
    try {
      await saveSecureChacheStorage.saveSecure(
        key: 'token',
        value: account.token,
      );
    } catch (error) {
      throw DomainError.unexpected;
    }
  }
}

abstract class SaveSecureChacheStorage {
  Future<void>? saveSecure({required String key, required String value});
}

class SaveChacheStorageSpy extends Mock implements SaveSecureChacheStorage {}

void main() {
  test('Should call SaveCacheStorage with correct value', () async {
    final saveSecureChacheStorage = SaveChacheStorageSpy();
    final sut = LocalSaveCurrentAccount(
      saveSecureChacheStorage: saveSecureChacheStorage,
    );
    final account = AccountEntity(faker.guid.guid());

    sut.save(account);

    verify(() =>
        saveSecureChacheStorage.saveSecure(key: 'token', value: account.token));
  });

  test('Should throw UnexpectedError if SaveSecureChacheStorage throws',
      () async {
    final saveSecureChacheStorage = SaveChacheStorageSpy();
    final account = AccountEntity(faker.guid.guid());
    final sut = LocalSaveCurrentAccount(
      saveSecureChacheStorage: saveSecureChacheStorage,
    );

    when(() => saveSecureChacheStorage.saveSecure(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenThrow(Exception());

    final future = sut.save(account);

    expect(future, throwsA(DomainError.unexpected));
  });
}
