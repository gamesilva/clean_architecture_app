import 'dart:async';

import '../../domain/usecases/usecases.dart';
import '../../ui/pages/pages.dart';
import '../mixins/mixins.dart';

class StreamSplashPresenter with NavigationManager implements SplashPresenter {
  final LoadCurrentAccount loadCurrentAccount;
  // final _navigateTo = StreamController<String?>();

  // @override
  // Stream<String?> get navigateToStream => _navigateTo.stream;

  StreamSplashPresenter({required this.loadCurrentAccount});

  @override
  Future<void>? checkAccount({int durationInSeconds = 2}) async {
    await Future.delayed(Duration(seconds: durationInSeconds));
    try {
      await loadCurrentAccount.load();
      navigateTo = '/surveys';
    } catch (e) {
      navigateTo = '/login';
    }
  }
}
