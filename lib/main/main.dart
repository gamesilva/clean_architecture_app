import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';

import '../../ui/components/components.dart';
import 'factories/factories.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return GetMaterialApp(
      title: '4Dev',
      debugShowCheckedModeBanner: false,
      theme: makeAppTheme(),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: makeSplashPage,
          transition: Transition.fade,
        ),
        GetPage(
          name: '/login',
          page: makeLoginPage,
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/signup',
          page: makeSignUpPage,
        ),
        GetPage(
          name: '/surveys',
          page: () => const Scaffold(
              body: Center(
            child: Text('Enquetes'),
          )),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
