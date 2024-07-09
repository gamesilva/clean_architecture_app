import 'dart:async';

import '../../domain/usecases/usecases.dart';
import '../../domain/helpers/helpers.dart';

import '../../ui/helpers/errors/ui_error.dart';
import '../../ui/pages/pages.dart';
import '../protocols/protocols.dart';
import '../mixins/mixins.dart';

class StreamSignUpPresenter
    with LoadingManager, FormManager, NavigationManager, UIErrorManager
    implements SignUpPresenter {
  final Validation validation;
  final AddAccount addAccount;
  final SaveCurrentAccount saveCurrentAccount;

  String? _name;
  String? _email;
  String? _password;
  String? _passwordConfirmation;

  UIError? _emailErrorValue;
  UIError? _nameErrorValue;
  UIError? _passwordErrorValue;
  UIError? _passwordConfirmationErrorValue;

  StreamController<UIError?>? _emailError =
      StreamController<UIError?>.broadcast();

  StreamController<UIError?>? _nameError =
      StreamController<UIError?>.broadcast();

  StreamController<UIError?>? _passwordError =
      StreamController<UIError?>.broadcast();

  StreamController<UIError?>? _passwordConfirmationError =
      StreamController<UIError?>.broadcast();

  // O distinct garante a emissão de valores diferentes do último
  @override
  Stream<UIError?> get nameErrorStream => _nameError!.stream.distinct();

  @override
  Stream<UIError?> get emailErrorStream => _emailError!.stream.distinct();

  @override
  Stream<UIError?> get passwordErrorStream => _passwordError!.stream.distinct();

  @override
  Stream<UIError?> get passwordConfirmationErrorStream =>
      _passwordConfirmationError!.stream.distinct();

  StreamSignUpPresenter({
    required this.validation,
    required this.addAccount,
    required this.saveCurrentAccount,
  });

  @override
  void validateName(String name) {
    _name = name;
    _nameErrorValue = _validateField('name');
    _nameError?.add(_nameErrorValue);
    _validateForm();
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

  @override
  void validatePasswordConfirmation(String passwordConfirmation) {
    _passwordConfirmation = passwordConfirmation;
    _passwordConfirmationErrorValue = _validateField('passwordConfirmation');
    _passwordConfirmationError?.add(_passwordConfirmationErrorValue);
    _validateForm();
  }

  UIError? _validateField(String field) {
    final formData = {
      'name': _name,
      'email': _email,
      'password': _password,
      'passwordConfirmation': _passwordConfirmation,
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
    isFormValid = _nameErrorValue == null &&
        _emailErrorValue == null &&
        _passwordErrorValue == null &&
        _passwordConfirmationErrorValue == null &&
        _name != null &&
        _email != null &&
        _password != null &&
        _passwordConfirmation != null;
  }

  @override
  Future<void> signUp() async {
    try {
      mainError = null;

      isLoading = true;

      final account = await addAccount.add(
        AddAccountParams(
          name: _name!,
          email: _email!,
          password: _password!,
          passwordConfirmation: _passwordConfirmation!,
        ),
      );
      await saveCurrentAccount.save(account);
      navigateTo = '/surveys';
    } on DomainError catch (error) {
      switch (error) {
        case DomainError.emailInUse:
          mainError = UIError.emailInUse;
          break;
        default:
          mainError = UIError.unexpected;
      }

      isLoading = false;
    }
  }

  @override
  void dispose() {
    _emailError?.close();
    _emailError = null;

    _nameError?.close();
    _nameError = null;

    _passwordError?.close();
    _passwordError = null;

    _passwordConfirmationError?.close();
    _passwordConfirmationError = null;
  }

  @override
  void goToLogin() {
    navigateTo = '/login';
  }
}
