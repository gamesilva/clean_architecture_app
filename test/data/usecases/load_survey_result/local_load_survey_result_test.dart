import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/cache/cache.dart';
import 'package:clean_architecture_app/data/usecases/usecases.dart';
import 'package:clean_architecture_app/domain/helpers/helpers.dart';

import '../../../mocks/mocks.dart';

class CacheStorageSpy extends Mock implements CacheStorage {}

void main() {
  group('loadBySurvey', () {
    late CacheStorage cacheStorage;
    late LocalLoadSurveyResult sut;
    late Map? data;
    late String surveyId;

    When mockFetchCall() =>
        when(() => cacheStorage.fetch('survey_result/$surveyId'));

    void mockFetch(Map? json) {
      data = json;
      mockFetchCall().thenAnswer((_) async => data);
    }

    void mockFetchError() => mockFetchCall().thenThrow(Exception());

    setUp(() {
      surveyId = faker.guid.guid();
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveyResult(
        cacheStorage: cacheStorage,
      );

      mockFetch(FakeSurveyResultFactory.makeCacheJson());
    });

    test('Should call FetchCacheStorage with correct key', () async {
      await sut.loadBySurvey(surveyId: surveyId);

      verify(() => cacheStorage.fetch('survey_result/$surveyId')).called(1);
    });

    test('Should return a surveyResult on success', () async {
      final surveyResult = await sut.loadBySurvey(surveyId: surveyId);

      expect(
          surveyResult,
          SurveyResultEntity(
            surveyId: data!['surveyId'],
            question: data!['question'],
            answers: [
              SurveyAnswerEntity(
                image: data!['answers'][0]['image'],
                answer: data!['answers'][0]['answer'],
                isCurrentAnswer: true,
                percent: 40,
              ),
              SurveyAnswerEntity(
                answer: data!['answers'][1]['answer'],
                isCurrentAnswer: false,
                percent: 60,
              ),
            ],
          ));
    });

    test('Should throws UnexpectedError if cache is empty', () async {
      mockFetch({});
      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws UnexpectedError if cache is null', () async {
      mockFetch(null);
      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws UnexpectedError if cache is invalid', () async {
      mockFetch(FakeSurveyResultFactory.makeInvalidCacheJson());
      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws UnexpectedError if cache is incomplete', () async {
      mockFetch(FakeSurveyResultFactory.makeIncompleteCacheJson());
      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws UnexpectedError if cache throws', () async {
      mockFetchError();

      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });
  });

  group('validate', () {
    late CacheStorage cacheStorage;
    late LocalLoadSurveyResult sut;
    late Map? data;
    late String surveyId;

    When mockFetchCall() =>
        when(() => cacheStorage.fetch('survey_result/$surveyId'));

    void mockFetch(Map? json) {
      data = json;
      mockFetchCall().thenAnswer((_) async => data);
    }

    void mockFetchError() => mockFetchCall().thenThrow(Exception());

    setUp(() {
      surveyId = faker.guid.guid();
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveyResult(
        cacheStorage: cacheStorage,
      );

      mockFetch(FakeSurveyResultFactory.makeCacheJson());
    });

    test('Should call CacheStorage with correct key', () async {
      await sut.validate(surveyId);

      verify(() => cacheStorage.fetch('survey_result/$surveyId')).called(1);
    });

    test('Should delete cache if it is invalid', () async {
      mockFetch(FakeSurveyResultFactory.makeInvalidCacheJson());
      await sut.validate(surveyId);

      verify(() => cacheStorage.delete('survey_result/$surveyId')).called(1);
    });

    test('Should delete cache if it is incomplete', () async {
      mockFetch(FakeSurveyResultFactory.makeIncompleteCacheJson());
      await sut.validate(surveyId);

      verify(() => cacheStorage.delete('survey_result/$surveyId')).called(1);
    });

    test('Should delete cache if it throws', () async {
      mockFetchError();
      await sut.validate(surveyId);

      verify(() => cacheStorage.delete('survey_result/$surveyId')).called(1);
    });
  });

  group('save', () {
    late CacheStorage cacheStorage;
    late LocalLoadSurveyResult sut;
    late SurveyResultEntity? surveyResult;

    When mockSaveCall() => when(() =>
        cacheStorage.save(key: any(named: 'key'), value: any(named: 'value')));

    void mockSaveError() => mockSaveCall().thenThrow(Exception());

    setUp(() {
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveyResult(
        cacheStorage: cacheStorage,
      );

      surveyResult = FakeSurveyResultFactory.makeEntity();
    });

    test('Should call CacheStorage with correct values', () async {
      final json = {
        'surveyId': surveyResult?.surveyId,
        'question': surveyResult?.question,
        'answers': [
          {
            'image': surveyResult?.answers![0].image,
            'answer': surveyResult?.answers![0].answer,
            'isCurrentAnswer': 'true',
            'percent': '40',
          },
          {
            'image': null,
            'answer': surveyResult?.answers![1].answer,
            'isCurrentAnswer': 'false',
            'percent': '60',
          },
        ]
      };

      await sut.save(surveyResult);

      verify(() => cacheStorage.save(
            key: 'survey_result/${surveyResult?.surveyId}',
            value: json,
          )).called(1);
    });

    test('Should throws UnexpectedError if save throws', () async {
      mockSaveError();

      final future = sut.save(surveyResult);

      expect(future, throwsA(DomainError.unexpected));
    });
  });
}
