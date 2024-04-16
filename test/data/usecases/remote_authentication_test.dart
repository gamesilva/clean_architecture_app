import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/usecases/usecases.dart';

import 'package:clean_architecture_app/data/usecases/usecases.dart';
import 'package:clean_architecture_app/data/http/http.dart';

class HttpClientSpy extends Mock implements HttpClient {}

// The structure of the test is Triple A (Arrange, Act, Assert);
void main() {
  late RemoteAuthentication sut;
  late HttpClientSpy httpClient;
  late String url;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
  });

  test('Should call HttpClient with correct values', () async {
    final params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );

    await sut.auth(params);
    verify(httpClient.request(
      url: url,
      method: 'POST',
      body: RemoteAuthenticationParams.fromDomain(params).toJson(),
    ));
  });
}
