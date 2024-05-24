import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/helpers/helpers.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

import 'package:clean_architecture_app/ui/helpers/errors/errors.dart';

import 'package:clean_architecture_app/presentation/presenters/presenters.dart';
import 'package:clean_architecture_app/presentation/protocols/protocols.dart';

class ValidationSpy extends Mock implements Validation {}

class AddAccountSpy extends Mock implements AddAccount {}

class SaveCurrentAccountSpy extends Mock implements SaveCurrentAccount {}

void main() {
  late Validation validation;
  late StreamSignUpPresenter sut;
  late AddAccount addAccount;
  late SaveCurrentAccount saveCurrentAccount;

  late String name;
  late String email;
  late String password;
  late String passwordConfirmation;
  late String token;

  When mockValidationCall(String? field) => when(() => validation.validate(
      field: field ?? any(named: 'field'), value: any(named: 'value')));

  void mockValidation({String? field, ValidationError? value}) =>
      mockValidationCall(field).thenReturn(value);

  When mockAddAccountCall() =>
      when(() => addAccount.add(any<AddAccountParams>()));

  void mockAddAccount() =>
      mockAddAccountCall().thenAnswer((_) async => AccountEntity(token));

  When mockSaveCurrentAccountCall() =>
      when(() => saveCurrentAccount.save(any<AccountEntity>()));
  void mockSaveCurrentAccountError() =>
      mockSaveCurrentAccountCall().thenThrow(DomainError.unexpected);

  setUpAll(() {
    name = faker.person.name();
    email = faker.internet.email();
    password = faker.internet.password();
    passwordConfirmation = faker.internet.password();
    token = faker.guid.guid();

    registerFallbackValue(AddAccountParams(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    ));
    registerFallbackValue(AccountEntity(token));
  });

  setUp(() {
    validation = ValidationSpy();
    addAccount = AddAccountSpy();
    saveCurrentAccount = SaveCurrentAccountSpy();

    sut = StreamSignUpPresenter(
      validation: validation,
      addAccount: addAccount,
      saveCurrentAccount: saveCurrentAccount,
    );

    mockValidation();
    mockAddAccount();
  });
  test('Should call Validation with correct email', () {
    sut.validateEmail(email);

    verify(() => validation.validate(field: 'email', value: email)).called(1);
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

  test('Should emit null if email validation succeeds', () {
    sut.emailErrorStream.listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(email);
    sut.validateEmail(email);
  });

  test('Should call Validation with correct name', () {
    sut.validateName(name);

    verify(() => validation.validate(field: 'name', value: name)).called(1);
  });

  test('Should emit invalidFieldError if name is invalid', () {
    mockValidation(value: ValidationError.invalidField);

    // Aqui eu garanto que o listen só execute uma vez caso o valor anterior seja o mesmo.
    sut.nameErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    // Mesmo validando duas vezes com o mesmo valor, a stream só emite um.
    sut.validateName(name);
    sut.validateName(name);
  });

  test('Should emit requiredFieldError if name is empty', () {
    mockValidation(value: ValidationError.requiredField);

    // Aqui eu garanto que o listen só execute uma vez caso o valor anterior seja o mesmo.
    sut.nameErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.requiredField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    // Mesmo validando duas vezes com o mesmo valor, a stream só emite um.
    sut.validateName(name);
    sut.validateName(name);
  });

  test('Should emit null if name validation succeeds', () {
    sut.nameErrorStream.listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateName(name);
    sut.validateName(name);
  });

  test('Should call Validation with correct password', () {
    sut.validatePassword(password);

    verify(() => validation.validate(field: 'password', value: password))
        .called(1);
  });

  test('Should emit invalidFieldError if password is invalid', () {
    mockValidation(value: ValidationError.invalidField);

    // Aqui eu garanto que o listen só execute uma vez caso o valor anterior seja o mesmo.
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    // Mesmo validando duas vezes com o mesmo valor, a stream só emite um.
    sut.validatePassword(password);
    sut.validatePassword(password);
  });

  test('Should emit requiredFieldError if password is empty', () {
    mockValidation(value: ValidationError.requiredField);

    // Aqui eu garanto que o listen só execute uma vez caso o valor anterior seja o mesmo.
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.requiredField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    // Mesmo validando duas vezes com o mesmo valor, a stream só emite um.
    sut.validatePassword(password);
    sut.validatePassword(password);
  });

  test('Should emit null if password validation succeeds', () {
    sut.passwordErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validatePassword(password);
    sut.validatePassword(password);
  });

  test('Should call Validation with correct passwordConfirmation', () {
    sut.validatePasswordConfirmation(passwordConfirmation);

    verify(() => validation.validate(
        field: 'passwordConfirmation', value: passwordConfirmation)).called(1);
  });

  test('Should emit invalidFieldError if passwordConfirmation is invalid', () {
    mockValidation(value: ValidationError.invalidField);

    // Aqui eu garanto que o listen só execute uma vez caso o valor anterior seja o mesmo.
    sut.passwordConfirmationErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.invalidField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    // Mesmo validando duas vezes com o mesmo valor, a stream só emite um.
    sut.validatePasswordConfirmation(passwordConfirmation);
    sut.validatePasswordConfirmation(passwordConfirmation);
  });

  test('Should emit requiredFieldError if passwordConfirmation is empty', () {
    mockValidation(value: ValidationError.requiredField);

    // Aqui eu garanto que o listen só execute uma vez caso o valor anterior seja o mesmo.
    sut.passwordConfirmationErrorStream
        .listen(expectAsync1((error) => expect(error, UIError.requiredField)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    // Mesmo validando duas vezes com o mesmo valor, a stream só emite um.
    sut.validatePasswordConfirmation(passwordConfirmation);
    sut.validatePasswordConfirmation(passwordConfirmation);
  });

  test('Should emit null if passwordConfirmation validation succeeds', () {
    sut.passwordConfirmationErrorStream
        .listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validatePasswordConfirmation(passwordConfirmation);
    sut.validatePasswordConfirmation(passwordConfirmation);
  });

  test('Should enable form button if all field are valid', () async {
    expectLater(sut.isFormValidStream, emitsInOrder([false, true]));

    sut.validateName(name);
    await Future.delayed(Duration.zero);
    sut.validateEmail(email);
    await Future.delayed(Duration.zero);
    sut.validatePassword(password);
    await Future.delayed(Duration.zero);
    sut.validatePasswordConfirmation(passwordConfirmation);
    await Future.delayed(Duration.zero);
  });

  test('Should call AddAccount with correct values.', () async {
    sut.validateName(name);
    sut.validateEmail(email);
    sut.validatePassword(password);
    sut.validatePasswordConfirmation(passwordConfirmation);

    await sut.signUp();

    verify(() => addAccount.add(
          AddAccountParams(
            name: name,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation,
          ),
        )).called(1);
  });

  test('Should call SaveCurrentAccount with correct value.', () async {
    sut.validateName(name);
    sut.validateEmail(email);
    sut.validatePassword(password);
    sut.validatePasswordConfirmation(passwordConfirmation);

    await sut.signUp();

    verify(() => saveCurrentAccount.save(AccountEntity(token))).called(1);
  });
}
