// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import 'components/components.dart';
import 'login_presenter.dart';

class LoginPage extends StatefulWidget {
  final LoginPresenter? presenter;
  const LoginPage({Key? key, this.presenter}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

          widget.presenter?.mainErrorStream.listen((error) {
            if (error != null) {
              showErrorMessage(context, error);
            }
          });

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const LoginHeader(),
                const Headline1(text: 'Login'),
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
                            child: StreamBuilder<dynamic>(
                                stream: widget.presenter?.passwordErrorStream,
                                builder: (context, snapshot) {
                                  return TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Senha',
                                      errorText: (snapshot.data != null &&
                                              snapshot.data != '')
                                          ? snapshot.data
                                          : null,
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      icon: Icon(
                                        Icons.lock,
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                    onChanged:
                                        widget.presenter?.validatePassword,
                                    obscureText: true,
                                  );
                                }),
                          ),
                          StreamBuilder<dynamic>(
                            stream: widget.presenter?.isFormValidStream,
                            builder: (context, snapshot) {
                              return RaisedButton(
                                onPressed:
                                    (snapshot.data != null && snapshot.data)
                                        ? widget.presenter?.auth
                                        : null,
                                child: Text('Entrar'.toUpperCase()),
                              );
                            },
                          ),
                          FlatButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.person),
                            label: const Text('Criar conta'),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
