import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/domain/models/reflection.dart';

class ReflectionRepository {
  ReflectionRepository(this._prefs);

  static const _storageKey = 'bonfire_reflections';
  static const _questionsKey = 'bonfire_reflection_custom_questions';

  final SharedPreferences _prefs;

  Future<List<Reflection>> loadReflections() async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return const [];

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Reflection.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveReflections(List<Reflection> reflections) async {
    final raw = jsonEncode(reflections.map((r) => r.toJson()).toList());
    await _prefs.setString(_storageKey, raw);
  }

  Future<List<String>> loadCustomQuestions() async {
    final raw = _prefs.getStringList(_questionsKey);
    return raw ?? const [];
  }

  Future<void> saveCustomQuestions(List<String> questions) async {
    await _prefs.setStringList(_questionsKey, questions);
  }
}
