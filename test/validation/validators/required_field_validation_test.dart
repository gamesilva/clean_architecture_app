import 'package:test/test.dart';

import 'package:clean_architecture_app/presentation/protocols/protocols.dart';
import 'package:clean_architecture_app/validation/validators/validators.dart';

void main() {
  late RequiredFieldValidation sut;

  setUp(() {
    sut = RequiredFieldValidation('any_field');
  });

  test('Should return null if value is not empty', () {
    expect(sut.validate({'any_field': 'any_field'}), null);
  });

  test('Should return error if value empty', () {
    expect(sut.validate({'any_field': ''}), ValidationError.requiredField);
  });

  test('Should return error if value null', () {
    expect(sut.validate({'any_field': null}), ValidationError.requiredField);
  });
}
