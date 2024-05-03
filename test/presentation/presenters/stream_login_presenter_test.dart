import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

abstract class Validation {
  String? validate({required String field, required String value});
}

class ValidationSpy extends Mock implements Validation {}

class StreamLoginPresenter {
  final Validation validation;

  StreamLoginPresenter({required this.validation});

  void validateEmail(String email) {
    validation.validate(field: 'email', value: email);
  }
}

void main() {
  late Validation validation;
  late StreamLoginPresenter sut;
  late String email;

  setUp(() {
    validation = ValidationSpy();
    sut = StreamLoginPresenter(validation: validation);
    email = faker.internet.email();
  });
  test('Should call Validation with correct email', () {
    sut.validateEmail(email);

    verify(() => validation.validate(field: 'email', value: email)).called(1);
  });
}
