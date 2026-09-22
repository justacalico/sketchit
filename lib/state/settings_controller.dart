import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide preferences: theme mode and locale. Persisted locally.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs);

  static Future<SettingsController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final c = SettingsController(prefs);
    c._themeMode = ThemeMode.values.byName(
        prefs.getString(_kTheme) ?? ThemeMode.system.name);
    final code = prefs.getString(_kLocale);
    if (code != null) c._locale = Locale(code);
    return c;
  }

  static const _kTheme = 'settings.theme';
  static const _kLocale = 'settings.locale';
  static const _kScene = 'scene.autosave';

  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setString(_kTheme, mode.name);
    notifyListeners();
  }

  void setLocale(Locale? locale) {
    _locale = locale;
    if (locale == null) {
      _prefs.remove(_kLocale);
    } else {
      _prefs.setString(_kLocale, locale.languageCode);
    }
    notifyListeners();
  }

  String? loadAutosave() => _prefs.getString(_kScene);

  void autosave(String sceneJson) {
    _prefs.setString(_kScene, sceneJson);
  }

  void clearAutosave() {
    _prefs.remove(_kScene);
  }
}
