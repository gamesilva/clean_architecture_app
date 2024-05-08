import 'package:flutter/material.dart';

import '../../../../ui/pages/pages.dart';
import '../../../factories/factories.dart';

Widget makeLoginPage() {
  return LoginPage(presenter: makeStreamLoginPresenter());
}
