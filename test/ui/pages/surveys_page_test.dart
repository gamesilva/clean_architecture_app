import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:clean_architecture_app/ui/helpers/helpers.dart';
import 'package:clean_architecture_app/ui/pages/pages.dart';
import 'package:mocktail/mocktail.dart';

class SurveysPresenterSpy extends Mock implements SurveysPresenter {}

void main() {
  late SurveysPresenter presenter;
  late StreamController<bool?> isLoadingController;
  late StreamController<List<SurveyViewModel>> loadSurveysController;

  void initStreams() {
    isLoadingController = StreamController<bool?>();
    loadSurveysController = StreamController<List<SurveyViewModel>>();
  }

  void mockStreams() {
    when(() => presenter.isLoadingStream)
        .thenAnswer((_) => isLoadingController.stream);

    when(() => presenter.surveysStream)
        .thenAnswer((_) => loadSurveysController.stream);
  }

  void closeStreams() {
    isLoadingController.close();
    loadSurveysController.close();
  }

  Future<void> loadPage(WidgetTester tester) async {
    presenter = SurveysPresenterSpy();

    initStreams();
    mockStreams();

    final surveysPage = GetMaterialApp(
      initialRoute: '/surveys',
      getPages: [
        GetPage(
          name: '/surveys',
          page: () => SurveysPage(
            presenter: presenter,
          ),
        ),
      ],
    );
    await tester.pumpWidget(surveysPage);
  }

  List<SurveyViewModel> makeSurveys() => [
        SurveyViewModel(
          id: '1',
          question: 'Question 1',
          date: 'Date 1',
          didAnswer: true,
        ),
        SurveyViewModel(
          id: '2',
          question: 'Question 2',
          date: 'Date 2',
          didAnswer: false,
        ),
      ];

  tearDown((() => closeStreams()));

  testWidgets('Should call LoadSurveys on page load',
      (WidgetTester tester) async {
    await loadPage(tester);
    verify(() => presenter.loadData()).called(1);
  });

  testWidgets('Should handle loading correctly', (WidgetTester tester) async {
    await loadPage(tester);

    isLoadingController.add(true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    isLoadingController.add(false);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    isLoadingController.add(true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    isLoadingController.add(null);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Should present error if loadSurveysStream fails',
      (WidgetTester tester) async {
    await loadPage(tester);

    loadSurveysController.addError(UIError.unexpected.description);
    await tester.pump();

    expect(find.text('Algo errado aconteceu. Tente novamente'), findsOneWidget);
    expect(find.text('Recarregar'), findsOneWidget);
    expect(find.text('Question 1'), findsNothing);
  });

  testWidgets('Should present list if loadSurveysStream succeeds',
      (WidgetTester tester) async {
    await loadPage(tester);

    loadSurveysController.add(makeSurveys());
    await tester.pump();

    expect(find.text('Algo errado aconteceu. Tente novamente'), findsNothing);
    expect(find.text('Recarregar'), findsNothing);

    expect(find.text('Question 1'), findsWidgets);
    expect(find.text('Question 2'), findsWidgets);

    expect(find.text('Date 1'), findsWidgets);
    expect(find.text('Date 2'), findsWidgets);
  });

  testWidgets('Should call LoadSurveys on reload button click',
      (WidgetTester tester) async {
    await loadPage(tester);

    loadSurveysController.addError(UIError.unexpected.description);
    await tester.pump();

    await tester.tap(find.text('Recarregar'));

    // Aqui o called é 2 pq a primeira chamada é realizada assim que a tela abre
    verify(() => presenter.loadData()).called(2);
  });
}
