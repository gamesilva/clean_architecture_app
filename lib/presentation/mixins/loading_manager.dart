import 'dart:async';

mixin LoadingManager {
  final _isLoadingStream = StreamController<bool>.broadcast();
  Stream<bool> get isLoadingStream => _isLoadingStream.stream.distinct();
  set isLoading(bool isLoading) {
    if (!_isLoadingStream.isClosed) {
      _isLoadingStream.add(isLoading);
    }
  }

  void closeLoadingManagerStream() => _isLoadingStream.close();
}
