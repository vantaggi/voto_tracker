import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestisce la lingua scelta dall'utente. `null` = segui il sistema.
/// La scelta è persistita su `shared_preferences`.
class LocaleProvider extends ChangeNotifier {
  static const String _key = 'locale';

  Locale? _locale;
  Locale? get locale => _locale;

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
