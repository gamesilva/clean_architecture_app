import 'package:flutter/material.dart';

import '../../../../ui/pages/pages.dart';
import '../../../factories/factories.dart';

Widget makeSignUpPage() {
  return SignUpPage(makeStreamSignUpPresenter());
}
