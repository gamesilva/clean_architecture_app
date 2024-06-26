import 'package:equatable/equatable.dart';

import '../entities/entities.dart';

abstract class AddAccount {
  Future<AccountEntity> add(AddAccountParams params);
}

class AddAccountParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  AddAccountParams({
    required this.name,
    required this.passwordConfirmation,
    required this.email,
    required this.password,
  });

  @override
  List get props => [name, email, password, passwordConfirmation];
}
