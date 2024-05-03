import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../login_presenter.dart';

class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final presenter = Provider.of<LoginPresenter>(context);
    return StreamBuilder<dynamic>(
        stream: presenter.passwordErrorStream,
        builder: (context, snapshot) {
          return TextFormField(
            decoration: InputDecoration(
              labelText: 'Senha',
              errorText: (snapshot.data != null && snapshot.data != '')
                  ? snapshot.data
                  : null,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
              icon: Icon(
                Icons.lock,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            onChanged: presenter.validatePassword,
            obscureText: true,
          );
        });
  }
}
