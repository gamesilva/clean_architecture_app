import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/data/usecases/usecases.dart';

import 'package:clean_architecture_app/data/http/http.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late RemoteSaveSurveyResult sut;
  late HttpClientSpy httpClient;
  late String url;
  late String answer;

  setUp(() {
    answer = faker.lorem.sentence();
    url = faker.internet.httpUrl();
    httpClient = HttpClientSpy();
    sut = RemoteSaveSurveyResult(url: url, httpClient: httpClient);
  });

  test('Should call HttpClient with correct values', () async {
    await sut.save(answer: answer);

    verify(() => httpClient.request(
          url: url,
          method: 'put',
          body: {'answer': answer},
        ));
  });
}
