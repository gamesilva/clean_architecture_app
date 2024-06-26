import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/cache/cache.dart';
import 'package:clean_architecture_app/data/usecases/usecases.dart';

import 'package:clean_architecture_app/domain/entities/survey_entity.dart';
import 'package:clean_architecture_app/domain/helpers/helpers.dart';

class CacheStorageSpy extends Mock implements CacheStorage {}

void main() {
  group('load', () {
    late CacheStorage cacheStorage;
    late LocalLoadSurveys sut;
    List<Map>? data;

    List<Map> mockValidData() => [
          {
            'id': faker.guid.guid(),
            'question': faker.randomGenerator.string(10),
            'date': '2020-07-20T00:00:00Z',
            'didAnswer': 'false',
          },
          {
            'id': faker.guid.guid(),
            'question': faker.randomGenerator.string(10),
            'date': '2019-02-02T00:00:00Z',
            'didAnswer': 'true',
          },
        ];

    When mockFetchCall() => when(() => cacheStorage.fetch('surveys'));

    void mockFetch(List<Map>? list) {
      data = list;
      mockFetchCall().thenAnswer((_) async => data);
    }

    void mockFetchError() => mockFetchCall().thenThrow(Exception());

    setUp(() {
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveys(
        cacheStorage: cacheStorage,
      );

      mockFetch(mockValidData());
    });

    test('Should call FetchCacheStorage with correct key', () async {
      await sut.load();

      verify(() => cacheStorage.fetch('surveys')).called(1);
    });

    test('Should return a list of surveys on success', () async {
      final surveys = await sut.load();

      expect(surveys, [
        SurveyEntity(
          id: data?[0]['id'],
          question: data?[0]['question'],
          dateTime: DateTime.utc(2020, 7, 20),
          didAnswer: false,
        ),
        SurveyEntity(
          id: data?[1]['id'],
          question: data?[1]['question'],
          dateTime: DateTime.utc(2019, 2, 2),
          didAnswer: true,
        ),
      ]);
    });

    test('Should throws UnexpectedError if cache is empty', () async {
      mockFetch([]);
      final future = sut.load();

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws UnexpectedError if cache is null', () async {
      mockFetch(null);
      final future = sut.load();

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws UnexpectedError if cache is invalid', () async {
      mockFetch([
        {
          'id': faker.guid.guid(),
          'question': faker.randomGenerator.string(10),
          'date': 'invalid date',
          'didAnswer': 'false',
        },
      ]);
      final future = sut.load();

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws UnexpectedError if cache is incomplete', () async {
      mockFetch([
        {
          'date': '2020-07-20T00:00:00Z',
          'didAnswer': 'false',
        },
      ]);
      final future = sut.load();

      expect(future, throwsA(DomainError.unexpected));
    });

    test('Should throws UnexpectedError if cache is incomplete', () async {
      mockFetchError();

      final future = sut.load();

      expect(future, throwsA(DomainError.unexpected));
    });
  });

  group('validate', () {
    late CacheStorage cacheStorage;
    late LocalLoadSurveys sut;
    List<Map>? data;

    List<Map> mockValidData() => [
          {
            'id': faker.guid.guid(),
            'question': faker.randomGenerator.string(10),
            'date': '2020-07-20T00:00:00Z',
            'didAnswer': 'false',
          },
          {
            'id': faker.guid.guid(),
            'question': faker.randomGenerator.string(10),
            'date': '2019-02-02T00:00:00Z',
            'didAnswer': 'true',
          },
        ];

    When mockFetchCall() => when(() => cacheStorage.fetch('surveys'));

    void mockFetch(List<Map>? list) {
      data = list;
      mockFetchCall().thenAnswer((_) async => data);
    }

    void mockFetchError() => mockFetchCall().thenThrow(Exception());

    setUp(() {
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveys(
        cacheStorage: cacheStorage,
      );

      mockFetch(mockValidData());
    });

    test('Should call CacheStorage with correct key', () async {
      await sut.validate();

      verify(() => cacheStorage.fetch('surveys')).called(1);
    });

    test('Should delete cache if it is invalid', () async {
      mockFetch([
        {
          'id': faker.guid.guid(),
          'question': faker.randomGenerator.string(10),
          'date': 'invalid date',
          'didAnswer': 'false',
        }
      ]);
      await sut.validate();

      verify(() => cacheStorage.delete('surveys')).called(1);
    });

    test('Should delete cache if it is incomplete', () async {
      mockFetch([
        {
          'date': '2020-07-20T00:00:00Z',
          'didAnswer': 'false',
        }
      ]);
      await sut.validate();

      verify(() => cacheStorage.delete('surveys')).called(1);
    });

    test('Should delete cache if it throws', () async {
      mockFetchError();
      await sut.validate();

      verify(() => cacheStorage.delete('surveys')).called(1);
    });
  });

  group('save', () {
    late CacheStorage cacheStorage;
    late LocalLoadSurveys sut;
    late List<SurveyEntity>? surveys;

    List<SurveyEntity> mockSurveys() => [
          SurveyEntity(
            id: faker.guid.guid(),
            question: faker.randomGenerator.string(10),
            dateTime: DateTime.utc(2020, 2, 2),
            didAnswer: true,
          ),
          SurveyEntity(
            id: faker.guid.guid(),
            question: faker.randomGenerator.string(10),
            dateTime: DateTime.utc(2018, 12, 20),
            didAnswer: false,
          ),
        ];

    When mockSaveCall() => when(() =>
        cacheStorage.save(key: any(named: 'key'), value: any(named: 'value')));

    void mockSaveError() => mockSaveCall().thenThrow(Exception());

    setUp(() {
      cacheStorage = CacheStorageSpy();
      sut = LocalLoadSurveys(
        cacheStorage: cacheStorage,
      );

      surveys = mockSurveys();
    });

    test('Should call CacheStorage with correct values', () async {
      final list = [
        {
          'id': surveys?[0].id,
          'question': surveys?[0].question,
          'date': '2020-02-02T00:00:00.000Z',
          'didAnswer': 'true',
        },
        {
          'id': surveys?[1].id,
          'question': surveys?[1].question,
          'date': '2018-12-20T00:00:00.000Z',
          'didAnswer': 'false',
        },
      ];

      await sut.save(surveys);

      verify(() => cacheStorage.save(key: 'surveys', value: list)).called(1);
    });

    test('Should throws UnexpectedError if save throws', () async {
      mockSaveError();

      final future = sut.save(surveys);

      expect(future, throwsA(DomainError.unexpected));
    });
  });
}
