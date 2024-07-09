import 'dart:async';

import 'package:intl/intl.dart';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';

import '../../ui/helpers/helpers.dart';
import '../../ui/pages/pages.dart';

import '../mixins/mixins.dart';

class StreamSurveysPresenter
    with SessionManager, LoadingManager, NavigationManager
    implements SurveysPresenter {
  final LoadSurveys loadSurveys;

  StreamController<List<SurveyViewModel>?>? _surveys =
      StreamController<List<SurveyViewModel>>();

  @override
  Stream<List<SurveyViewModel>?> get surveysStream => _surveys!.stream;

  StreamSurveysPresenter({required this.loadSurveys});

  void _updateSurveys(List<SurveyViewModel> surveys) {
    _surveys?.add(surveys);
  }

  @override
  Future<void>? loadData() async {
    try {
      isLoading = true;

      final surveys = await loadSurveys.load();
      final surveysViewModel = surveys!
          .map((survey) => SurveyViewModel(
                id: survey.id!,
                question: survey.question!,
                date: DateFormat('dd MMM yyyy').format(survey.dateTime!),
                didAnswer: survey.didAnswer!,
              ))
          .toList();
      _updateSurveys(surveysViewModel);
    } on DomainError catch (error) {
      if (error == DomainError.accessDenied) {
        isSessionExpired = true;
      } else {
        _surveys?.addError(UIError.unexpected.description);
      }
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    _surveys?.close();
    _surveys = null;
  }

  @override
  void goToSurveyResult(String surveyId) {
    navigateTo = '/survey_result/$surveyId';
  }
}
