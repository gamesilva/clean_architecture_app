import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helpers/helpers.dart';
import '../login_presenter.dart';

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final presenter = Provider.of<LoginPresenter>(context);
    return StreamBuilder<dynamic>(
      stream: presenter.isFormValidStream,
      builder: (context, snapshot) {
        return ElevatedButton(
          onPressed:
              (snapshot.data != null && snapshot.data) ? presenter.auth : null,
          child: Text(R.strings.enter.toUpperCase()),
        );
      },
    );
  }
}
