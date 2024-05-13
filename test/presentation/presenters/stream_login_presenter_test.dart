import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/helpers/helpers.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

import 'package:clean_architecture_app/presentation/presenters/presenters.dart';
import 'package:clean_architecture_app/presentation/protocols/protocols.dart';

class ValidationSpy extends Mock implements Validation {}

class AuthenticationSpy extends Mock implements Authentication {}

class SaveCurrentAccountSpy extends Mock implements SaveCurrentAccount {}

void main() {
  late Validation validation;
  late Authentication authentication;
  late StreamLoginPresenter sut;
  late SaveCurrentAccount saveCurrentAccount;
  late String email;
  late String password;
  late String token;

  When mockValidationCall(String? field) => when(() => validation.validate(
      field: field ?? any(named: 'field'), value: any(named: 'value')));

  void mockValidation({String? field, String? value}) =>
      mockValidationCall(field).thenReturn(value);

  When mockAuthenticationCall() =>
      when(() => authentication.auth(any<AuthenticationParams>()));
  void mockAuthentication() =>
      mockAuthenticationCall().thenAnswer((_) async => AccountEntity(token));
  void mockAuthenticationError(DomainError error) =>
      mockAuthenticationCall().thenThrow(error);

  When mockSaveCurrentAccountCall() =>
      when(() => saveCurrentAccount.save(any<AccountEntity>()));
  void mockSaveCurrentAccountError() =>
      mockSaveCurrentAccountCall().thenThrow(DomainError.unexpected);

  setUpAll(() {
    email = faker.internet.email();
    password = faker.internet.password();
    token = faker.guid.guid();

    registerFallbackValue(AuthenticationParams(email: email, secret: password));
    registerFallbackValue(AccountEntity(token));
  });

  setUp(() {
    validation = ValidationSpy();
    authentication = AuthenticationSpy();
    saveCurrentAccount = SaveCurrentAccountSpy();

    sut = StreamLoginPresenter(
      validation: validation,
      authentication: authentication,
      saveCurrentAccount: saveCurrentAccount,
    );

    mockValidation();
    mockAuthentication();
  });
  test('Should call Validation with correct email', () {
    sut.validateEmail(email);

    verify(() => validation.validate(field: 'email', value: email)).called(1);
  });
  test('Should emit email error if validation fails', () {
    mockValidation(value: 'error');

    // Aqui eu garanto que o listen só execute uma vez caso o valor anterior seja o mesmo.
    sut.emailErrorStream
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    // Mesmo validando duas vezes com o mesmo valor, a stream só emite um.
    sut.validateEmail(email);
    sut.validateEmail(email);
  });
  test('Should emit null if validation succeeds', () {
    sut.emailErrorStream.listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(email);
    sut.validateEmail(email);
  });

  test('Should call Validation with correct password', () {
    sut.validatePassword(password);

    verify(() => validation.validate(field: 'password', value: password))
        .called(1);
  });

  test('Should emit password error if validation fails', () {
    mockValidation(value: 'error');

    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validatePassword(password);
    sut.validatePassword(password);
  });

  test('Should emit password error as null if validation succeeds', () {
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validatePassword(password);
    sut.validatePassword(password);
  });

  test('Should emit form invalid if any field is invalid', () {
    mockValidation(field: 'email', value: 'error');

    sut.emailErrorStream
        .listen(expectAsync1((error) => expect(error, 'error')));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(password);
    sut.validatePassword(password);
  });

  test('Should emit form valid if both fields are valid', () async {
    sut.emailErrorStream.listen(expectAsync1((error) => expect(error, null)));
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, null)));

    expectLater(sut.isFormValidStream, emitsInOrder([false, true]));

    sut.validateEmail(email);
    await Future.delayed(Duration.zero);
    sut.validatePassword(password);
  });

  test('Should call Authentication with correct values.', () async {
    sut.validateEmail(email);
    sut.validatePassword(password);

    await sut.auth();

    verify(() => authentication.auth(
          AuthenticationParams(
            email: email,
            secret: password,
          ),
        )).called(1);
  });

  test('Should emit correct events on Authentication success', () async {
    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    await sut.auth();
  });

  test('Should emit correct events on InvalidCredenrialsError', () async {
    mockAuthenticationError(DomainError.invalidCredentials);

    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emits(false));
    sut.mainErrorStream.listen(
        expectAsync1((error) => expect(error, 'Credenciais inválidas')));

    await sut.auth();
  });

  test('Should emit correct events on UnexpectedError', () async {
    mockAuthenticationError(DomainError.unexpected);

    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emits(false));
    sut.mainErrorStream.listen(expectAsync1(
        (error) => expect(error, 'Algo errado aconteceu. Tente novamente')));

    await sut.auth();
  });

  test('Should not emit after dispose', () async {
    mockSaveCurrentAccountError();

    expectLater(sut.emailErrorStream, neverEmits(null));
    expectLater(sut.passwordErrorStream, neverEmits(null));
    expectLater(sut.mainErrorStream, neverEmits(null));

    sut.dispose();

    sut.validateEmail(email);
    sut.validatePassword(password);
    await sut.auth();
  });

  test('Should call SaveCurrentAccount with correct value.', () async {
    sut.validateEmail(email);
    sut.validatePassword(password);

    await sut.auth();

    verify(() => saveCurrentAccount.save(AccountEntity(token))).called(1);
  });

  test('Should emit UnexpectedError if SaveCurrentAccount fails', () async {
    mockSaveCurrentAccountError();

    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    sut.mainErrorStream.listen(expectAsync1(
        (error) => expect(error, 'Algo errado aconteceu. Tente novamente')));

    await sut.auth();
  });
}
