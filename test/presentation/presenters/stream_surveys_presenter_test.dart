import 'dart:async';
import 'package:clean_architecture_app/domain/helpers/helpers.dart';
import 'package:clean_architecture_app/ui/helpers/helpers.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:intl/intl.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

import 'package:clean_architecture_app/ui/pages/pages.dart';

class StreamSurveysPresenter {
  final LoadSurveys loadSurveys;

  final StreamController<bool> _isLoading = StreamController<bool>();
  final StreamController<List<SurveyViewModel>> _surveys =
      StreamController<List<SurveyViewModel>>();

  Stream<bool> get isLoadingStream => _isLoading.stream;

  Stream<List<SurveyViewModel>> get surveyStream => _surveys.stream;

  StreamSurveysPresenter({required this.loadSurveys});

  void _updateIsLoding(bool isLoading) {
    _isLoading.add(isLoading);
  }

  void _updateSurveys(List<SurveyViewModel> surveys) {
    _surveys.add(surveys);
  }

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
      _surveys.addError(UIError.unexpected.description);
    } finally {
      _updateIsLoding(false);
    }
  }
}

class LoadSurveysSpy extends Mock implements LoadSurveys {}

void main() {
  late LoadSurveysSpy loadSurveys;
  late StreamSurveysPresenter sut;
  late List<SurveyEntity> surveys;

  List<SurveyEntity> mockValidData() => [
        SurveyEntity(
            id: faker.guid.guid(),
            question: faker.lorem.sentence(),
            dateTime: DateTime(2020, 2, 20),
            didAnswer: true),
        SurveyEntity(
            id: faker.guid.guid(),
            question: faker.lorem.sentence(),
            dateTime: DateTime(2018, 10, 3),
            didAnswer: false),
      ];

  When mockLoadSurveysCall() => when(() => loadSurveys.load());

  void mockLoadSurveys(List<SurveyEntity> data) {
    surveys = data;
    mockLoadSurveysCall().thenAnswer((_) async => data);
  }

  void mockLoadSurveysError() =>
      mockLoadSurveysCall().thenThrow(DomainError.unexpected);

  setUp(() {
    loadSurveys = LoadSurveysSpy();
    sut = StreamSurveysPresenter(loadSurveys: loadSurveys);

    mockLoadSurveys(mockValidData());
  });

  test('Should call LoadSurveys on loadData', () async {
    await sut.loadData();

    verify(() => loadSurveys.load()).called(1);
  });

  test('Should emit correct events on success', () async {
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    sut.surveyStream.listen(expectAsync1((surveys) => expect(surveys, [
          SurveyViewModel(
            id: surveys[0].id,
            question: surveys[0].question,
            date: '20 Feb 2020',
            didAnswer: surveys[0].didAnswer,
          ),
          SurveyViewModel(
            id: surveys[1].id,
            question: surveys[1].question,
            date: '03 Oct 2018',
            didAnswer: surveys[1].didAnswer,
          ),
        ])));

    await sut.loadData();
  });

  test('Should emit correct events on failure', () async {
    mockLoadSurveysError();

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    sut.surveyStream.listen(null,
        onError: expectAsync1((error) => expect(
              error,
              UIError.unexpected.description,
            )));

    await sut.loadData();
  });
}
