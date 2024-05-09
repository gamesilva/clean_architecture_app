import '../../../data/usecases/usecases.dart';
import '../../../domain/usecases/usecases.dart';
import '../factories.dart';

SaveCurrentAccount makeLocalSaveCurrentAccont() {
  return LocalSaveCurrentAccount(
    saveSecureChacheStorage: makeLocalStorageAdapter(),
  );
}
