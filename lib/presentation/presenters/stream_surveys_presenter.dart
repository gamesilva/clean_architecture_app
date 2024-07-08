import 'dart:async';

import 'package:intl/intl.dart';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';

import '../../ui/helpers/helpers.dart';
import '../../ui/pages/pages.dart';

class StreamSurveysPresenter implements SurveysPresenter {
  final LoadSurveys loadSurveys;

  StreamController<bool?>? _isLoading = StreamController<bool>();
  StreamController<bool?>? _isSessionExpired = StreamController<bool>();
  StreamController<List<SurveyViewModel>?>? _surveys =
      StreamController<List<SurveyViewModel>>();
  StreamController<String>? _controllerNavigateTo =
      StreamController<String>.broadcast();

  @override
  Stream<bool?> get isLoadingStream => _isLoading!.stream;

  @override
  Stream<bool?> get isSessionExpiredStream => _isSessionExpired!.stream;

  @override
  Stream<List<SurveyViewModel>?> get surveysStream => _surveys!.stream;

  Stream<String?> get navigateToStream =>
      _controllerNavigateTo!.stream.distinct();

  StreamSurveysPresenter({required this.loadSurveys});

  void _updateIsLoding(bool isLoading) {
    _isLoading?.add(isLoading);
  }

  void _updateIsSessionExpired(bool isSessionExpired) {
    _isSessionExpired?.add(isSessionExpired);
  }

  void _updateSurveys(List<SurveyViewModel> surveys) {
    _surveys?.add(surveys);
  }

  void _updateNavigateTo(String route) {
    _controllerNavigateTo?.add(route);
  }

  @override
  Future<void>? loadData() async {
    try {
      _updateIsLoding(true);

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
        _updateIsSessionExpired(true);
      } else {
        _surveys?.addError(UIError.unexpected.description);
      }
    } finally {
      _updateIsLoding(false);
    }
  }

  @override
  void dispose() {
    _isLoading?.close();
    _isLoading = null;

    _surveys?.close();
    _surveys = null;

    _controllerNavigateTo?.close();
    _controllerNavigateTo = null;
  }

  @override
  void goToSurveyResult(String surveyId) {
    _updateNavigateTo('/survey_result/$surveyId');
  }
}
