import '../../../../presentation/presenters/presenters.dart';
import '../../../../ui/pages/pages.dart';
import '../../factories.dart';

SplashPresenter makeStreamSplashPresenter() {
  return StreamSplashPresenter(
    loadCurrentAccount: makeLocalLoadCurrentAccount(),
  );
}
