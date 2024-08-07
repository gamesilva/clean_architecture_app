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
  late Map<String, String> defaultHeaders;

  setUpAll(() {
    url = faker.internet.httpUrl();
    registerFallbackValue(Uri.parse(url));
  });

  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client);
    url = faker.internet.httpUrl();
    uri = Uri.parse(url);
    defaultHeaders = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
  });
  group('shared', () {
    test('Should throw ServerError if invalid method is provided', () async {
      final future = sut.request(url: url, method: 'invalid_method');

      expect(future, throwsA(HttpError.serverError));
    });
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

    void mockError() => mockRequest().thenThrow(Exception());

    setUp(() {
      mockResponse(200);
    });

    test('Should call POST with correct value', () async {
      await sut.request(
        url: url,
        method: 'POST',
        body: {"any_key": "any_value"},
      );

      verify(() => client.post(uri,
          headers: defaultHeaders, body: '{"any_key":"any_value"}'));

      await sut.request(
        url: url,
        method: 'POST',
        body: {"any_key": "any_value"},
        headers: {'any_header': 'any_value'},
      );

      verify(() => client.post(uri,
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
            'any_header': 'any_value',
          },
          body: '{"any_key":"any_value"}'));
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

    test('Should return NotFoundError if post returns 404', () async {
      mockResponse(404);
      final future = sut.request(url: url, method: 'POST');

      expect(future, throwsA(HttpError.notFound));
    });

    test('Should return ServerError if post returns 500', () async {
      mockResponse(500);
      final future = sut.request(url: url, method: 'POST');

      expect(future, throwsA(HttpError.serverError));
    });

    test('Should return ServerError if post throws', () async {
      mockError();
      final future = sut.request(url: url, method: 'POST');

      expect(future, throwsA(HttpError.serverError));
    });
  });

  group('get', () {
    When mockRequest() =>
        when(() => client.get(any<Uri>(), headers: any(named: 'headers')));

    void mockResponse(int statusCode,
        {String body = '{"any_key":"any_value"}'}) {
      return mockRequest().thenAnswer((_) async => Response(
            body,
            statusCode,
          ));
    }

    void mockError() => mockRequest().thenThrow(Exception());

    setUp(() {
      mockResponse(200);
    });

    test('Should call GET with correct value', () async {
      await sut.request(url: url, method: 'GET');
      verify(() => client.get(uri, headers: defaultHeaders));

      await sut.request(
        url: url,
        method: 'GET',
        headers: {'any_header': 'any_value'},
      );

      verify(() => client.get(
            uri,
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
              'any_header': 'any_value',
            },
          ));
    });

    test('Should return data if get returns 200', () async {
      final response = await sut.request(url: url, method: 'GET');

      expect(response, {"any_key": "any_value"});
    });

    test('Should return null if get returns 200 with no data', () async {
      mockResponse(200, body: '');

      final response = await sut.request(url: url, method: 'GET');

      expect(response, null);
    });

    test('Should return null if get returns 204', () async {
      mockResponse(204, body: '');
      final response = await sut.request(url: url, method: 'GET');

      expect(response, null);
    });

    test('Should return null if get returns 204 with data', () async {
      mockResponse(204);
      final response = await sut.request(url: url, method: 'GET');

      expect(response, null);
    });

    test('Should return BadRequest if get returns 400 with data', () async {
      mockResponse(400, body: '');
      final future = sut.request(url: url, method: 'GET');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return BadRequest if get returns 400', () async {
      mockResponse(400);
      final future = sut.request(url: url, method: 'GET');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return UnauthorizedError if get returns 401', () async {
      mockResponse(401);
      final future = sut.request(url: url, method: 'GET');

      expect(future, throwsA(HttpError.unauthorized));
    });

    test('Should return ForbiddenError if get returns 403', () async {
      mockResponse(403);
      final future = sut.request(url: url, method: 'GET');

      expect(future, throwsA(HttpError.forbidden));
    });

    test('Should return NotFoundError if get returns 404', () async {
      mockResponse(404);
      final future = sut.request(url: url, method: 'GET');

      expect(future, throwsA(HttpError.notFound));
    });

    test('Should return ServerError if get returns 500', () async {
      mockResponse(500);
      final future = sut.request(url: url, method: 'GET');

      expect(future, throwsA(HttpError.serverError));
    });

    test('Should return ServerError if get throws', () async {
      mockError();
      final future = sut.request(url: url, method: 'GET');

      expect(future, throwsA(HttpError.serverError));
    });
  });

  group('put', () {
    When mockRequest() => when(() => client.put(any<Uri>(),
        body: any(named: 'body'), headers: any(named: 'headers')));

    void mockResponse(int statusCode,
        {String body = '{"any_key":"any_value"}'}) {
      return mockRequest().thenAnswer((_) async => Response(
            body,
            statusCode,
          ));
    }

    void mockError() => mockRequest().thenThrow(Exception());

    setUp(() {
      mockResponse(200);
    });

    test('Should call PUT with correct value', () async {
      await sut.request(
        url: url,
        method: 'PUT',
        body: {"any_key": "any_value"},
      );

      verify(() => client.put(uri,
          headers: defaultHeaders, body: '{"any_key":"any_value"}'));

      await sut.request(
        url: url,
        method: 'PUT',
        body: {"any_key": "any_value"},
        headers: {'any_header': 'any_value'},
      );

      verify(() => client.put(uri,
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
            'any_header': 'any_value',
          },
          body: '{"any_key":"any_value"}'));
    });

    test('Should call PUT without body', () async {
      await sut.request(url: url, method: 'PUT');

      verify(() => client.put(
            any<Uri>(),
            headers: any(named: 'headers'),
          ));
    });

    test('Should return data if put returns 200', () async {
      final response = await sut.request(url: url, method: 'PUT');

      expect(response, {"any_key": "any_value"});
    });

    test('Should return null if put returns 200 with no data', () async {
      mockResponse(200, body: '');

      final response = await sut.request(url: url, method: 'PUT');

      expect(response, null);
    });

    test('Should return null if put returns 204', () async {
      mockResponse(204, body: '');
      final response = await sut.request(url: url, method: 'PUT');

      expect(response, null);
    });

    test('Should return null if put returns 204 with data', () async {
      mockResponse(204);
      final response = await sut.request(url: url, method: 'PUT');

      expect(response, null);
    });

    test('Should return BadRequest if put returns 400 with data', () async {
      mockResponse(400, body: '');
      final future = sut.request(url: url, method: 'PUT');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return BadRequest if put returns 400', () async {
      mockResponse(400);
      final future = sut.request(url: url, method: 'PUT');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('Should return UnauthorizedError if put returns 401', () async {
      mockResponse(401);
      final future = sut.request(url: url, method: 'PUT');

      expect(future, throwsA(HttpError.unauthorized));
    });

    test('Should return ForbiddenError if put returns 403', () async {
      mockResponse(403);
      final future = sut.request(url: url, method: 'PUT');

      expect(future, throwsA(HttpError.forbidden));
    });

    test('Should return NotFoundError if put returns 404', () async {
      mockResponse(404);
      final future = sut.request(url: url, method: 'PUT');

      expect(future, throwsA(HttpError.notFound));
    });

    test('Should return ServerError if put returns 500', () async {
      mockResponse(500);
      final future = sut.request(url: url, method: 'PUT');

      expect(future, throwsA(HttpError.serverError));
    });

    test('Should return ServerError if put throws', () async {
      mockError();
      final future = sut.request(url: url, method: 'PUT');

      expect(future, throwsA(HttpError.serverError));
    });
  });
}
