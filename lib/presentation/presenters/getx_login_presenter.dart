import 'package:get/get.dart';

import '../../ui/helpers/errors/errors.dart';
import '../../ui/pages/pages.dart';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';

import '../protocols/protocols.dart';

class GetxLoginPresenter extends GetxController implements LoginPresenter {
  final Validation validation;
  final Authentication authentication;

  String? _email;
  String? _password;
  final _emailError = Rxn<UIError>();
  final _passwordError = Rxn<UIError>();
  final _mainError = Rxn<UIError>();
  final _navigateToError = RxnString();
  final _isFormValid = false.obs;
  final _isLoading = false.obs;

  // O distinct garante a emissão de valores diferentes do último
  @override
  Stream<UIError?> get emailErrorStream => _emailError.stream;

  @override
  Stream<UIError?> get passwordErrorStream => _passwordError.stream;

  @override
  Stream<UIError?> get mainErrorStream => _mainError.stream;

  @override
  Stream<String?> get navigateToStream => _navigateToError.stream;

  @override
  Stream<bool> get isFormValidStream => _isFormValid.stream;

  @override
  Stream<bool> get isLoadingStream => _isLoading.stream;

  GetxLoginPresenter({
    required this.validation,
    required this.authentication,
  });

  @override
  void validateEmail(String email) {
    _email = email;
    _emailError.value = _validateField('email');
    _validateForm();
  }

  @override
  void validatePassword(String password) {
    _password = password;
    _passwordError.value = _validateField('password');
    _validateForm();
  }

  void _validateForm() {
    _isFormValid.value = _emailError.value == null &&
        _passwordError.value == null &&
        _email != null &&
        _password != null;
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
      default:
        return null;
    }
  }

  @override
  Future<void> auth() async {
    _isLoading.value = true;

    try {
      await authentication.auth(
        AuthenticationParams(email: _email!, secret: _password!),
      );
    } on DomainError catch (error) {
      switch (error) {
        case DomainError.invalidCredentials:
          _mainError.value = UIError.invalidCredentials;
          break;
        default:
          _mainError.value = UIError.unexpected;
      }
    }

    _isLoading.value = false;
  }

  @override
  void dispose() {}

  @override
  void goToSignUp() {
    // TODO: implement goToSignUp
  }
}
