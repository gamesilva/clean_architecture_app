import 'dart:async';

import 'package:intl/intl.dart';

import '../../domain/helpers/helpers.dart';
import '../../domain/usecases/usecases.dart';

import '../../ui/helpers/helpers.dart';
import '../../ui/pages/pages.dart';

class StreamSurveysPresenter implements SurveysPresenter {
  final LoadSurveys loadSurveys;

  StreamController<bool?>? _isLoading = StreamController<bool>();
  StreamController<List<SurveyViewModel>?>? _surveys =
      StreamController<List<SurveyViewModel>>();

  @override
  Stream<bool?> get isLoadingStream => _isLoading!.stream;

  @override
  Stream<List<SurveyViewModel>?> get surveysStream => _surveys!.stream;

  StreamSurveysPresenter({required this.loadSurveys});

  void _updateIsLoding(bool isLoading) {
    _isLoading?.add(isLoading);
  }

  void _updateSurveys(List<SurveyViewModel> surveys) {
    _surveys?.add(surveys);
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
    } on DomainError {
      _surveys?.addError(UIError.unexpected.description);
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
  }
}
