import '../../../data/usecases/usecases.dart';
import '../../../domain/usecases/usecases.dart';
import '../factories.dart';

LoadCurrentAccount makeLocalLoadCurrentAccount() {
  return LocalLoadingCurrentAccount(
    fetchSecureCacheStorage: makeSecureStorageAdapter(),
  );
}
