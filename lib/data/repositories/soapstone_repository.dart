import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/domain/models/soapstone.dart';

class SoapstoneRepository {
  SoapstoneRepository(this._prefs);

  static const _storageKey = 'bonfire_soapstones';

  final SharedPreferences _prefs;

  Future<List<Soapstone>> loadSoapstones() async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return const [];

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Soapstone.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSoapstones(List<Soapstone> soapstones) async {
    final raw = jsonEncode(soapstones.map((s) => s.toJson()).toList());
    await _prefs.setString(_storageKey, raw);
  }

  Future<void> clearSoapstones() async {
    await _prefs.remove(_storageKey);
  }
}
