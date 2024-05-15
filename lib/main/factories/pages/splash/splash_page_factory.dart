import 'package:flutter/material.dart';

import '../../../../ui/pages/pages.dart';
import '../../../factories/factories.dart';

Widget makeSplashPage() {
  return SplashPage(presenter: makeStreamSplashPresenter());
}
