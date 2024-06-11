import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:clean_architecture_app/domain/usecases/usecases.dart';

class StreamSurveysPresenter {
  final LoadSurveys loadSurveys;

  StreamSurveysPresenter({required this.loadSurveys});
  Future<void>? loadData() async {
    await loadSurveys.load();
  }
}

class LoadSurveysSpy extends Mock implements LoadSurveys {}

void main() {
  test('Should call LoadSurveys on loadData', () async {
    final loadSurveys = LoadSurveysSpy();
    final sut = StreamSurveysPresenter(loadSurveys: loadSurveys);

    await sut.loadData();

    verify(() => loadSurveys.load()).called(1);
  });
}
