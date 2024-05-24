import 'dart:async';

import '../../domain/usecases/usecases.dart';
import '../../domain/helpers/helpers.dart';

import '../../ui/helpers/errors/ui_error.dart';
import '../protocols/protocols.dart';

class SignUpState {
  UIError? emailError;
  UIError? nameError;
  UIError? passwordError;
  UIError? passwordConfirmationError;
  String? name;
  String? email;
  String? password;
  String? passwordConfirmation;
  bool isLoading = false;

  bool get isFormValid =>
      nameError == null &&
      emailError == null &&
      passwordError == null &&
      passwordConfirmationError == null &&
      name != null &&
      email != null &&
      password != null &&
      passwordConfirmation != null;
}

class StreamSignUpPresenter {
  final Validation validation;
  final AddAccount addAccount;
  final SaveCurrentAccount saveCurrentAccount;

  StreamController<SignUpState>? _controller =
      StreamController<SignUpState>.broadcast();

  StreamController<UIError>? _controllerMainError =
      StreamController<UIError>.broadcast();

  StreamController<String>? _controllerNavigateTo =
      StreamController<String>.broadcast();

  final _state = SignUpState();

  // O distinct garante a emissão de valores diferentes do último

  Stream<UIError?> get nameErrorStream =>
      _controller!.stream.map((state) => state.nameError).distinct();

  Stream<UIError?> get emailErrorStream =>
      _controller!.stream.map((state) => state.emailError).distinct();

  Stream<UIError?> get passwordErrorStream =>
      _controller!.stream.map((state) => state.passwordError).distinct();

  Stream<UIError?> get passwordConfirmationErrorStream => _controller!.stream
      .map((state) => state.passwordConfirmationError)
      .distinct();

  Stream<UIError> get mainErrorStream =>
      _controllerMainError!.stream.distinct();

  Stream<String?> get navigateToStream =>
      _controllerNavigateTo!.stream.distinct();

  Stream<bool> get isFormValidStream =>
      _controller!.stream.map((state) => state.isFormValid).distinct();

  Stream<bool> get isLoadingStream =>
      _controller!.stream.map((state) => state.isLoading).distinct();

  StreamSignUpPresenter({
    required this.validation,
    required this.addAccount,
    required this.saveCurrentAccount,
  });

  void _update() {
    _controller?.add(_state);
  }

  void _updateError(UIError error) {
    _controllerMainError?.add(error);
  }

  void _updateNavigateTo(String route) {
    _controllerNavigateTo?.add(route);
  }

  void validateName(String name) {
    _state.name = name;
    _state.nameError = _validateField(field: 'name', value: name);
    _update();
  }

  void validateEmail(String email) {
    _state.email = email;
    _state.emailError = _validateField(field: 'email', value: email);
    _update();
  }

  void validatePassword(String password) {
    _state.password = password;
    _state.passwordError = _validateField(field: 'password', value: password);
    _update();
  }

  void validatePasswordConfirmation(String passwordConfirmation) {
    _state.passwordConfirmation = passwordConfirmation;
    _state.passwordConfirmationError = _validateField(
      field: 'passwordConfirmation',
      value: passwordConfirmation,
    );
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

  Future<void> signUp() async {
    try {
      _state.isLoading = true;
      _update();

      final account = await addAccount.add(
        AddAccountParams(
          name: _state.name!,
          email: _state.email!,
          password: _state.password!,
          passwordConfirmation: _state.passwordConfirmation!,
        ),
      );
      await saveCurrentAccount.save(account);
      _updateNavigateTo('/surveys');
    } on DomainError catch (error) {
      switch (error) {
        case DomainError.emailInUse:
          _updateError(UIError.emailInUse);
          break;
        default:
          _updateError(UIError.unexpected);
      }

      _state.isLoading = false;
      _update();
    }
  }

  void dispose() {
    _controller?.close();
    _controller = null;

    _controllerMainError?.close();
    _controllerMainError = null;
  }
}
