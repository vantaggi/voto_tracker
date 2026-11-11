import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferenze di aspetto. `useSystemColors`: usa il colore dinamico del
/// sistema (Material You su Android 12+) quando disponibile, altrimenti il
/// seed indigo del brand. Persistito su `shared_preferences`.
class AppearanceProvider extends ChangeNotifier {
  static const String _key = 'use_system_colors';

  bool _useSystemColors = true;
  bool get useSystemColors => _useSystemColors;

  AppearanceProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_key);
    if (stored != null && stored != _useSystemColors) {
      _useSystemColors = stored;
      notifyListeners();
    }
  }

  Future<void> setUseSystemColors(bool value) async {
    if (_useSystemColors == value) return;
    _useSystemColors = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
