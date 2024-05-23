import 'dart:async';

import '../../ui/helpers/errors/ui_error.dart';
import '../protocols/protocols.dart';

class SignUpState {
  UIError? emailError;

  bool get isFormValid => false;
}

class StreamSignUpPresenter {
  final Validation validation;

  StreamController<SignUpState>? _controller =
      StreamController<SignUpState>.broadcast();
  final _state = SignUpState();

  // O distinct garante a emissão de valores diferentes do último

  Stream<UIError?> get emailErrorStream =>
      _controller!.stream.map((state) => state.emailError).distinct();

  Stream<bool> get isFormValidStream =>
      _controller!.stream.map((state) => state.isFormValid).distinct();

  StreamSignUpPresenter({
    required this.validation,
  });

  void _update() {
    _controller?.add(_state);
  }

  void validateEmail(String email) {
    _state.emailError = _validateField(field: 'email', value: email);
    _update();
  }

  UIError? _validateField({required String field, required String value}) {
    final error = validation.validate(field: field, value: value);
    switch (error) {
      case ValidationError.invalidField:
        return UIError.invalidField;
      case ValidationError.requiredField:
        return UIError.requiredField;
      default:
        return null;
    }
  }

  void dispose() {
    _controller?.close();
    _controller = null;
  }
}
