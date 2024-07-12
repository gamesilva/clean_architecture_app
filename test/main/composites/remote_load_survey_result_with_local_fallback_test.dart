import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/usecases/usecases.dart';
import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

class RemoteLoadSurveyResultWithLocalFallback implements LoadSurveyResult {
  final RemoteLoadSurveyResult remote;
  final LocalLoadSurveyResult local;

  RemoteLoadSurveyResultWithLocalFallback({
    required this.remote,
    required this.local,
  });

  @override
  Future<SurveyResultEntity>? loadBySurvey({String? surveyId}) async {
    final surveyResult = await remote.loadBySurvey(surveyId: surveyId);
    await local.save(surveyId: surveyId!, surveyResult: surveyResult);
    return surveyResult!;
  }
}

class RemoteLoadSurveyResultSpy extends Mock implements RemoteLoadSurveyResult {
}

class LocalLoadSurveyResultSpy extends Mock implements LocalLoadSurveyResult {}

void main() {
  late String surveyId;
  late RemoteLoadSurveyResult remote;
  late LocalLoadSurveyResult local;
  late RemoteLoadSurveyResultWithLocalFallback sut;
  late SurveyResultEntity surveyResult;

  void mockSurveyResult() {
    surveyResult = SurveyResultEntity(
      surveyId: surveyId,
      question: faker.lorem.sentence(),
      answers: [
        SurveyAnswerEntity(
          answer: faker.lorem.sentence(),
          isCurrentAnswer: faker.randomGenerator.boolean(),
          percent: faker.randomGenerator.integer(100),
        ),
      ],
    );

    when(() => remote.loadBySurvey(surveyId: any(named: 'surveyId')))
        .thenAnswer((_) async => surveyResult);
  }

  setUp(() {
    surveyId = faker.guid.guid();
    remote = RemoteLoadSurveyResultSpy();
    local = LocalLoadSurveyResultSpy();
    sut = RemoteLoadSurveyResultWithLocalFallback(
      remote: remote,
      local: local,
    );
    mockSurveyResult();
  });

  test('Should call remote LoadBySurvey', () async {
    await sut.loadBySurvey(surveyId: surveyId);

    verify(() => remote.loadBySurvey(surveyId: surveyId));
  });

  test('Should call local save with remote data', () async {
    await sut.loadBySurvey(surveyId: surveyId);

    verify(() => local.save(surveyId: surveyId, surveyResult: surveyResult));
  });

  test('Should return remote data', () async {
    final response = await sut.loadBySurvey(surveyId: surveyId);

    expect(response, surveyResult);
  });
}
