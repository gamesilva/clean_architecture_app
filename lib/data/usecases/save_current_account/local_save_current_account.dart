import '../../../domain/entities/entities.dart';
import '../../../domain/helpers/helpers.dart';
import '../../../domain/usecases/usecases.dart';
import '../../cache/cache.dart';

class LocalSaveCurrentAccount implements SaveCurrentAccount {
  final SaveSecureChacheStorage saveSecureChacheStorage;

  LocalSaveCurrentAccount({required this.saveSecureChacheStorage});

  @override
  Future<void>? save(AccountEntity account) async {
    try {
      await saveSecureChacheStorage.save(
        key: 'token',
        value: account.token!,
      );
    } catch (error) {
      throw DomainError.unexpected;
    }
  }
}
