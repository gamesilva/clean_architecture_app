import '../../../../presentation/presenters/presenters.dart';
import '../../../../ui/pages/pages.dart';
import '../../usecases/usecases.dart';

SurveyResultPresenter makeStreamSurveyResultPresenter(String surveyId) {
  return StreamSurveyResultPresenter(
    loadSurveyResult: makeRemoteLoadSurveyResult(surveyId),
    surveyId: surveyId,
  );
}
