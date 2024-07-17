import 'package:clean_architecture_app/domain/entities/entities.dart';
import 'package:faker/faker.dart';

class FakeAccountFactory {
  static Map makeApiJson() => {
        'accessToken': faker.guid.guid(),
        'name': faker.person.name(),
      };

  static AccountEntity makeEntity() => AccountEntity(faker.guid.guid());
}
