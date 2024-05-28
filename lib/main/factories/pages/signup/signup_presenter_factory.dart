import '../../../../presentation/presenters/presenters.dart';
import '../../../../ui/pages/pages.dart';
import '../../factories.dart';

SignUpPresenter makeStreamSignUpPresenter() {
  return StreamSignUpPresenter(
    addAccount: makeRemoteAddAccount(),
    validation: makeSignUpValidation(),
    saveCurrentAccount: makeLocalSaveCurrentAccount(),
  );
}
