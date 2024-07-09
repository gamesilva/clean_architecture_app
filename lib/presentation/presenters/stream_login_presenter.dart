import 'dart:async';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';
import '../../ui/pages/pages.dart';
import '../../ui/helpers/errors/ui_error.dart';
import '../mixins/mixins.dart';
import '../protocols/protocols.dart';

class StreamLoginPresenter
    with LoadingManager, FormManager, NavigationManager
    implements LoginPresenter {
  final Validation validation;
  final Authentication authentication;
  final SaveCurrentAccount saveCurrentAccount;

  String? _email;
  String? _password;

  UIError? _emailErrorValue;
  UIError? _passwordErrorValue;

  String? mainError;

  StreamController<UIError?>? _emailError =
      StreamController<UIError?>.broadcast();
  StreamController<UIError?>? _passwordError =
      StreamController<UIError?>.broadcast();

  StreamController<UIError?>? _controllerMainError =
      StreamController<UIError?>.broadcast();

  // O distinct garante a emissão de valores diferentes do último
  @override
  Stream<UIError?> get emailErrorStream => _emailError!.stream.distinct();

  @override
  Stream<UIError?> get passwordErrorStream => _passwordError!.stream.distinct();

  @override
  Stream<UIError?> get mainErrorStream =>
      _controllerMainError!.stream.distinct();

  StreamLoginPresenter({
    required this.validation,
    required this.authentication,
    required this.saveCurrentAccount,
  });

  void _updateError(UIError? error) {
    _controllerMainError?.add(error);
  }

  @override
  void validateEmail(String email) {
    _email = email;
    _emailErrorValue = _validateField('email');
    _emailError?.add(_emailErrorValue);
    _validateForm();
  }

  @override
  void validatePassword(String password) {
    _password = password;
    _passwordErrorValue = _validateField('password');
    _passwordError?.add(_passwordErrorValue);
    _validateForm();
  }

  UIError? _validateField(String field) {
    final formData = {
      'email': _email,
      'password': _password,
    };

    final error = validation.validate(field: field, input: formData);
    switch (error) {
      case ValidationError.invalidField:
        return UIError.invalidField;
      case ValidationError.requiredField:
        return UIError.requiredField;
      default:
        return null;
    }
  }

  void _validateForm() {
    isFormValid = _emailErrorValue == null &&
        _passwordErrorValue == null &&
        _email != null &&
        _password != null;
  }

  @override
  Future<void> auth() async {
    try {
      _updateError(null);

      isLoading = true;

      final account = await authentication.auth(
        AuthenticationParams(email: _email!, secret: _password!),
      );

      await saveCurrentAccount.save(account);
      navigateTo = '/surveys';
    } on DomainError catch (error) {
      switch (error) {
        case DomainError.invalidCredentials:
          _updateError(UIError.invalidCredentials);
          break;
        default:
          _updateError(UIError.unexpected);
      }

      isLoading = false;
    }
  }

  @override
  void dispose() {
    _emailError?.close();
    _emailError = null;

    _passwordError?.close();
    _passwordError = null;

    _controllerMainError?.close();
    _controllerMainError = null;
  }

  @override
  void goToSignUp() {
    navigateTo = '/signup';
  }
}
