import 'dart:async';

import '../../ui/helpers/helpers.dart';

mixin UIErrorManager {
  final _mainErrorStream = StreamController<UIError?>.broadcast();
  Stream<UIError?> get mainErrorStream => _mainErrorStream.stream.distinct();
  set mainError(UIError? error) => _mainErrorStream.add(error);
}
