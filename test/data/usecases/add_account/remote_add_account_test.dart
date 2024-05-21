import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/usecases/usecases.dart';

import 'package:clean_architecture_app/data/usecases/usecases.dart';
import 'package:clean_architecture_app/data/http/http.dart';

class HttpClientSpy extends Mock implements HttpClient {}

// The structure of the test is Triple A (Arrange, Act, Assert);
void main() {
  late RemoteAddAccount sut;
  late HttpClientSpy httpClient;
  late String url;
  late AddAccountParams params;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAddAccount(httpClient: httpClient, url: url);
    params = AddAccountParams(
      name: faker.person.name(),
      email: faker.internet.email(),
      password: faker.internet.password(),
      passwordConfirmation: faker.internet.password(),
    );
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
}
