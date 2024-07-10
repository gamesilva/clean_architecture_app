import 'dart:async';

mixin SessionManager {
  final _isSessionExpired = StreamController<bool>.broadcast();

  Stream<bool> get isSessionExpiredStream =>
      _isSessionExpired.stream.distinct();

  set isSessionExpired(bool isSessionExpired) {
    if (!_isSessionExpired.isClosed) {
      _isSessionExpired.add(isSessionExpired);
    }
  }

  void closeSessionManagerStream() => _isSessionExpired.close();
}
