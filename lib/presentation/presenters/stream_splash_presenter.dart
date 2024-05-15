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
  Future<void>? checkAccount() async {
    try {
      final account = await loadCurrentAccount.load();
      _navigateTo.add(account != null ? '/surveys' : '/login');
    } catch (e) {
      _navigateTo.add('/login');
    }
  }
}
