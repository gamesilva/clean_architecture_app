import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test/test.dart';

class HttpAdapter {
  final Client client;

  HttpAdapter(this.client);

  Future<void>? request({
    required String? url,
    required String? method,
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    await client.post(Uri.parse(url!), headers: headers);
  }
}

class ClientSpy extends Mock implements Client {}

void main() {
  group('post', () {
    test('Should call POST with correct value', () async {
      final client = ClientSpy();
      final sut = HttpAdapter(client);
      final url = faker.internet.httpUrl();
      final uri = Uri.parse(url);
      final headers = {
        'content-type': 'application/json',
        'accept': 'application/json',
      };

      when(() => client.post(uri, headers: headers))
          .thenAnswer((_) async => Response('{}', 200));

      await sut.request(url: url, method: 'POST');

      verify(() => client.post(
            uri,
            headers: headers,
          ));
    });
  });
}
