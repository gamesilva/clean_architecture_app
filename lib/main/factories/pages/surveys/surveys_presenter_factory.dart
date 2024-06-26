import '../../../../presentation/presenters/presenters.dart';
import '../../../../ui/pages/pages.dart';
import '../../factories.dart';

SurveysPresenter makeStreamSurveysPresenter() {
  return StreamSurveysPresenter(
    loadSurveys: makeRemoteLoadSurveysWithLocalFallback(),
  );
}
