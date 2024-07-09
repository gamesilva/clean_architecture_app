import 'dart:async';

mixin LoadingManager {
  final _isLoadingStream = StreamController<bool>.broadcast();
  Stream<bool> get isLoadingStream => _isLoadingStream.stream.distinct();
  set isLoading(bool isLoading) => _isLoadingStream.add(isLoading);
}
