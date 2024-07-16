import 'dart:async';

mixin NavigationManager {
  final _navigateToStream = StreamController<String>.broadcast();
  Stream<String> get navigateToStream => _navigateToStream.stream;
  set navigateTo(String route) {
    if (!_navigateToStream.isClosed) {
      _navigateToStream.add(route);
    }
  }

  void closeNavigationManagerStream() => _navigateToStream.close();
}
