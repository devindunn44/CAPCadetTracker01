import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  SettingsService(this._prefs);

  static const String _jrotcKey = 'settings.jrotcMode';
  final SharedPreferences _prefs;

  /// Convenience for startup code outside Riverpod.
  static Future<SettingsService> create() async =>
      SettingsService(await SharedPreferences.getInstance());

  AppSettings load() =>
      AppSettings(jrotcMode: _prefs.getBool(_jrotcKey) ?? false);

  Future<void> save(AppSettings settings) =>
      _prefs.setBool(_jrotcKey, settings.jrotcMode);
}
