import 'dart:async';

mixin FormManager {
  final _isFormValidStream = StreamController<bool>.broadcast();
  Stream<bool> get isFormValidStream => _isFormValidStream.stream.distinct();
  set isFormValid(bool isFormValid) {
    if (!_isFormValidStream.isClosed) {
      _isFormValidStream.add(isFormValid);
    }
  }

  void closeFormManagerStream() => _isFormValidStream.close();
}
