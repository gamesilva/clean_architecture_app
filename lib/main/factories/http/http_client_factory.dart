import 'package:http/http.dart';

import '../../../data/http/http.dart';
import '../../../infra/http/http.dart';

HttpClient<ReturnType> makeHttpAdapter<ReturnType>() {
  final client = Client();
  return HttpAdapter<ReturnType>(client);
}
