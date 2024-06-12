import '../../decorators/decorators.dart';
import '../../factories/factories.dart';
import '../../../data/http/http.dart';

HttpClient makeAuthorizeHttpClientDecorator() => AuthorizeHttpClientDecorator(
    decoratee: makeHttpAdapter(),
    fetchSecureCacheStorage: makeLocalStorageAdapter());
