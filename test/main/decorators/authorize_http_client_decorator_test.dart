import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/cache/cache.dart';
import 'package:clean_architecture_app/data/http/http.dart';
import 'package:clean_architecture_app/main/decorators/decorators.dart';

class FetchSecureCacheStorageSpy extends Mock
    implements FetchSecureCacheStorage {}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late FetchSecureCacheStorage fetchSecureCacheStorage;
  late AuthorizeHttpClientDecorator sut;
  late HttpClient httpClient;

  late String url;
  late String method;
  late Map body;
  late String token;
  late String httpResponse;

  When mockTokenCall() =>
      when(() => fetchSecureCacheStorage.fetchSecure(any()));

  void mockToken() {
    token = faker.guid.guid();
    mockTokenCall().thenAnswer((_) async => token);
  }

  void mockTokenError() {
    token = faker.guid.guid();
    mockTokenCall().thenThrow((_) async => Exception());
  }

  When mockHttpCall() => when(() => httpClient.request(
        url: any(named: 'url'),
        method: any(named: 'method'),
        body: any(named: 'body'),
        headers: any(named: 'headers'),
      ));

  void mockHttpResponse() {
    httpResponse = faker.randomGenerator.string(50);
    mockHttpCall().thenAnswer((_) async => httpResponse);
  }

  void mockHttpResponseError(HttpError error) {
    httpResponse = faker.randomGenerator.string(50);
    mockHttpCall().thenThrow(error);
  }

  setUp(() {
    fetchSecureCacheStorage = FetchSecureCacheStorageSpy();
    httpClient = HttpClientSpy();
    sut = AuthorizeHttpClientDecorator(
      fetchSecureCacheStorage: fetchSecureCacheStorage,
      decoratee: httpClient,
    );

    url = faker.internet.httpUrl();
    method = faker.randomGenerator.string(10);
    body = {'any_key': 'any_value'};

    mockToken();
    mockHttpResponse();
  });

  test('Should call FetchSecureCacheStorage with correct key', () async {
    await sut.request(url: url, method: method, body: body);

    verify(() => fetchSecureCacheStorage.fetchSecure('token')).called(1);
  });

  test('Should call decoratee with access token on header', () async {
    await sut.request(url: url, method: method, body: body);
    verify(() => httpClient.request(
          url: url,
          method: method,
          body: body,
          headers: {'x-access-key': token},
        )).called(1);

    await sut.request(
        url: url,
        method: method,
        body: body,
        headers: {'any_header': 'any_value'});
    verify(() => httpClient.request(
          url: url,
          method: method,
          body: body,
          headers: {'x-access-key': token, 'any_header': 'any_value'},
        )).called(1);
  });

  test('Should return same result as decoratee', () async {
    final response = await sut.request(url: url, method: method, body: body);

    expect(response, httpResponse);
  });

  test('Should throw ForbiddenError if FetchSecureCacheStorage throws',
      () async {
    mockTokenError();
    final future = sut.request(url: url, method: method, body: body);

    expect(future, throwsA(HttpError.forbidden));
  });

  test('Should rethrow decoratee throws', () async {
    mockHttpResponseError(HttpError.badRequest);
    final future = sut.request(url: url, method: method, body: body);

    expect(future, throwsA(HttpError.badRequest));
  });
}
