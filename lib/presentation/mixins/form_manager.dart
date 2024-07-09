import 'dart:async';

mixin FormManager {
  final _isFormValidStream = StreamController<bool>.broadcast();
  Stream<bool> get isFormValidStream => _isFormValidStream.stream.distinct();
  set isFormValid(bool isFormValid) => _isFormValidStream.add(isFormValid);
}
