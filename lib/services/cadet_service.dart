import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cadet.dart';
import 'sample_data.dart';

class CadetService {
  CadetService(this._prefs);

  static const String _key = 'cadets.v1';
  final SharedPreferences _prefs;

  /// Loads saved cadets; seeds sample data on first launch.
  List<Cadet> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return buildSampleCadets(DateTime.now());
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Cadet.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return buildSampleCadets(DateTime.now());
    }
  }

  Future<void> save(List<Cadet> cadets) => _prefs.setString(
      _key, jsonEncode(cadets.map((c) => c.toJson()).toList()));
}
