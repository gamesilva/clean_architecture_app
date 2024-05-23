import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/ui/helpers/errors/errors.dart';

import 'package:clean_architecture_app/presentation/presenters/presenters.dart';
import 'package:clean_architecture_app/presentation/protocols/protocols.dart';

class ValidationSpy extends Mock implements Validation {}

void main() {
  late Validation validation;
  late StreamSignUpPresenter sut;
  late String email;

  When mockValidationCall(String? field) => when(() => validation.validate(
      field: field ?? any(named: 'field'), value: any(named: 'value')));

  void mockValidation({String? field, ValidationError? value}) =>
      mockValidationCall(field).thenReturn(value);

  setUpAll(() {
    email = faker.internet.email();
  });

  setUp(() {
    validation = ValidationSpy();
    sut = StreamSignUpPresenter(
      validation: validation,
    );

    mockValidation();
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

  test('Should emit null if validation succeeds', () {
    sut.emailErrorStream.listen(expectAsync1((error) => expect(error, null)));
    sut.isFormValidStream
        .listen(expectAsync1((isValid) => expect(isValid, false)));

    sut.validateEmail(email);
    sut.validateEmail(email);
  });
}
