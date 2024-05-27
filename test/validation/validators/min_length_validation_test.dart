import 'package:test/test.dart';

import 'package:clean_architecture_app/presentation/protocols/protocols.dart';
import 'package:clean_architecture_app/validation/protocols/protocols.dart';

class MinLengthValidation implements FieldValidation {
  @override
  final String field;
  final int size;

  MinLengthValidation({required this.field, required this.size});

  @override
  ValidationError? validate(String? value) {
    return ValidationError.invalidField;
  }
}

void main() {
  late MinLengthValidation sut;
  setUp(() {
    sut = MinLengthValidation(field: 'any_field', size: 5);
  });

  test('Should return error if value is empty', () {
    expect(sut.validate(''), ValidationError.invalidField);
  });

  test('Should return error if value is null', () {
    expect(sut.validate(null), ValidationError.invalidField);
  });
}
