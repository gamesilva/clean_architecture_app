import 'package:http/http.dart';

import '../../../data/http/http.dart';
import '../../../infra/http/http.dart';

HttpClient<T> makeHttpAdapter<T>() {
  final client = Client();
  return HttpAdapter<T>(client);
}
