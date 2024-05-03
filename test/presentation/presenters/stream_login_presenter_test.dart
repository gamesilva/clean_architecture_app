import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/presentation/presenters/presenters.dart';
import 'package:clean_architecture_app/presentation/protocols/protocols.dart';

class ValidationSpy extends Mock implements Validation {}

void main() {
  late Validation validation;
  late StreamLoginPresenter sut;
  late String email;
  When mockValidationCall(String? field) => when(() => validation.validate(
      field: field ?? any(named: 'field'), value: any(named: 'value')));

  void mockValidation({String? field, String? value}) =>
      mockValidationCall(field).thenReturn(value);

  setUp(() {
    validation = ValidationSpy();
    sut = StreamLoginPresenter(validation: validation);
    email = faker.internet.email();
    mockValidation();
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

    // Mesmo validando duas vezes com o mesmo valor, a stream só emite um.
    sut.validateEmail(email);
    sut.validateEmail(email);
  });
}
