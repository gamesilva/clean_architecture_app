import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../helpers/helpers.dart';
import '../../mixins/mixins.dart';

import 'components/components.dart';
import 'signup_presenter.dart';

class SignUpPage extends StatefulWidget {
  final SignUpPresenter presenter;
  SignUpPage(this.presenter);

  @override
  State<SignUpPage> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage>
    with KeyboardManager, LoadingManager, UIErrorManager, NavigationManager {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: ((context) {
          handleLoading(context, widget.presenter.isLoadingStream);
          handleMainError(context, widget.presenter.mainErrorStream);
          handleNavigation(widget.presenter.navigateToStream, clear: true);

          return GestureDetector(
            onTap: () => hideKeyboard(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const LoginHeader(),
                  Headline1(text: R.strings.addAccount),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Provider(
                      create: (_) => widget.presenter,
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            NameInput(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: EmailInput(),
                            ),
                            PasswordInput(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 32),
                              child: PasswordConfirmationInput(),
                            ),
                            SignUpButton(),
                            TextButton.icon(
                              onPressed: widget.presenter.goToLogin,
                              icon: const Icon(Icons.exit_to_app),
                              label: Text(R.strings.login),
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
