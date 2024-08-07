import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/ui/helpers/errors/errors.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/helpers/helpers.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

import 'package:clean_architecture_app/presentation/presenters/presenters.dart';
import 'package:clean_architecture_app/presentation/protocols/protocols.dart';

import '../../mocks/mocks.dart';

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
  late AccountEntity account;

  When mockValidationCall(String? field) => when(() => validation.validate(
      field: field ?? any(named: 'field'), input: any(named: 'input')));

  void mockValidation({String? field, ValidationError? value}) =>
      mockValidationCall(field).thenReturn(value);

  When mockAuthenticationCall() =>
      when(() => authentication.auth(any<AuthenticationParams>()));
  void mockAuthentication(AccountEntity data) {
    account = data;
    mockAuthenticationCall().thenAnswer((_) async => data);
  }

  void mockAuthenticationError(DomainError error) =>
      mockAuthenticationCall().thenThrow(error);

  When mockSaveCurrentAccountCall() =>
      when(() => saveCurrentAccount.save(any<AccountEntity>()));
  void mockSaveCurrentAccountError() =>
      mockSaveCurrentAccountCall().thenThrow(DomainError.unexpected);

  setUpAll(() {
    email = faker.internet.email();
    password = faker.internet.password();

    registerFallbackValue(AuthenticationParams(email: email, secret: password));
    registerFallbackValue(FakeAccountFactory.makeEntity());
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
    mockAuthentication(FakeAccountFactory.makeEntity());
  });
  test('Should call Validation with correct email', () {
    final formData = {'email': email, 'password': null};

    sut.validateEmail(email);

    verify(() => validation.validate(
          field: 'email',
          input: formData,
        )).called(1);
  });

  test('Should emit invalidFieldError if email is invalid', () {
    mockValidation(value: ValidationError.invalidField);

    // Aqui eu garanto que o listen só execute uma vez caso o valor anterior seja o mesmo.
    sut.emailErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    // Mesmo validando duas vezes com o mesmo valor, a stream só emite um.
    sut.validateEmail(email);
    sut.validateEmail(email);
  });

  test('Should emit requiredFieldError if email is empty', () {
    mockValidation(value: ValidationError.requiredField);

    // Aqui eu garanto que o listen só execute uma vez caso o valor anterior seja o mesmo.
    sut.emailErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.requiredField)));
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
    final formData = {'email': null, 'password': password};

    sut.validatePassword(password);

    verify(() => validation.validate(field: 'password', input: formData))
        .called(1);
  });

  test('Should emit requiredFieldError if password is empty', () {
    mockValidation(value: ValidationError.requiredField);

    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.requiredField)));
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

  test('Should disable form button if any field is invalid', () {
    mockValidation(field: 'email', value: ValidationError.invalidField);

    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(password);
    sut.validatePassword(password);
  });

  test('Should enable form button if all field are valid', () async {
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

    expectLater(sut.mainErrorStream, emits(null));
    expectLater(sut.isLoadingStream, emits(true));

    await sut.auth();
  });

  test('Should emit correct events on InvalidCredentialsError', () async {
    mockAuthenticationError(DomainError.invalidCredentials);

    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    expectLater(
      sut.mainErrorStream,
      emitsInOrder([null, UIError.invalidCredentials]),
    );

    await sut.auth();
  });

  test('Should emit correct events on UnexpectedError', () async {
    mockAuthenticationError(DomainError.unexpected);

    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    expectLater(sut.mainErrorStream, emitsInOrder([null, UIError.unexpected]));

    await sut.auth();
  });

  test('Should not emit after dispose', () async {
    mockSaveCurrentAccountError();

    expectLater(sut.emailErrorStream, neverEmits(null));
    expectLater(sut.passwordErrorStream, neverEmits(null));

    sut.dispose();

    sut.validateEmail(email);
    sut.validatePassword(password);
    await sut.auth();
  });

  test('Should call SaveCurrentAccount with correct value.', () async {
    sut.validateEmail(email);
    sut.validatePassword(password);

    await sut.auth();

    verify(() => saveCurrentAccount.save(account)).called(1);
  });

  test('Should emit UnexpectedError if SaveCurrentAccount fails', () async {
    mockSaveCurrentAccountError();

    sut.validateEmail(email);
    sut.validatePassword(password);

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    expectLater(sut.mainErrorStream, emitsInOrder([null, UIError.unexpected]));

    await sut.auth();
  });

  test('Should change page on success', () async {
    sut.validateEmail(email);
    sut.validatePassword(password);

    sut.navigateToStream
        .listen(expectAsync1((page) => expect(page, '/surveys')));

    await sut.auth();
  });

  test('Should go to SignUpPage on link click', () async {
    sut.navigateToStream
        .listen(expectAsync1((page) => expect(page, '/signup')));

    sut.goToSignUp();
  });
}
