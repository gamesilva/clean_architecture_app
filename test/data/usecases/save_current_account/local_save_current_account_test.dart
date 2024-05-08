import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

class LocalSaveCurrentAccount implements SaveCurrentAccount {
  final SaveSecureChacheStorage saveSecureChacheStorage;

  LocalSaveCurrentAccount({required this.saveSecureChacheStorage});

  @override
  Future<void>? save(AccountEntity account) async {
    await saveSecureChacheStorage.saveSecure(
      key: 'token',
      value: account.token,
    );
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
}
