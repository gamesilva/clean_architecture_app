import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/errors/errors.dart';
import '../login_presenter.dart';

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final presenter = Provider.of<LoginPresenter>(context);
    return StreamBuilder<UIError?>(
      stream: presenter.emailErrorStream,
      builder: (context, snapshot) {
        return TextFormField(
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: snapshot.hasData ? snapshot.data?.description : null,
            labelStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            icon: Icon(
              Icons.email,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          onChanged: presenter.validateEmail,
          keyboardType: TextInputType.emailAddress,
        );
      },
    );
  }
}
