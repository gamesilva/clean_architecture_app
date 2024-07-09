import 'dart:async';

mixin NavigationManager {
  final _navigateToStream = StreamController<String>.broadcast();
  Stream<String> get navigateToStream => _navigateToStream.stream.distinct();
  set navigateTo(String route) => _navigateToStream.add(route);
}
