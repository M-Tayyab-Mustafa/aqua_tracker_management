import 'package:hive_flutter/hive_flutter.dart';
import '../../model/user.dart';
import 'user_adapter.dart';

class LocalDatabase {
  static const String _boxKey = 'box';
  static const String _userKey = 'user';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
  }

  static Future<Box> get openBox async {
    return await Hive.openBox(_boxKey);
  }

  static Future<void> putUser(User user) async {
    await Hive.box(_boxKey).put(_userKey, user);
  }

  static Future<User> getUser() async {
    return await Hive.box(_boxKey).get(_userKey);
  }

  static Future<void> updateUser(User newUser) async {
    await Hive.box(_boxKey).put(_userKey, newUser);
  }

  static Future<void> removeUser() async {
    await Hive.deleteFromDisk();
  }
}
