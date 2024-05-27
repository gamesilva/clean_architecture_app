import 'package:equatable/equatable.dart';

import '../../presentation/protocols/protocols.dart';
import '../protocols/protocols.dart';

class MinLengthValidation extends Equatable implements FieldValidation {
  @override
  final String field;
  final int size;

  @override
  List get props => [field, size];

  MinLengthValidation({
    required this.field,
    required this.size,
  });

  @override
  ValidationError? validate(String? value) {
    return value != null && value.length >= size
        ? null
        : ValidationError.invalidField;
  }
}
