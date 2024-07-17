import 'package:clean_architecture_app/domain/helpers/helpers.dart';
import 'package:clean_architecture_app/ui/helpers/helpers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

import 'package:clean_architecture_app/presentation/presenters/presenters.dart';

import 'package:clean_architecture_app/ui/pages/pages.dart';

import '../../mocks/mocks.dart';

class LoadSurveysSpy extends Mock implements LoadSurveys {}

void main() {
  late LoadSurveys loadSurveys;
  late StreamSurveysPresenter sut;

  When mockLoadSurveysCall() => when(() => loadSurveys.load());

  void mockLoadSurveys(List<SurveyEntity> data) =>
      mockLoadSurveysCall().thenAnswer((_) async => data);

  void mockLoadSurveysError() =>
      mockLoadSurveysCall().thenThrow(DomainError.unexpected);

  void mockAccessDeniedError() =>
      mockLoadSurveysCall().thenThrow(DomainError.accessDenied);

  setUp(() {
    loadSurveys = LoadSurveysSpy();
    sut = StreamSurveysPresenter(loadSurveys: loadSurveys);

    mockLoadSurveys(FakeSurveysFactory.makeEntities());
  });

  test('Should call LoadSurveys on loadData', () async {
    await sut.loadData();

    verify(() => loadSurveys.load()).called(1);
  });

  test('Should emit correct events on success', () async {
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    sut.surveysStream.listen(expectAsync1((surveys) => expect(surveys, [
          SurveyViewModel(
            id: surveys![0].id,
            question: surveys[0].question,
            date: '02 Feb 2020',
            didAnswer: surveys[0].didAnswer,
          ),
          SurveyViewModel(
            id: surveys[1].id,
            question: surveys[1].question,
            date: '20 Dec 2018',
            didAnswer: surveys[1].didAnswer,
          ),
        ])));

    await sut.loadData();
  });

  test('Should emit correct events on failure', () async {
    mockLoadSurveysError();

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));

    sut.surveysStream.listen(null,
        onError: expectAsync1((error) => expect(
              error,
              UIError.unexpected.description,
            )));

    await sut.loadData();
  });

  test('Should emit correct events on access denied', () async {
    mockAccessDeniedError();

    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    expectLater(sut.isSessionExpiredStream, emits(true));

    await sut.loadData();
  });

  test('Should go to SurveyResultPage on link click', () async {
    expectLater(
        sut.navigateToStream,
        emitsInOrder([
          '/survey_result/1',
          '/survey_result/1',
        ]));

    sut.goToSurveyResult('1');
    sut.goToSurveyResult('1');
  });

  test('Should not emit after dispose', () async {
    mockLoadSurveysError();

    expectLater(sut.surveysStream, neverEmits(null));

    sut.dispose();

    await sut.loadData();
  });
}
