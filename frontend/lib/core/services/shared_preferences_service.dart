import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:university_qa_system/features/authentication/domain/entities/user.dart';

class SharedPreferencesService {
  final SharedPreferences _preferences;

  SharedPreferencesService(this._preferences);

  static const _userKey = 'USER_INFO';

  Future<void> saveUserInfo(User userInfo) async {
    final userInfoString = jsonEncode(userInfo);
    await _preferences.setString(_userKey, userInfoString);
  }

  User? getUserInfo() {
    final userInfoString = _preferences.getString(_userKey);
    if (userInfoString != null) {
      final userInfoJson = jsonDecode(userInfoString) as Map<String, dynamic>;
      return User.fromJson(userInfoJson);
    }
    return null;
  }
}
