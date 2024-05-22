import 'package:flutter/material.dart';
import '../../../helpers/helpers.dart';

class PasswordConfirmationInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: R.strings.confirmPassword,
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
        icon: Icon(
          Icons.lock,
          color: Theme.of(context).primaryColorLight,
        ),
      ),
      obscureText: true,
    );
  }
}
