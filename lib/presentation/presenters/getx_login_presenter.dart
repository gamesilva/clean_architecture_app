import 'package:get/get.dart';

import '../../ui/pages/pages.dart';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';

import '../protocols/protocols.dart';

class GetxLoginPresenter extends GetxController implements LoginPresenter {
  final Validation validation;
  final Authentication authentication;

  String? _email;
  String? _password;
  final _emailError = RxnString();
  final _passwordError = RxnString();
  final _mainError = RxnString();
  final _navigateToError = RxnString();
  final _isFormValid = false.obs;
  final _isLoading = false.obs;

  // O distinct garante a emissão de valores diferentes do último
  @override
  Stream<String?> get emailErrorStream => _emailError.stream;

  @override
  Stream<String?> get passwordErrorStream => _passwordError.stream;

  @override
  Stream<String?> get mainErrorStream => _mainError.stream;

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
    _emailError.value = validation.validate(field: 'email', value: email);
    _validateForm();
  }

  @override
  void validatePassword(String password) {
    _password = password;
    _passwordError.value =
        validation.validate(field: 'password', value: password);
    _validateForm();
  }

  void _validateForm() {
    _isFormValid.value = _emailError.value == null &&
        _passwordError.value == null &&
        _email != null &&
        _password != null;
  }

  @override
  Future<void> auth() async {
    _isLoading.value = true;

    try {
      await authentication.auth(
        AuthenticationParams(email: _email!, secret: _password!),
      );
    } on DomainError catch (error) {
      _mainError.value = error.description;
    }

    _isLoading.value = false;
  }

  @override
  void dispose() {}
}
