import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/cache/cache.dart';
import 'package:clean_architecture_app/data/http/http.dart';

class AuthorizeHttpClientDecorator {
  final FetchSecureCacheStorage fetchSecureCacheStorage;
  final HttpClient decoratee;

  AuthorizeHttpClientDecorator({
    required this.decoratee,
    required this.fetchSecureCacheStorage,
  });

  Future<void> request({
    required String? url,
    required String? method,
    Map? body,
    Map? headers,
  }) async {
    final token = await fetchSecureCacheStorage.fetchSecure('token');
    final authorizedHeaders = {'x-access-key': token};
    await decoratee.request(
      url: url,
      method: method,
      body: body,
      headers: authorizedHeaders,
    );
  }
}

class FetchSecureCacheStorageSpy extends Mock
    implements FetchSecureCacheStorage {}

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late FetchSecureCacheStorage fetchSecureCacheStorage;
  late AuthorizeHttpClientDecorator sut;
  late HttpClient httpClient;

  late String url;
  late String method;
  late String token;
  late Map body;

  void mockToken() {
    token = faker.guid.guid();
    when(() => fetchSecureCacheStorage.fetchSecure(any()))
        .thenAnswer((_) async => token);
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
  });
}
