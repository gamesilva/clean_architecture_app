import 'dart:async';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';
import '../../ui/helpers/helpers.dart';
import '../../ui/pages/pages.dart';
import '../mixins/mixins.dart';

class StreamSurveyResultPresenter
    with LoadingManager, SessionManager
    implements SurveyResultPresenter {
  final LoadSurveyResult loadSurveyResult;
  final SaveSurveyResult saveSurveyResult;
  final String surveyId;

  StreamController<SurveyResultViewModel>? _surveyResult =
      StreamController<SurveyResultViewModel>();

  @override
  Stream<SurveyResultViewModel> get surveyResultStream => _surveyResult!.stream;

  StreamSurveyResultPresenter({
    required this.loadSurveyResult,
    required this.saveSurveyResult,
    required this.surveyId,
  });

  void _updateSurveyResult(SurveyResultViewModel surveyResult) {
    _surveyResult?.add(surveyResult);
  }

  @override
  Future<void>? loadData() async {
    try {
      isLoading = true;

      final surveyResult = await loadSurveyResult.loadBySurvey(
        surveyId: surveyId,
      );

      final surveyResultViewModel = SurveyResultViewModel(
        surveyId: surveyResult?.surveyId,
        question: surveyResult?.question,
        answers: surveyResult?.answers
            ?.map(
              (answer) => SurveyAnswerViewModel(
                image: answer.image,
                answer: answer.answer,
                isCurrentAnswer: answer.isCurrentAnswer,
                percent: '${answer.percent}%',
              ),
            )
            .toList(),
      );
      _updateSurveyResult(surveyResultViewModel);
    } on DomainError catch (error) {
      if (error == DomainError.accessDenied) {
        isSessionExpired = true;
      } else {
        _surveyResult?.addError(UIError.unexpected.description);
      }
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    _surveyResult?.close();
    _surveyResult = null;

    closeLoadingManagerStream();
    closeSessionManagerStream();
  }

  @override
  Future<void>? save({required String answer}) async {
    try {
      isLoading = true;

      final surveyResult = await saveSurveyResult.save(answer: answer);

      final surveyResultViewModel = SurveyResultViewModel(
        surveyId: surveyResult?.surveyId,
        question: surveyResult?.question,
        answers: surveyResult?.answers
            ?.map(
              (answer) => SurveyAnswerViewModel(
                image: answer.image,
                answer: answer.answer,
                isCurrentAnswer: answer.isCurrentAnswer,
                percent: '${answer.percent}%',
              ),
            )
            .toList(),
      );
      _updateSurveyResult(surveyResultViewModel);
    } on DomainError catch (error) {
      if (error == DomainError.accessDenied) {
        isSessionExpired = true;
      } else {
        _surveyResult?.addError(UIError.unexpected.description);
      }
    } finally {
      isLoading = false;
    }
  }
}
