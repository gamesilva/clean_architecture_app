import 'package:test/test.dart';

abstract class FieldValidation {
  String get field;
  String? validate(String value);
}

class RequiredFieldValidation implements FieldValidation {
  @override
  final String field;

  RequiredFieldValidation(this.field);

  @override
  String? validate(String? value) {
    return value?.isNotEmpty == true ? null : 'Campo obrigatório';
  }
}

void main() {
  late RequiredFieldValidation sut;

  setUp(() {
    sut = RequiredFieldValidation('any_field');
  });

  test('Should return null if value is not empty', () {
    expect(sut.validate('any_field'), null);
  });
  test('Should return error if value empty', () {
    expect(sut.validate(''), 'Campo obrigatório');
  });
  test('Should return error if value null', () {
    expect(sut.validate(null), 'Campo obrigatório');
  });
}
