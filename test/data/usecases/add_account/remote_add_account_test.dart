import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/helpers/helpers.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

import 'package:clean_architecture_app/data/usecases/usecases.dart';
import 'package:clean_architecture_app/data/http/http.dart';

import '../../../mocks/mocks.dart';

class HttpClientSpy extends Mock implements HttpClient {}

// The structure of the test is Triple A (Arrange, Act, Assert);
void main() {
  late RemoteAddAccount sut;
  late HttpClientSpy httpClient;
  late String url;
  late AddAccountParams params;
  late Map apiResult;

  When mockRequest() => when(
        () => httpClient.request(
          url: any(named: 'url'),
          method: any(named: 'method'),
          body: any(named: 'body'),
        ),
      );

  void mockHttpData(Map data) {
    apiResult = data;
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAddAccount(httpClient: httpClient, url: url);
    params = FakeParamsFactory.makeAddAccount();
    mockHttpData(FakeAccountFactory.makeApiJson());
  });

  test('Should call HttpClient with correct values', () async {
    await sut.add(params);
    verify(() => httpClient.request(
          url: url,
          method: 'POST',
          body: {
            'name': params.name,
            'email': params.email,
            'password': params.password,
            'passwordConfirmation': params.passwordConfirmation,
          },
        ));
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    mockHttpError(HttpError.badRequest);

    final future = sut.add(params);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    mockHttpError(HttpError.notFound);

    final future = sut.add(params);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 500', () async {
    mockHttpError(HttpError.serverError);

    final future = sut.add(params);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if HttpClient return 401',
      () async {
    mockHttpError(HttpError.forbidden);

    final future = sut.add(params);
    expect(future, throwsA(DomainError.emailInUse));
  });

  test('Should return an Account if HttpClient return 200', () async {
    mockHttpData(apiResult);

    final account = await sut.add(params);
    expect(account.token, apiResult['accessToken']);
  });

  test(
      'Should return UnexpectedError if HttpClient return 200 with invalid data',
      () async {
    mockHttpData({'invalidKey': 'invalidValue'});

    final future = sut.add(params);
    expect(future, throwsA(DomainError.unexpected));
  });
}
