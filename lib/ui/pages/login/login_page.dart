// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../helpers/helpers.dart';

import 'components/components.dart';
import 'login_presenter.dart';

class LoginPage extends StatefulWidget {
  final LoginPresenter? presenter;
  const LoginPage({Key? key, this.presenter}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _hideKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.presenter?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: ((context) {
          widget.presenter?.isLoadingStream.listen((isLoading) {
            isLoading ? showLoading(context) : hideLoading(context);
          });

          widget.presenter?.mainErrorStream.listen((UIError? error) {
            if (error != null) {
              showErrorMessage(context, error.description);
            }
          });

          widget.presenter?.navigateToStream.listen((page) {
            if (page?.isNotEmpty == true) {
              Get.offAllNamed(page!);
            }
          });

          return GestureDetector(
            onTap: _hideKeyboard,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const LoginHeader(),
                  Headline1(text: R.strings.login),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Provider(
                      create: (_) => widget.presenter,
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            EmailInput(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 32),
                              child: PasswordInput(),
                            ),
                            LoginButton(),
                            FlatButton.icon(
                              onPressed: widget.presenter?.goToSignUp,
                              icon: const Icon(Icons.person),
                              label: Text(R.strings.addAccount),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
