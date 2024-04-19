import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/http/http_client.dart';

class HttpAdapter implements HttpClient {
  final Client client;

  HttpAdapter(this.client);

  @override
  Future<Map> request({
    required String? url,
    required String? method,
    Map? body,
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };

    final jsonBody = body != null ? jsonEncode(body) : null;

    final response = await client.post(
      Uri.parse(url!),
      headers: headers,
      body: jsonBody,
    );

    return jsonDecode(response.body);
  }
}

class ClientSpy extends Mock implements Client {}

void main() {
  late HttpAdapter sut;
  late ClientSpy client;
  late String url;
  late Uri uri;
  late Map<String, String> headers;

  setUpAll(() {
    url = faker.internet.httpUrl();
    registerFallbackValue(Uri.parse(url));
  });

  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client);
    url = faker.internet.httpUrl();
    uri = Uri.parse(url);
    headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
  });
  group('post', () {
    test('Should call POST with correct value', () async {
      when(() => client.post(
            uri,
            headers: headers,
            body: '{"any_key":"any_value"}',
          )).thenAnswer((_) async => Response('{}', 200));

      await sut.request(
        url: url,
        method: 'POST',
        body: {"any_key": "any_value"},
      );

      verify(() =>
          client.post(uri, headers: headers, body: '{"any_key":"any_value"}'));
    });

    test('Should call POST without body', () async {
      when(() => client.post(
            any<Uri>(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => Response('{}', 200));

      await sut.request(url: url, method: 'POST');

      verify(() => client.post(
            any<Uri>(),
            headers: any(named: 'headers'),
          ));
    });

    test('Should return data if post returns 200', () async {
      when(() => client.post(
            any<Uri>(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => Response('{"any_key":"any_value"}', 200));

      final response = await sut.request(url: url, method: 'POST');

      expect(response, {"any_key": "any_value"});
    });
  });
}
