import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/cache/cache.dart';
import 'package:clean_architecture_app/data/usecases/usecases.dart';

import 'package:clean_architecture_app/domain/entities/survey_entity.dart';
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
}
