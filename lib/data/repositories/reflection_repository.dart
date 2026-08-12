import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/domain/models/reflection.dart';

class ReflectionRepository {
  ReflectionRepository(this._prefs);

  static const _storageKey = 'bonfire_reflections';

  final SharedPreferences _prefs;

  Future<List<Reflection>> loadReflections() async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Reflection.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      await clearReflections();
      return const [];
    }
  }

  Future<void> saveReflections(List<Reflection> reflections) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(reflections.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> clearReflections() async {
    await _prefs.remove(_storageKey);
  }
}
