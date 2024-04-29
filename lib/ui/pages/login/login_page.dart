// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../components/components.dart';
import 'login_presenter.dart';

class LoginPage extends StatelessWidget {
  final LoginPresenter? presenter;
  const LoginPage({Key? key, this.presenter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const LoginHeader(),
            const Headline1(text: 'Login'),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                child: Column(
                  children: <Widget>[
                    StreamBuilder<dynamic>(
                      stream: presenter?.emailErrorStream,
                      builder: (context, snapshot) {
                        return TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText:
                                (snapshot.data != null && snapshot.data != '')
                                    ? snapshot.data
                                    : null,
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            icon: Icon(
                              Icons.email,
                              color: Theme.of(context).primaryColorLight,
                            ),
                          ),
                          onChanged: presenter?.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 32),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          icon: Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                        onChanged: presenter?.validatePassword,
                        obscureText: true,
                      ),
                    ),
                    RaisedButton(
                      onPressed: null,
                      child: Text('Entrar'.toUpperCase()),
                    ),
                    FlatButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person),
                      label: const Text('Criar conta'),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
