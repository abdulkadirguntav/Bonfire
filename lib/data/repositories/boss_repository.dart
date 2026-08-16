import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/domain/models/boss.dart';

class BossRepository {
  BossRepository(this._prefs);

  static const _storageKey = 'bonfire_boss';

  final SharedPreferences _prefs;

  Future<Boss?> loadBoss() async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return Boss.fromJson(decoded);
    } catch (_) {
      await clearBoss();
      return null;
    }
  }

  Future<void> saveBoss(Boss boss) async {
    await _prefs.setString(_storageKey, jsonEncode(boss.toJson()));
  }

  Future<void> clearBoss() async {
    await _prefs.remove(_storageKey);
  }
}
