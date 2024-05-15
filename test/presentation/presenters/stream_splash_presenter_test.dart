import 'dart:async';
import 'package:clean_architecture_app/domain/entities/account_entity.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/usecases/usecases.dart';
import 'package:clean_architecture_app/ui/pages/pages.dart';

class StreamSplashPresenter implements SplashPresenter {
  final LoadCurrentAccount loadCurrentAccount;
  final _navigateTo = StreamController<String?>();

  @override
  Stream<String?> get navigateToStream => _navigateTo.stream;

  StreamSplashPresenter({required this.loadCurrentAccount});

  @override
  Future<void>? checkAccount() async {
    final account = await loadCurrentAccount.load();
    _navigateTo.add(account != null ? '/surveys' : '/login');
  }
}

class LoadCurrentAccountSpy extends Mock implements LoadCurrentAccount {}

void main() {
  late LoadCurrentAccount loadCurrentAccount;
  late SplashPresenter sut;

  void mockLoadCurrentAccount({AccountEntity? account}) =>
      when(() => loadCurrentAccount.load()).thenAnswer((_) async => account);

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
}
