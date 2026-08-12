import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/domain/models/user.dart';

class UserRepository {
  UserRepository(this._prefs);

  static const _storageKey = 'bonfire_user';

  final SharedPreferences _prefs;

  Future<User?> loadUser() async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return User.fromJson(decoded);
    } catch (_) {
      await clearUser();
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    await _prefs.setString(_storageKey, jsonEncode(user.toJson()));
  }

  Future<void> clearUser() async {
    await _prefs.remove(_storageKey);
  }
}
