import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clean_architecture_app/ui/helpers/errors/errors.dart';
import 'package:clean_architecture_app/ui/pages/pages.dart';

import '../helpers/helpers.dart';

class SignUpPresenterSpy extends Mock implements SignUpPresenter {}

void main() {
  late SignUpPresenter presenter;
  late StreamController<UIError?> nameErrorController;
  late StreamController<UIError?> emailErrorController;
  late StreamController<UIError?> passwordErrorController;
  late StreamController<UIError?> passwordConfirmationErrorController;
  late StreamController<UIError?> mainErrorController;
  late StreamController<String?> navigateToController;
  late StreamController<bool> isFormValidController;
  late StreamController<bool> isLoadingController;

  void initStreams() {
    nameErrorController = StreamController<UIError?>();
    emailErrorController = StreamController<UIError?>();
    passwordErrorController = StreamController<UIError?>();
    passwordConfirmationErrorController = StreamController<UIError?>();
    mainErrorController = StreamController<UIError?>();
    navigateToController = StreamController<String?>();
    isFormValidController = StreamController<bool>();
    isLoadingController = StreamController<bool>();
  }

  void mockStreams() {
    when(() => presenter.nameErrorStream)
        .thenAnswer((_) => nameErrorController.stream);

    when(() => presenter.emailErrorStream)
        .thenAnswer((_) => emailErrorController.stream);

    when(() => presenter.passwordErrorStream)
        .thenAnswer((_) => passwordErrorController.stream);

    when(() => presenter.passwordConfirmationErrorStream)
        .thenAnswer((_) => passwordConfirmationErrorController.stream);

    when(() => presenter.isFormValidStream)
        .thenAnswer((_) => isFormValidController.stream);

    when(() => presenter.isLoadingStream)
        .thenAnswer((_) => isLoadingController.stream);

    when(() => presenter.mainErrorStream)
        .thenAnswer((_) => mainErrorController.stream);

    when(() => presenter.navigateToStream)
        .thenAnswer((_) => navigateToController.stream);
  }

  void closeStreams() {
    nameErrorController.close();
    emailErrorController.close();
    passwordErrorController.close();
    passwordConfirmationErrorController.close();
    isFormValidController.close();
    isLoadingController.close();
    mainErrorController.close();
    navigateToController.close();
  }

  Future<void> loadPage(WidgetTester tester) async {
    presenter = SignUpPresenterSpy();

    initStreams();
    mockStreams();

    await tester.pumpWidget(
      makePage(path: '/signup', page: () => SignUpPage(presenter)),
    );
  }

  tearDown((() => closeStreams()));
  testWidgets('Should load with correct initial state',
      (WidgetTester tester) async {
    await loadPage(tester);

    final nameTextChildren = find.descendant(
      of: find.bySemanticsLabel('Nome'),
      matching: find.byType(Text),
    );
    expect(
      nameTextChildren,
      findsOneWidget,
      reason:
          'When a TextFormField has only text child, means it has no errors, since one of the childs is always the label text',
    );

    final emailTextChildren = find.descendant(
      of: find.bySemanticsLabel('Email'),
      matching: find.byType(Text),
    );
    expect(
      emailTextChildren,
      findsOneWidget,
      reason:
          'When a TextFormField has only text child, means it has no errors, since one of the childs is always the label text',
    );

    final passwordTextChildren = find.descendant(
      of: find.bySemanticsLabel('Senha'),
      matching: find.byType(Text),
    );
    expect(
      passwordTextChildren,
      findsOneWidget,
      reason:
          'When a TextFormField has only text child, means it has no errors, since one of the childs is always the label text',
    );

    final passwordConfirmationTextChildren = find.descendant(
      of: find.bySemanticsLabel('Confirmar senha'),
      matching: find.byType(Text),
    );
    expect(
      passwordConfirmationTextChildren,
      findsOneWidget,
      reason:
          'When a TextFormField has only text child, means it has no errors, since one of the childs is always the label text',
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(
      button.onPressed,
      null,
      reason:
          'To test a button, you need to get it as a Widget and you should use tester intead of find.',
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Should call validate with corret values',
      (WidgetTester tester) async {
    await loadPage(tester);

    final name = faker.person.name();
    await tester.enterText(find.bySemanticsLabel('Nome'), name);
    verify(() => presenter.validateName(name));

    final email = faker.internet.email();
    await tester.enterText(find.bySemanticsLabel('Email'), email);
    verify(() => presenter.validateEmail(email));

    final password = faker.internet.password();
    await tester.enterText(find.bySemanticsLabel('Senha'), password);
    verify(() => presenter.validatePassword(password));

    await tester.enterText(find.bySemanticsLabel('Confirmar senha'), password);
    verify(() => presenter.validatePasswordConfirmation(password));
  });

  testWidgets('Should present email error', (WidgetTester tester) async {
    await loadPage(tester);

    emailErrorController.add(UIError.invalidField);
    await tester.pump();
    expect(find.text('Campo inválido'), findsOneWidget);

    emailErrorController.add(UIError.requiredField);
    await tester.pump();
    expect(find.text('Campo obrigatório'), findsOneWidget);

    emailErrorController.add(null);
    await tester.pump();
    expect(
      find.descendant(
        of: find.bySemanticsLabel('Email'),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Should present name error', (WidgetTester tester) async {
    await loadPage(tester);

    nameErrorController.add(UIError.invalidField);
    await tester.pump();
    expect(find.text('Campo inválido'), findsOneWidget);

    nameErrorController.add(UIError.requiredField);
    await tester.pump();
    expect(find.text('Campo obrigatório'), findsOneWidget);

    nameErrorController.add(null);
    await tester.pump();
    expect(
      find.descendant(
        of: find.bySemanticsLabel('Nome'),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Should present password error', (WidgetTester tester) async {
    await loadPage(tester);

    passwordErrorController.add(UIError.invalidField);
    await tester.pump();
    expect(find.text('Campo inválido'), findsOneWidget);

    passwordErrorController.add(UIError.requiredField);
    await tester.pump();
    expect(find.text('Campo obrigatório'), findsOneWidget);

    passwordErrorController.add(null);
    await tester.pump();
    expect(
      find.descendant(
        of: find.bySemanticsLabel('Senha'),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Should present passwordConfirmation error',
      (WidgetTester tester) async {
    await loadPage(tester);

    passwordConfirmationErrorController.add(UIError.invalidField);
    await tester.pump();
    expect(find.text('Campo inválido'), findsOneWidget);

    passwordConfirmationErrorController.add(UIError.requiredField);
    await tester.pump();
    expect(find.text('Campo obrigatório'), findsOneWidget);

    passwordConfirmationErrorController.add(null);
    await tester.pump();
    expect(
      find.descendant(
        of: find.bySemanticsLabel('Confirmar senha'),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Should enable form button if form is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    isFormValidController.add(true);
    await tester.pump(); // Atualizando a tela para receber novos valores.

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Should disable form button if form is invalid',
      (WidgetTester tester) async {
    await loadPage(tester);

    isFormValidController.add(false);
    await tester.pump(); // Atualizando a tela para receber novos valores.

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, null);
  });

  testWidgets('Should call signUp on form submit', (WidgetTester tester) async {
    await loadPage(tester);

    isFormValidController.add(true);
    await tester.pump();

    final button = find.byType(ElevatedButton);

    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    verify(() => presenter.signUp()).called(1);
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
  });

  testWidgets('Should presents error message if signUp fails',
      (WidgetTester tester) async {
    await loadPage(tester);

    mainErrorController.add(UIError.emailInUse);
    await tester.pump();

    expect(find.text('O email já está em uso'), findsOneWidget);
  });

  testWidgets('Should presents error message if signUp throws',
      (WidgetTester tester) async {
    await loadPage(tester);

    mainErrorController.add(UIError.unexpected);
    await tester.pump();

    expect(find.text('Algo errado aconteceu. Tente novamente'), findsOneWidget);
  });

  testWidgets('Should change page', (WidgetTester tester) async {
    await loadPage(tester);

    navigateToController.add('/any_route');
    await tester.pumpAndSettle();

    expect(currentRoute, '/any_route');
    expect(find.text('Fake page'), findsOneWidget);
  });

  testWidgets('Should not change page', (WidgetTester tester) async {
    await loadPage(tester);

    navigateToController.add('');
    await tester.pump();
    expect(currentRoute, '/signup');

    navigateToController.add(null);
    await tester.pump();
    expect(currentRoute, '/signup');
  });

  testWidgets('Should call goToLogin on link click',
      (WidgetTester tester) async {
    await loadPage(tester);

    final button = find.text('Login');

    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    verify(() => presenter.goToLogin()).called(1);
  });
}
