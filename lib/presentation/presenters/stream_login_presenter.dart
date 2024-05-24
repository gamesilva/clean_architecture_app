import 'dart:async';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';
import '../../ui/pages/pages.dart';
import '../../ui/helpers/errors/ui_error.dart';
import '../protocols/protocols.dart';

class LoginState {
  String? email;
  UIError? emailError;
  String? password;
  UIError? passwordError;
  String? mainError;
  bool isLoading = false;

  bool get isFormValid =>
      emailError == null &&
      passwordError == null &&
      email != null &&
      password != null;
}

class StreamLoginPresenter implements LoginPresenter {
  final Validation validation;
  final Authentication authentication;
  final SaveCurrentAccount saveCurrentAccount;
  StreamController<LoginState>? _controller =
      StreamController<LoginState>.broadcast();
  final _state = LoginState();

  StreamController<UIError>? _controllerMainError =
      StreamController<UIError>.broadcast();
  StreamController<String>? _controllerNavigateTo =
      StreamController<String>.broadcast();

  // O distinct garante a emissão de valores diferentes do último
  @override
  Stream<UIError?> get emailErrorStream =>
      _controller!.stream.map((state) => state.emailError).distinct();

  @override
  Stream<UIError?> get passwordErrorStream =>
      _controller!.stream.map((state) => state.passwordError).distinct();

  @override
  Stream<UIError> get mainErrorStream =>
      _controllerMainError!.stream.distinct();

  @override
  Stream<String?> get navigateToStream =>
      _controllerNavigateTo!.stream.distinct();

  @override
  Stream<bool> get isFormValidStream =>
      _controller!.stream.map((state) => state.isFormValid).distinct();

  @override
  Stream<bool> get isLoadingStream =>
      _controller!.stream.map((state) => state.isLoading).distinct();

  StreamLoginPresenter({
    required this.validation,
    required this.authentication,
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

  @override
  void validateEmail(String email) {
    _state.email = email;
    _state.emailError = _validateField(field: 'email', value: email);
    _update();
  }

  @override
  void validatePassword(String password) {
    _state.password = password;
    _state.passwordError = _validateField(field: 'password', value: password);
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

  @override
  Future<void> auth() async {
    try {
      _state.isLoading = true;
      _update();

      final account = await authentication.auth(
        AuthenticationParams(email: _state.email!, secret: _state.password!),
      );

      await saveCurrentAccount.save(account);
      _updateNavigateTo('/surveys');
    } on DomainError catch (error) {
      switch (error) {
        case DomainError.invalidCredentials:
          _updateError(UIError.invalidCredentials);
          break;
        default:
          _updateError(UIError.unexpected);
      }

      _state.isLoading = false;
      _update();
    }
  }

  @override
  void dispose() {
    _controller?.close();
    _controller = null;

    _controllerMainError?.close();
    _controllerMainError = null;

    _controllerNavigateTo?.close();
    _controllerNavigateTo = null;
  }

  @override
  void goToSignUp() {
    _updateNavigateTo('/signup');
  }
}
