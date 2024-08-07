import 'dart:async';

import '../../domain/entities/entities.dart';
import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';
import '../../ui/helpers/helpers.dart';
import '../../ui/pages/pages.dart';

import '../helpers/helpers.dart';
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
    showResultOnAction(() => loadSurveyResult.loadBySurvey(surveyId: surveyId));
  }

  @override
  Future<void>? save({required String answer}) async {
    showResultOnAction(() => saveSurveyResult.save(answer: answer));
  }

  Future<void>? showResultOnAction(
    Future<SurveyResultEntity>? Function() action,
  ) async {
    try {
      isLoading = true;

      final surveyResult = await action();
      _updateSurveyResult(surveyResult!.toViewModel());
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

  void dispose() {
    _surveyResult?.close();
    _surveyResult = null;

    closeLoadingManagerStream();
    closeSessionManagerStream();
  }
}
