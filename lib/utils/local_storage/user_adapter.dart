import 'package:hive/hive.dart';

import '../../model/user.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 0;

  @override
  User read(BinaryReader reader) {
    return User.fromMap(reader.read());
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.write(obj.toMap());
  }
}
