import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonfire/domain/models/soapstone.dart';

class SoapstoneRepository {
  SoapstoneRepository(this._prefs);

  static const _storageKey = 'bonfire_soapstone';

  final SharedPreferences _prefs;

  Future<List<Soapstone>> loadSoapstones() async {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Soapstone.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      await clearSoapstones();
      return const [];
    }
  }

  Future<void> saveSoapstones(List<Soapstone> soapstones) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(soapstones.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> clearSoapstones() async {
    await _prefs.remove(_storageKey);
  }
}
