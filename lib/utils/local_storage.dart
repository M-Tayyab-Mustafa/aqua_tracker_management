import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';

class LocalStorage {
  LocalStorage._privateConstructor();

  static final LocalStorage _instance = LocalStorage._privateConstructor();

  factory LocalStorage() {
    return _instance;
  }

  static String userKey = 'user_key';

  Future<bool> saveUser(User user) async {
    var localStorage = await SharedPreferences.getInstance();
    return localStorage.setString(userKey, user.toJson());
  }

  Future<User> get user async {
    var localStorage = await SharedPreferences.getInstance();
    var userCredential = localStorage.getString(userKey)!;
    return User.fromJson(userCredential);
  }

  Future<User?> get hasUser async {
    var localStorage = await SharedPreferences.getInstance();
    var userCredential = localStorage.getString(userKey);
    if (userCredential == null) return null;
    return User.fromJson(userCredential);
  }

  Future<bool> removeUser() async {
    var localStorage = await SharedPreferences.getInstance();
    return localStorage.remove(userKey);
  }

  Future<bool> updateName({required String name}) async {
    var localStorage = await SharedPreferences.getInstance();
    var userCredential = localStorage.getString(userKey)!;
    User user = User.fromJson(userCredential).copyWith(name: name);
    return localStorage.setString(userKey, user.toJson());
  }

  Future<bool> updateContact({required String contact}) async {
    var localStorage = await SharedPreferences.getInstance();
    var userCredential = localStorage.getString(userKey)!;
    User user = User.fromJson(userCredential).copyWith(contact: contact);
    return localStorage.setString(userKey, user.toJson());
  }
}
