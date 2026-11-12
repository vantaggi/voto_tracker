import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/models/candidate_list.dart';
import 'package:voto_tracker/models/settings.dart';

/// Liste di candidati e impostazioni predefinite per i nuovi scrutini
/// (FEAT-008, P10), su `shared_preferences` accanto all'archivio.
/// Un valore illeggibile si ignora (si riparte senza liste), non blocca l'app.
class TemplatesRepository {
  TemplatesRepository(this._prefs);

  static const String kLists = 'candidate_lists';
  static const String kDefaultSettings = 'default_settings';

  final SharedPreferences _prefs;

  static Future<TemplatesRepository> open() async =>
      TemplatesRepository(await SharedPreferences.getInstance());

  List<CandidateList> loadLists() {
    final raw = _prefs.getString(kLists);
    if (raw == null) return [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          CandidateList.fromJson(Map<String, dynamic>.from(e)),
      ];
    } catch (e) {
      debugPrint('Liste di candidati illeggibili: $e');
      return [];
    }
  }

  Future<void> saveLists(List<CandidateList> lists) =>
      _prefs.setString(kLists, jsonEncode([for (final l in lists) l.toJson()]));

  Settings? loadDefaultSettings() {
    final raw = _prefs.getString(kDefaultSettings);
    if (raw == null) return null;
    try {
      return Settings.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
    } catch (e) {
      debugPrint('Impostazioni predefinite illeggibili: $e');
      return null;
    }
  }

  Future<void> saveDefaultSettings(Settings? settings) => settings == null
      ? _prefs.remove(kDefaultSettings)
      : _prefs.setString(kDefaultSettings, jsonEncode(settings.toJson()));
}
