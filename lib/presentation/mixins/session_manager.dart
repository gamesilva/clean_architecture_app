import 'dart:async';

mixin SessionManager {
  final _isSessionExpired = StreamController<bool>.broadcast();

  Stream<bool> get isSessionExpiredStream =>
      _isSessionExpired.stream.distinct();

  set isSessionExpired(bool isSessionExpired) =>
      _isSessionExpired.add(isSessionExpired);
}
