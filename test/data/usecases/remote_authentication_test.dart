import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/helpers/helpers.dart';
import 'package:clean_architecture_app/domain/usecases/usecases.dart';

import 'package:clean_architecture_app/data/usecases/usecases.dart';
import 'package:clean_architecture_app/data/http/http.dart';

class HttpClientSpy extends Mock implements HttpClient {}

// The structure of the test is Triple A (Arrange, Act, Assert);
void main() {
  late RemoteAuthentication sut;
  late HttpClientSpy httpClient;
  late String url;
  late AuthenticationParams params;
  PostExpectation mockRequest() => when(
        httpClient.request(
          url: anyNamed('url'),
          method: anyNamed('method'),
          body: anyNamed('body'),
        ),
      );

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );
  });

  test('Should call HttpClient with correct values', () async {
    mockHttpData(
        {'accessToken': faker.guid.guid(), 'name': faker.person.name()});
    await sut.auth(params);
    verify(httpClient.request(
      url: url,
      method: 'POST',
      body: RemoteAuthenticationParams.fromDomain(params).toJson(),
    ));
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    mockHttpError(HttpError.badRequest);

    final future = sut.auth(params);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    mockHttpError(HttpError.notFound);

    final future = sut.auth(params);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 500', () async {
    mockHttpError(HttpError.serverError);

    final future = sut.auth(params);
    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if HttpClient return 401',
      () async {
    mockHttpError(HttpError.unauthorized);

    final future = sut.auth(params);
    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('Should return an Account if HttpClient return 200', () async {
    final accessToken = faker.guid.guid();
    mockHttpData({'accessToken': accessToken, 'name': faker.person.name()});

    final account = await sut.auth(params);
    expect(account.token, accessToken);
  });

  test(
      'Should return UnexpectedError if HttpClient return 200 with invalid data',
      () async {
    mockHttpData({'invalidKey': 'invalidValue'});

    final future = sut.auth(params);
    expect(future, throwsA(DomainError.unexpected));
  });
}
