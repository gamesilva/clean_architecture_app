import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';
import 'package:clean_architecture_app/presentation/presenters/presenters.dart';

class LoadCurrentAccountSpy extends Mock implements LoadCurrentAccount {}

void main() {
  late LoadCurrentAccountSpy loadCurrentAccount;
  late StreamSplashPresenter sut;

  When mockLoadCurrentAccountCall() => when(() => loadCurrentAccount.load());

  void mockLoadCurrentAccount({AccountEntity? account}) =>
      mockLoadCurrentAccountCall().thenAnswer((_) async => account);
  void mockLoadCurrentAccountError() =>
      mockLoadCurrentAccountCall().thenThrow(Exception());

  setUp(() {
    loadCurrentAccount = LoadCurrentAccountSpy();
    sut = StreamSplashPresenter(loadCurrentAccount: loadCurrentAccount);
  });

  test('Should call LoadCurrentAccount', () async {
    mockLoadCurrentAccount(account: AccountEntity(faker.guid.guid()));
    await sut.checkAccount();

    verify(() => loadCurrentAccount.load()).called(1);
  });

  test('Should go to surveys page on success', () async {
    mockLoadCurrentAccount(account: AccountEntity(faker.guid.guid()));
    sut.navigateToStream
        .listen(expectAsync1((page) => expect(page, '/surveys')));

    await sut.checkAccount();
  });

  test('Should go to login page on null result', () async {
    mockLoadCurrentAccount(account: null);

    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/login')));

    await sut.checkAccount();
  });

  test('Should go to login page on error', () async {
    mockLoadCurrentAccountError();

    sut.navigateToStream.listen(expectAsync1((page) => expect(page, '/login')));

    await sut.checkAccount();
  });
}
