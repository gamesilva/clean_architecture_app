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
  late LoadSurveysSpy loadSurveys;
  late StreamSurveysPresenter sut;

  setUp(() {
    loadSurveys = LoadSurveysSpy();
    sut = StreamSurveysPresenter(loadSurveys: loadSurveys);
  });

  test('Should call LoadSurveys on loadData', () async {
    await sut.loadData();

    verify(() => loadSurveys.load()).called(1);
  });
}
