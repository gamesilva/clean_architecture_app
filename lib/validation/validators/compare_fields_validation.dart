import '../../presentation/protocols/protocols.dart';
import '../protocols/protocols.dart';

class CompareFieldsValidation implements FieldValidation {
  @override
  final String field;
  final String fieldToCompare;

  CompareFieldsValidation({
    required this.field,
    required this.fieldToCompare,
  });

  @override
  ValidationError? validate(Map input) {
    return input[field] == input[fieldToCompare]
        ? null
        : ValidationError.invalidField;
  }
}
