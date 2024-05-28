import 'dart:async';

import '../../domain/usecases/usecases.dart';
import '../../ui/pages/pages.dart';

class StreamSplashPresenter implements SplashPresenter {
  final LoadCurrentAccount loadCurrentAccount;
  final _navigateTo = StreamController<String?>();

  @override
  Stream<String?> get navigateToStream => _navigateTo.stream;

  StreamSplashPresenter({required this.loadCurrentAccount});

  @override
  Future<void>? checkAccount({int durationInSeconds = 2}) async {
    await Future.delayed(Duration(seconds: durationInSeconds));
    try {
      final account = await loadCurrentAccount.load();
      _navigateTo.add(account?.token == null ? '/login' : '/surveys');
    } catch (e) {
      _navigateTo.add('/login');
    }
  }
}
