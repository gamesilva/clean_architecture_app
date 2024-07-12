import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/cache/cache.dart';
import 'package:clean_architecture_app/data/usecases/usecases.dart';
import 'package:clean_architecture_app/domain/helpers/helpers.dart';

class CacheStorageSpy extends Mock implements CacheStorage {}

void main() {
  group('loadBySurvey', () {
    late CacheStorage cacheStorage;
    late LocalLoadSurveyResult sut;
    late Map? data;
    late String surveyId;

    Map mockValidData() => {
          'surveyId': faker.guid.guid(),
          'question': faker.lorem.sentence(),
          'answers': [
            {
              'image': faker.internet.httpUrl(),
              'answer': faker.lorem.sentence(),
              'isCurrentAnswer': 'true',
              'percent': '40',
            },
            {
              'answer': faker.lorem.sentence(),
              'isCurrentAnswer': 'false',
              'percent': '60',
            },
          ]
        };

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

      mockFetch(mockValidData());
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
      mockFetch({
        'surveyId': faker.guid.guid(),
        'question': faker.lorem.sentence(),
        'answers': [
          {
            'image': faker.internet.httpUrl(),
            'answer': faker.lorem.sentence(),
            'isCurrentAnswer': 'invalid bool',
            'percent': 'invalid int',
          }
        ]
      });
      final future = sut.loadBySurvey(surveyId: surveyId);

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws UnexpectedError if cache is incomplete', () async {
      mockFetch({'surveyId': faker.guid.guid()});
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

    Map mockValidData() => {
          'surveyId': faker.guid.guid(),
          'question': faker.lorem.sentence(),
          'answers': [
            {
              'image': faker.internet.httpUrl(),
              'answer': faker.lorem.sentence(),
              'isCurrentAnswer': 'true',
              'percent': '40',
            },
            {
              'answer': faker.lorem.sentence(),
              'isCurrentAnswer': 'false',
              'percent': '60',
            },
          ]
        };

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

      mockFetch(mockValidData());
    });

    test('Should call CacheStorage with correct key', () async {
      await sut.validate(surveyId);

      verify(() => cacheStorage.fetch('survey_result/$surveyId')).called(1);
    });

    test('Should delete cache if it is invalid', () async {
      mockFetch({
        'surveyId': faker.guid.guid(),
        'question': faker.lorem.sentence(),
        'answers': [
          {
            'image': faker.internet.httpUrl(),
            'answer': faker.lorem.sentence(),
            'isCurrentAnswer': 'invalid bool',
            'percent': 'invalid int',
          }
        ]
      });
      await sut.validate(surveyId);

      verify(() => cacheStorage.delete('survey_result/$surveyId')).called(1);
    });

    test('Should delete cache if it is incomplete', () async {
      mockFetch({'surveyId': faker.guid.guid()});
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
    late String surveyId;

    SurveyResultEntity mockSurveyResult() => SurveyResultEntity(
          surveyId: faker.guid.guid(),
          question: faker.lorem.sentence(),
          answers: [
            SurveyAnswerEntity(
              image: faker.internet.httpUrl(),
              answer: faker.lorem.sentence(),
              isCurrentAnswer: true,
              percent: 40,
            ),
            SurveyAnswerEntity(
              answer: faker.lorem.sentence(),
              isCurrentAnswer: false,
              percent: 60,
            ),
          ],
        );

    When mockSaveCall() => when(() =>
        cacheStorage.save(key: any(named: 'key'), value: any(named: 'value')));

    void mockSaveError() => mockSaveCall().thenThrow(Exception());

    setUp(() {
      surveyId = faker.guid.guid();
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveyResult(
        cacheStorage: cacheStorage,
      );

      surveyResult = mockSurveyResult();
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

      await sut.save(surveyId: surveyId, surveyResult: surveyResult);

      verify(() => cacheStorage.save(
            key: 'survey_result/$surveyId',
            value: json,
          )).called(1);
    });

    test('Should throws UnexpectedError if save throws', () async {
      mockSaveError();

      final future = sut.save(surveyId: surveyId, surveyResult: surveyResult);

      expect(future, throwsA(DomainError.unexpected));
    });
  });
}
