import 'package:faker/faker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/infra/cache/cache.dart';

class FlutterSecureStorageSpy extends Mock implements FlutterSecureStorage {}

void main() {
  late FlutterSecureStorageSpy secureStorage;
  late SecureStorageAdapter sut;
  late String key;
  late String value;

  setUp(() {
    secureStorage = FlutterSecureStorageSpy();
    sut = SecureStorageAdapter(secureStorage: secureStorage);
    key = faker.lorem.word();
    value = faker.guid.guid();
  });

  group('saveSecure', () {
    void mockSaveSecureError() => when(() => secureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenThrow(Exception());

    test('Should call save secure with correct values', () async {
      await sut.saveSecure(key: key, value: value);

      verify(() => secureStorage.write(key: key, value: value));
    });

    test('Should throw if save secure throws', () async {
      mockSaveSecureError();

      final future = sut.saveSecure(key: key, value: value);

      expect(future, throwsA(const TypeMatcher<Exception>()));
    });
  });

  group('fetchSecure', () {
    When mockFetchSecureCall() =>
        when(() => secureStorage.read(key: any(named: 'key')));

    void mockFetchSecure() =>
        mockFetchSecureCall().thenAnswer((_) async => value);

    void mockFetchSecureError() => mockFetchSecureCall().thenThrow(Exception());

    setUp(() {
      mockFetchSecure();
    });

    test('Should call fetchSecure with correct value', () async {
      await sut.fetchSecure(key);

      verify(() => secureStorage.read(key: key));
    });

    test('Should return correc value on success', () async {
      final fetchedValue = await sut.fetchSecure(key);

      expect(fetchedValue, value);
    });

    test('Should throw if save secure throws', () async {
      mockFetchSecureError();

      final future = sut.fetchSecure(key);

      expect(future, throwsA(const TypeMatcher<Exception>()));
    });
  });
}
