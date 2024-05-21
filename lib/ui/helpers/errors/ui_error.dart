import 'package:clean_architecture_app/ui/helpers/i18n/i18n.dart';

enum UIError {
  requiredField,
  invalidField,
  unexpected,
  invalidCredentials,
}

extension UIErrorExtension on UIError {
  String get description {
    switch (this) {
      case UIError.requiredField:
        return R.strings.msgRequiredField;
      case UIError.invalidField:
        return R.strings.msgInvalidField;
      case UIError.invalidCredentials:
        return R.strings.msgInvalidCredentials;
      default:
        return R.strings.msgUnexpectedError;
    }
  }
}
