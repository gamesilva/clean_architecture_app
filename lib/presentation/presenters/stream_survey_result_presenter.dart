import 'dart:async';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';
import '../../ui/helpers/helpers.dart';
import '../../ui/pages/pages.dart';

class StreamSurveyResultPresenter implements SurveyResultPresenter {
  final LoadSurveyResult loadSurveyResult;
  final String surveyId;

  StreamController<bool?>? _isLoading = StreamController<bool>();
  StreamController<bool?>? _isSessionExpired = StreamController<bool>();
  StreamController<SurveyResultViewModel>? _surveyResult =
      StreamController<SurveyResultViewModel>();

  @override
  Stream<bool?> get isLoadingStream => _isLoading!.stream;

  @override
  Stream<bool?> get isSessionExpiredStream => _isSessionExpired!.stream;

  @override
  Stream<SurveyResultViewModel> get surveyResultStream => _surveyResult!.stream;

  StreamSurveyResultPresenter({
    required this.loadSurveyResult,
    required this.surveyId,
  });

  void _updateIsLoding(bool isLoading) {
    _isLoading?.add(isLoading);
  }

  void _updateIsSessionExpired(bool isSessionExpired) {
    _isSessionExpired?.add(isSessionExpired);
  }

  void _updateSurveyResult(SurveyResultViewModel surveyResult) {
    _surveyResult?.add(surveyResult);
  }

  @override
  Future<void>? loadData() async {
    try {
      _updateIsLoding(true);

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
        _updateIsSessionExpired(true);
      } else {
        _surveyResult?.addError(UIError.unexpected.description);
      }
    } finally {
      _updateIsLoding(false);
    }
  }

  @override
  void dispose() {
    _isLoading?.close();
    _isLoading = null;

    _surveyResult?.close();
    _surveyResult = null;
  }
}
