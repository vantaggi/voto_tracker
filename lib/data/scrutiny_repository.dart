import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/scrutiny.dart';
import 'package:voto_tracker/models/settings.dart';

/// Archivio degli scrutini in memoria: l'elenco e quale è aperto.
class ScrutinyArchive {
  ScrutinyArchive({required this.items, required this.currentId});

  final List<Scrutiny> items;
  String currentId;

  Scrutiny get current => items.firstWhere((s) => s.id == currentId);
}

/// Persistenza degli scrutini su `shared_preferences` (ADR-001 in
/// docs/PROJECT_GUIDE.md), con versione dello schema.
///
/// - **v1** (fino alla 1.3): uno scrutinio solo, chiavi `settings`,
///   `candidates`, `vote_log`.
/// - **v2**: archivio in `scrutinies` (JSON) + `current_scrutiny_id`.
///
/// La migrazione v1 → v2 crea il primo scrutinio dell'archivio dai dati v1 e
/// **non cancella** le chiavi v1, che restano come copia di sicurezza.
class ScrutinyRepository {
  ScrutinyRepository(this._prefs, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static Future<ScrutinyRepository> open() async =>
      ScrutinyRepository(await SharedPreferences.getInstance());

  static const int schemaVersion = 2;
  static const String kSchemaVersion = 'schema_version';
  static const String kScrutinies = 'scrutinies';
  static const String kCurrentId = 'current_scrutiny_id';
  static const String kCorruptBackup = 'scrutinies_corrupt_backup';
  static const String kV1Settings = 'settings';
  static const String kV1Candidates = 'candidates';
  static const String kV1VoteLog = 'vote_log';

  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  int _idCounter = 0;

  DateTime now() => _clock();

  /// Id unico e ordinabile per data di creazione.
  String newId() =>
      '${now().microsecondsSinceEpoch.toRadixString(36)}-${(_idCounter++).toRadixString(36)}';

  /// Carica l'archivio, migrando i dati v1 se serve. Non restituisce mai un
  /// archivio vuoto: se non c'è nulla crea uno scrutinio con [createDefault].
  Future<ScrutinyArchive> load({
    required List<Candidate> Function(Settings) createDefault,
  }) async {
    final version = _prefs.getInt(kSchemaVersion) ?? 1;
    ScrutinyArchive? archive;
    if (version >= 2) archive = _readV2();
    archive ??= _migrateFromV1(createDefault);
    await save(archive);
    return archive;
  }

  Future<void> save(ScrutinyArchive archive) async {
    await _prefs.setString(
      kScrutinies,
      jsonEncode(archive.items.map((s) => s.toJson()).toList()),
    );
    await _prefs.setString(kCurrentId, archive.currentId);
    await _prefs.setInt(kSchemaVersion, schemaVersion);
  }

  ScrutinyArchive? _readV2() {
    final raw = _prefs.getString(kScrutinies);
    if (raw == null) return null;
    try {
      final items = (jsonDecode(raw) as List)
          .map((e) => Scrutiny.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (items.isEmpty) return null;
      final stored = _prefs.getString(kCurrentId);
      final currentId = items.any((s) => s.id == stored)
          ? stored!
          : items.last.id;
      return ScrutinyArchive(items: items, currentId: currentId);
    } catch (e) {
      // Dati illeggibili: li mettiamo da parte invece di sovrascriverli.
      debugPrint('Archivio scrutini illeggibile: $e');
      _prefs.setString(kCorruptBackup, raw);
      return null;
    }
  }

  ScrutinyArchive _migrateFromV1(
    List<Candidate> Function(Settings) createDefault,
  ) {
    var settings = Settings();
    final settingsJson = _prefs.getString(kV1Settings);
    if (settingsJson != null) {
      try {
        settings = Settings.fromJson(jsonDecode(settingsJson));
      } catch (e) {
        debugPrint('Impostazioni v1 illeggibili: $e');
      }
    }

    List<Candidate>? candidates;
    final candidatesJson = _prefs.getString(kV1Candidates);
    if (candidatesJson != null) {
      try {
        candidates = (jsonDecode(candidatesJson) as List)
            .map((e) => Candidate.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        debugPrint('Candidati v1 illeggibili: $e');
      }
    }
    candidates ??= createDefault(settings);

    final rawLog = _prefs.getStringList(kV1VoteLog);
    final List<int> log;
    if (rawLog != null) {
      log = [for (final e in rawLog) ?int.tryParse(e)];
    } else {
      // Dati senza registro (prima della 1.2): i voti salvati nei candidati
      // diventano un registro equivalente, così i totali non si perdono.
      log = [
        for (var i = 0; i < candidates.length; i++)
          for (var k = 0; k < candidates[i].votes; k++) i,
      ];
    }

    final t = now();
    final scrutiny = Scrutiny(
      id: newId(),
      createdAt: t,
      updatedAt: t,
      settings: settings,
      candidates: candidates,
      voteLog: log,
    );
    return ScrutinyArchive(items: [scrutiny], currentId: scrutiny.id);
  }
}
