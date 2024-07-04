// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../helpers/helpers.dart';

class ReloadScreen extends StatelessWidget {
  final String error;
  final Future<void>? Function()? reload;

  const ReloadScreen({required this.error, required this.reload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          RaisedButton(
            child: Text(R.strings.reload),
            onPressed: reload,
          )
        ],
      ),
    );
  }
}
