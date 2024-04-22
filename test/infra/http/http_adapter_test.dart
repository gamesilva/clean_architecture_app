import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/http/http.dart';
import 'package:clean_architecture_app/infra/http/http.dart';

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
    When mockRequest() => when(() => client.post(any<Uri>(),
        body: any(named: 'body'), headers: any(named: 'headers')));

    void mockResponse(int statusCode,
        {String body = '{"any_key":"any_value"}'}) {
      return mockRequest().thenAnswer((_) async => Response(
            body,
            statusCode,
          ));
    }

    setUp(() {
      mockResponse(200);
    });

    test('Should call POST with correct value', () async {
      await sut.request(
        url: url,
        method: 'POST',
        body: {"any_key": "any_value"},
      );

      verify(() =>
          client.post(uri, headers: headers, body: '{"any_key":"any_value"}'));
    });

    test('Should call POST without body', () async {
      await sut.request(url: url, method: 'POST');

      verify(() => client.post(
            any<Uri>(),
            headers: any(named: 'headers'),
          ));
    });

    test('Should return data if post returns 200', () async {
      final response = await sut.request(url: url, method: 'POST');

      expect(response, {"any_key": "any_value"});
    });

    test('Should return null if post returns 200 with no data', () async {
      mockResponse(200, body: '');

      final response = await sut.request(url: url, method: 'POST');

      expect(response, null);
    });

    test('Should return null if post returns 204', () async {
      mockResponse(204, body: '');
      final response = await sut.request(url: url, method: 'POST');

      expect(response, null);
    });

    test('Should return null if post returns 204 with data', () async {
      mockResponse(204);
      final response = await sut.request(url: url, method: 'POST');

      expect(response, null);
    });

    test('Should return BadRequest if post returns 400 with data', () async {
      mockResponse(400, body: '');
      final future = sut.request(url: url, method: 'POST');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return BadRequest if post returns 400', () async {
      mockResponse(400);
      final future = sut.request(url: url, method: 'POST');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return UnauthorizedError if post returns 401', () async {
      mockResponse(401);
      final future = sut.request(url: url, method: 'POST');

      expect(future, throwsA(HttpError.unauthorized));
    });

    test('Should return ForbiddenError if post returns 403', () async {
      mockResponse(403);
      final future = sut.request(url: url, method: 'POST');

      expect(future, throwsA(HttpError.forbidden));
    });

    test('Should return ServerError if post returns 500', () async {
      mockResponse(500);
      final future = sut.request(url: url, method: 'POST');

      expect(future, throwsA(HttpError.serverError));
    });
  });
}
