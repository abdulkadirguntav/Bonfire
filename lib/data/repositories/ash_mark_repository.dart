import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/domain/models/ash_mark.dart';

class AshMarkRepository {
  AshMarkRepository(this._prefs);

  static const _storageKey = 'bonfire_ash_mark';

  final SharedPreferences _prefs;

  Future<AshMark?> loadAshMark() async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return AshMark.fromJson(decoded);
    } catch (_) {
      await clearAshMark();
      return null;
    }
  }

  Future<void> saveAshMark(AshMark ashMark) async {
    await _prefs.setString(_storageKey, jsonEncode(ashMark.toJson()));
  }

  Future<void> clearAshMark() async {
    await _prefs.remove(_storageKey);
  }
}
