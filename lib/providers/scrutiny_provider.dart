import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show listEquals;

import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/data/scrutiny_repository.dart';
import 'package:voto_tracker/data/templates_repository.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/candidate_list.dart';
import 'package:voto_tracker/models/scrutiny.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';
import 'package:voto_tracker/utils/app_constants.dart';

export 'package:voto_tracker/domain/scrutiny_engine.dart'
    show WinnerStatus, WinnerStatusX;

class ScrutinyProvider extends ChangeNotifier {
  List<Candidate> _candidates = [];
  Settings _settings = Settings();

  // Vote Log History (Replacing Snapshot History)
  final List<int> _voteLog = [];
  // Stack delle azioni annullate (LIFO), per il redo. Transiente: non persiste
  // fra i riavvii e viene svuotato a ogni nuova azione.
  final List<int> _redoStack = [];

  bool get canUndo => _voteLog.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// Candidato dell'ultimo voto annullabile (per "Annulla Rossi"), o null.
  int? get lastVotedIndex => _voteLog.isEmpty ? null : _voteLog.last;

  // Calculated values - RESTORED
  int _totalVotesAssigned = 0;
  int _remainingVotes = 0;
  // Stato del vincitore tramite enum (identità stabile, non basata su stringhe).
  String? _winnerName; // nome del candidato vincente (null su pareggio/nessuno)
  WinnerStatus _winnerStatus = WinnerStatus.none;

  // Getters - RESTORED
  List<Candidate> get candidates => _candidates;
  Settings get settings => _settings;
  int get totalVotesAssigned => _totalVotesAssigned;
  int get remainingVotes => _remainingVotes;

  // Stato del vincitore
  WinnerStatus get winnerStatus => _winnerStatus;
  bool get hasWinner => _winnerStatus != WinnerStatus.none;
  bool get isTie => _winnerStatus == WinnerStatus.tie;

  /// Esito senza vincitore (pareggio, maggioranza o quorum non raggiunti).
  bool get isInconclusive => _winnerStatus.isInconclusive;
  String? get winnerName => _winnerName;

  /// Magic number: voti che mancano al primo per un vantaggio incolmabile
  /// sul secondo (vedi [ScrutinyEngine.evaluate]).
  int? get votesUntilMajority => _votesToWin;
  int? _votesToWin;

  /// Nome dei candidati nuovi, nella lingua dell'app (P4). Lo imposta
  /// `MaterialApp.builder` con [setDefaultCandidateNamer]: il provider non ha
  /// un `BuildContext`.
  String Function(int number) get defaultCandidateName => _namer;
  String Function(int number) _namer = _italianDefaultName;
  String? _namerLocale = 'it';

  static String _italianDefaultName(int number) =>
      '${AppStrings.candidatePrefix} $number';

  /// Lingua dei nomi predefiniti in uso (codice come `AppLocalizations.localeName`).
  String? get defaultNamesLocale => _namerLocale;

  /// Cambia la lingua dei nomi predefiniti. Se lo scrutinio aperto non ha
  /// ancora schede, i candidati che portano ancora il nome predefinito
  /// vengono rinominati nella nuova lingua; i nomi scelti dall'utente e gli
  /// scrutini con voti non cambiano mai.
  void setDefaultCandidateNamer(
    String localeName,
    String Function(int number) namer,
  ) {
    if (localeName == _namerLocale) return;
    final old = _namer;
    _namer = namer;
    _namerLocale = localeName;
    if (_archive == null || _voteLog.isNotEmpty) return;
    var changed = false;
    var n = 0;
    for (final c in _candidates) {
      if (c.type != CandidateType.normal) continue;
      n++;
      if (c.name == old(n) && c.name != namer(n)) {
        c.name = namer(n);
        changed = true;
      }
    }
    if (changed) {
      _scheduleSave();
      notifyListeners();
    }
  }

  ScrutinyProvider() {
    _loadState();
  }

  // ... (Keep _initializeCandidates) ...
  void _initializeCandidates() {
    _candidates = List.generate(
      _settings.participantsCount,
      (index) => Candidate(
        name: _namer(index + 1),
        votes: 0,
        color: CandidatePalette.forIndex(index),
      ),
    );
    _candidates.addAll(_technicalCandidates());
  }

  /// Schede bianche e nulle, se le impostazioni le prevedono.
  List<Candidate> _technicalCandidates() {
    final rows = <Candidate>[];
    if (_settings.showBlankVotes) {
      rows.add(
        Candidate(
          name: AppStrings.blankVotes,
          votes: 0,
          color: CandidatePalette.blank,
          type: CandidateType.blank,
        ),
      );
    }
    if (_settings.showNullVotes) {
      rows.add(
        Candidate(
          name: AppStrings.nullVotes,
          votes: 0,
          color: CandidatePalette.spoiled,
          type: CandidateType.spoiled,
        ),
      );
    }
    return rows;
  }

  ScrutinyRepository? _repository;
  ScrutinyArchive? _archive;

  Future<void> _loadState() async {
    final repository = await ScrutinyRepository.open();
    final archive = await repository.load(
      createDefault: (settings) {
        _settings = settings;
        _initializeCandidates();
        return _candidates;
      },
    );
    final templates = await TemplatesRepository.open();
    _templates = templates;
    _lists = templates.loadLists();
    _defaultSettings = templates.loadDefaultSettings();
    _repository = repository;
    _archive = archive;
    _applyCurrent();
    notifyListeners();
  }

  /// Copia lo scrutinio aperto dell'archivio nello stato del provider.
  void _applyCurrent() {
    final current = _archive!.current;
    _settings = current.settings;
    _candidates = current.candidates;
    _voteLog
      ..clear()
      ..addAll(current.voteLog);
    _redoStack.clear();
    _recalculateState();
  }

  // --- Salvataggio (P3) -------------------------------------------------------

  /// Ritardo con cui si raggruppano i salvataggi dei voti: una raffica di
  /// tocchi produce una sola scrittura dell'archivio.
  static const Duration saveDelay = Duration(milliseconds: 300);
  Timer? _saveTimer;
  bool _disposed = false;

  /// C'è un salvataggio in attesa del timer.
  bool get hasPendingSave => _saveTimer?.isActive ?? false;

  /// Pianifica un salvataggio raggruppato (voti, annulla, rinomina…).
  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, () {
      _saveTimer = null;
      _persistState();
    });
  }

  /// Salva subito se c'è un salvataggio in attesa. Chiamato quando l'app va
  /// in background o viene chiusa, e prima di ogni azione sull'archivio.
  Future<void> flushPendingSave() async {
    if (!hasPendingSave) return;
    _saveTimer!.cancel();
    _saveTimer = null;
    await _persistState();
  }

  @override
  void dispose() {
    if (hasPendingSave) {
      _saveTimer!.cancel();
      _saveTimer = null;
      _persistState(); // ultima scrittura, senza attendere
    }
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> _persistState() async {
    final archive = _archive;
    final repository = _repository;
    if (archive == null || repository == null) return; // ancora in caricamento
    _saveTimer?.cancel();
    _saveTimer = null;
    final current = archive.current;
    current
      ..settings = _settings
      ..candidates = _candidates
      ..updatedAt = repository.now();
    current.voteLog
      ..clear()
      ..addAll(_voteLog);
    await repository.save(archive);
  }

  // --- Archivio (FEAT-004) ---------------------------------------------------

  /// Scrutini salvati, dal più recente. Vuoto finché il caricamento non è
  /// finito.
  List<Scrutiny> get archive {
    final items = List<Scrutiny>.of(_archive?.items ?? const []);
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// Id dello scrutinio aperto (`null` durante il caricamento).
  String? get currentScrutinyId => _archive?.currentId;

  /// Scrutinio aperto (`null` durante il caricamento).
  Scrutiny? get currentScrutiny => _archive?.current;

  /// Nuovo scrutinio vuoto con le impostazioni di quello aperto.
  Future<void> newScrutiny() async {
    final archive = _archive, repository = _repository;
    if (archive == null || repository == null) return;
    await _persistState();
    // P10: le impostazioni predefinite, se salvate; se no quelle di ora.
    _settings = Settings.fromJson((_defaultSettings ?? _settings).toJson());
    _initializeCandidates();
    final t = repository.now();
    final created = Scrutiny(
      id: repository.newId(),
      createdAt: t,
      updatedAt: t,
      settings: _settings,
      candidates: _candidates,
    );
    await _openNew(created);
  }

  /// Nuovo scrutinio con candidati e impostazioni di [id], senza schede.
  Future<void> duplicateAsTemplate(String id) async {
    final archive = _archive, repository = _repository;
    if (archive == null || repository == null) return;
    await _persistState();
    final source = archive.items.firstWhere((s) => s.id == id);
    await _openNew(
      source.asTemplate(id: repository.newId(), now: repository.now()),
    );
  }

  Future<void> _openNew(Scrutiny scrutiny) async {
    _archive!
      ..items.add(scrutiny)
      ..currentId = scrutiny.id;
    _applyCurrent();
    await _repository!.save(_archive!);
    notifyListeners();
  }

  // --- Liste di candidati e impostazioni predefinite (FEAT-008, P10) --------

  TemplatesRepository? _templates;
  List<CandidateList> _lists = [];
  Settings? _defaultSettings;

  /// Liste salvate, in ordine alfabetico.
  List<CandidateList> get candidateLists =>
      List.of(_lists)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  /// Impostazioni dei nuovi scrutini; `null` = si copiano quelle dell'aperto.
  Settings? get defaultSettings => _defaultSettings;

  /// Salva candidati (nomi, colori, percentuali precedenti) e impostazioni
  /// dello scrutinio aperto come lista. Un nome già usato viene sostituito.
  Future<void> saveCandidateList(String name) async {
    final templates = _templates, repository = _repository;
    final trimmed = name.trim();
    if (templates == null || repository == null || trimmed.isEmpty) return;
    _lists.removeWhere((l) => l.name.toLowerCase() == trimmed.toLowerCase());
    _lists.add(
      CandidateList(
        id: repository.newId(),
        name: trimmed,
        candidates: [
          for (final c in _candidates)
            if (c.type == CandidateType.normal)
              Candidate(
                name: c.name,
                votes: 0,
                color: c.color,
                previousPercentage: c.previousPercentage,
              ),
        ],
        settings: Settings.fromJson(_settings.toJson()),
      ),
    );
    await templates.saveLists(_lists);
    notifyListeners();
  }

  Future<void> deleteCandidateList(String id) async {
    final templates = _templates;
    if (templates == null) return;
    _lists.removeWhere((l) => l.id == id);
    await templates.saveLists(_lists);
    notifyListeners();
  }

  /// Nuovo scrutinio con candidati e impostazioni della lista [id].
  Future<void> newScrutinyFromList(String id) async {
    final archive = _archive, repository = _repository;
    if (archive == null || repository == null) return;
    final list = _lists.where((l) => l.id == id).firstOrNull;
    if (list == null) return;
    await _persistState();
    final s = list.settings;
    _settings = Settings(
      totalVoters: s.totalVoters,
      participantsCount: list.candidates.length,
      showBlankVotes: s.showBlankVotes,
      showNullVotes: s.showNullVotes,
      victoryRule: s.victoryRule,
      eligibleVoters: s.eligibleVoters,
      quorumPercent: s.quorumPercent,
    );
    _candidates = [
      for (final c in list.candidates)
        Candidate(
          name: c.name,
          votes: 0,
          color: c.color,
          previousPercentage: c.previousPercentage,
        ),
      ..._technicalCandidates(),
    ];
    final t = repository.now();
    await _openNew(
      Scrutiny(
        id: repository.newId(),
        title: list.name,
        createdAt: t,
        updatedAt: t,
        settings: _settings,
        candidates: _candidates,
      ),
    );
  }

  /// Le impostazioni dello scrutinio aperto diventano quelle dei nuovi
  /// scrutini; con [clear] si torna a copiare quelle dell'aperto.
  Future<void> setDefaultSettingsFromCurrent({bool clear = false}) async {
    final templates = _templates;
    if (templates == null) return;
    _defaultSettings = clear ? null : Settings.fromJson(_settings.toJson());
    await templates.saveDefaultSettings(_defaultSettings);
    notifyListeners();
  }

  /// Riapre uno scrutinio dell'archivio.
  Future<void> openScrutiny(String id) async {
    final archive = _archive;
    if (archive == null || archive.currentId == id) return;
    if (!archive.items.any((s) => s.id == id)) return;
    await _persistState();
    archive.currentId = id;
    _applyCurrent();
    await _repository!.save(archive);
    notifyListeners();
  }

  /// Cambia il titolo; `null` o vuoto torna al titolo predefinito.
  Future<void> renameScrutiny(String id, String? title) async {
    final archive = _archive;
    if (archive == null) return;
    final trimmed = title?.trim();
    archive.items.firstWhere((s) => s.id == id).title =
        (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    await _repository!.save(archive);
    notifyListeners();
  }

  /// Elimina uno scrutinio. Se era quello aperto si apre il più recente fra
  /// i rimasti; se non ne resta nessuno se ne crea uno nuovo.
  Future<void> deleteScrutiny(String id) async {
    final archive = _archive;
    if (archive == null) return;
    final wasCurrent = archive.currentId == id;
    if (wasCurrent && archive.items.length == 1) {
      await newScrutiny();
    } else if (!wasCurrent) {
      await _persistState();
    }
    archive.items.removeWhere((s) => s.id == id);
    if (wasCurrent && archive.currentId == id) {
      final latest = archive.items.reduce(
        (a, b) => a.updatedAt.isAfter(b.updatedAt) ? a : b,
      );
      archive.currentId = latest.id;
      _applyCurrent();
    }
    await _repository!.save(archive);
    notifyListeners();
  }

  /// Aggiunge all'archivio gli scrutini letti da un file (P7). Non sovrascrive
  /// mai: uno scrutinio già presente identico (stesso id, stessi candidati e
  /// stesse schede) viene saltato; uno con lo stesso id ma diverso entra con
  /// un id nuovo. Lo scrutinio aperto non cambia.
  /// Restituisce (aggiunti, saltati).
  Future<(int, int)> importScrutinies(List<Scrutiny> incoming) async {
    final archive = _archive, repository = _repository;
    if (archive == null || repository == null) return (0, 0);
    await _persistState();
    var added = 0, skipped = 0;
    for (final s in incoming) {
      final same = archive.items.where((e) => e.id == s.id).firstOrNull;
      if (same == null) {
        archive.items.add(s);
        added++;
      } else if (_sameContent(same, s)) {
        skipped++;
      } else {
        archive.items.add(
          Scrutiny(
            id: repository.newId(),
            title: s.title,
            createdAt: s.createdAt,
            updatedAt: s.updatedAt,
            settings: s.settings,
            candidates: s.candidates,
            voteLog: s.voteLog,
          ),
        );
        added++;
      }
    }
    if (added > 0) {
      await repository.save(archive);
      notifyListeners();
    }
    return (added, skipped);
  }

  static bool _sameContent(Scrutiny a, Scrutiny b) =>
      listEquals(a.voteLog, b.voteLog) &&
      jsonEncode([for (final c in a.candidates) c.toJson()]) ==
          jsonEncode([for (final c in b.candidates) c.toJson()]);

  /// Ricalcola i voti rigiocando il registro delle schede.
  void _recalculateState() {
    final votes = ScrutinyEngine.tally(_candidates.length, _voteLog);
    for (var i = 0; i < _candidates.length; i++) {
      _candidates[i].votes = votes[i];
    }
    _calculateResults();
  }

  void vote(int index, {bool increment = true}) {
    if (index < 0 || index >= _candidates.length) return;

    if (increment) {
      if (_remainingVotes <= 0) return;
      _voteLog.add(index);
      _candidates[index].votes++;
    } else {
      // Rimuove l'ultima occorrenza di questo candidato dal log
      int lastIndex = _voteLog.lastIndexOf(index);
      if (lastIndex == -1) return; // niente da rimuovere
      _voteLog.removeAt(lastIndex);
      _candidates[index].votes--;
    }

    _redoStack.clear(); // una nuova azione invalida il redo
    // Aggiornamento incrementale: ogni voto cambia un solo candidato di ±1,
    // quindi non serve rigiocare l'intero log (vedi PERF-001).
    _calculateResults();
    _scheduleSave();
    notifyListeners();
  }

  void undo() {
    if (_voteLog.isEmpty) return;
    final removed = _voteLog
        .removeLast(); // sposta l'ultima azione sul redo-stack
    _redoStack.add(removed);
    if (removed >= 0 && removed < _candidates.length) {
      _candidates[removed].votes--;
    }
    _calculateResults();
    _scheduleSave();
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final restored = _redoStack
        .removeLast(); // riapplica l'ultima azione annullata
    _voteLog.add(restored);
    if (restored >= 0 && restored < _candidates.length) {
      _candidates[restored].votes++;
    }
    _calculateResults();
    _scheduleSave();
    notifyListeners();
  }

  /// Azzera i voti (D2): nomi, colori e percentuali precedenti restano.
  void reset() {
    _voteLog.clear();
    _redoStack.clear();
    _recalculateState();
    _scheduleSave();
    notifyListeners();
  }

  void loadConfiguration(List<Candidate> newCandidates) {
    _candidates = newCandidates;
    // Ensure votes are 0 if it's just a config load
    for (var c in _candidates) {
      c.votes = 0;
    }

    // Update settings participant count if needed
    final validCount = _candidates
        .where((c) => c.type == CandidateType.normal)
        .length;
    if (validCount != _settings.participantsCount) {
      _settings = Settings(
        totalVoters: _settings.totalVoters,
        participantsCount: validCount,
        showBlankVotes: _candidates.any((c) => c.type == CandidateType.blank),
        showNullVotes: _candidates.any((c) => c.type == CandidateType.spoiled),
        victoryRule: _settings.victoryRule,
        eligibleVoters: _settings.eligibleVoters,
        quorumPercent: _settings.quorumPercent,
      );
    }

    _voteLog.clear();
    _redoStack.clear();
    _recalculateState();
    _scheduleSave();
    notifyListeners();
  }

  /// Le impostazioni [next] cambiano le righe dello scrutinio (numero di
  /// candidati, bianche o nulle): salvarle azzera i voti.
  bool _changesRows(Settings next) {
    final real = _candidates.where((c) => !c.isTechnical).length;
    final blank = _candidates.any((c) => c.type == CandidateType.blank);
    final spoiled = _candidates.any((c) => c.type == CandidateType.spoiled);
    return real != next.participantsCount ||
        blank != next.showBlankVotes ||
        spoiled != next.showNullVotes;
  }

  /// Schede contate che si perderebbero salvando [next] (0 se i voti restano).
  int ballotsLostWith(Settings next) =>
      _changesRows(next) ? totalVotesAssigned : 0;

  /// Applica le impostazioni. Se cambiano le righe, i voti si azzerano ma i
  /// primi candidati tengono nome, colore e percentuale precedente (D1).
  void updateSettings(Settings newSettings) {
    final changesRows = _changesRows(newSettings);
    _settings = newSettings;
    if (!changesRows) {
      _calculateResults();
      _scheduleSave();
      notifyListeners();
      return;
    }
    final kept = _candidates.where((c) => !c.isTechnical).toList();
    _initializeCandidates();
    final real = _candidates.where((c) => !c.isTechnical).toList();
    for (var i = 0; i < real.length && i < kept.length; i++) {
      real[i]
        ..name = kept[i].name
        ..color = kept[i].color
        ..previousPercentage = kept[i].previousPercentage;
    }
    _voteLog.clear();
    _redoStack.clear();
    _recalculateState();
    _scheduleSave();
    notifyListeners();
  }

  void renameCandidate(int index, String newName) {
    if (index >= 0 && index < _candidates.length) {
      _candidates[index].name = newName;
      // History is based on index, so renaming is fine, no log rewriting needed
      _scheduleSave();
      notifyListeners();
    }
  }

  /// Colore scelto per il candidato [index] (S6).
  void setCandidateColor(int index, Color color) {
    if (index >= 0 && index < _candidates.length) {
      _candidates[index].color = color;
      _scheduleSave();
      notifyListeners();
    }
  }

  void setCandidatePreviousPercentage(int index, double? value) {
    if (index >= 0 && index < _candidates.length) {
      _candidates[index].previousPercentage = value;
      _scheduleSave();
      notifyListeners();
    }
  }

  void _calculateResults() {
    // L'ordine di _candidates non cambia mai (la UI non deve "saltare"):
    // la classifica è nel campo rank.
    final outcome = ScrutinyEngine.evaluate(
      types: [for (final c in _candidates) c.type],
      votes: [for (final c in _candidates) c.votes],
      totalVoters: _settings.totalVoters,
      rule: _settings.victoryRule,
      quorumReached: _settings.quorumReached,
    );
    for (var i = 0; i < _candidates.length; i++) {
      _candidates[i].rank = outcome.ranks[i];
    }
    _totalVotesAssigned = outcome.totalAssigned;
    _remainingVotes = outcome.remaining;
    _winnerStatus = outcome.status;
    _winnerName = outcome.winnerIndex == null
        ? null
        : _candidates[outcome.winnerIndex!].name;
    _votesToWin = outcome.votesToWin;
  }

  /// Candidati in ordine di classifica (per grafici ed export).
  List<Candidate> get sortedCandidates => [
    for (final i in ScrutinyEngine.ranking([
      for (final c in _candidates) c.votes,
    ]))
      _candidates[i],
  ];

  /// Andamento per i grafici: schede scrutinate → voti per nome.
  Map<int, Map<String, int>> get historyPoints {
    final points = ScrutinyEngine.history(_candidates.length, _voteLog);
    return {
      for (var k = 0; k < points.length; k++)
        k: {
          for (var i = 0; i < _candidates.length; i++)
            _candidates[i].name: points[k][i],
        },
    };
  }

  // Export Data Helper
  String exportToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Candidato,Voti,Percentuale');
    for (var c in _candidates) {
      buffer.writeln(
        '${c.name},${c.votes},${c.getPercentage(_totalVotesAssigned).toStringAsFixed(2)}%',
      );
    }
    buffer.writeln('Totale Voti,$_totalVotesAssigned,');
    buffer.writeln('Votanti Previsti,${_settings.totalVoters},');
    return buffer.toString();
  }

  Map<String, dynamic> exportToJson() {
    return {
      'candidates': _candidates.map((c) => c.toJson()).toList(),
      'settings': _settings.toJson(),
      'stats': {
        'totalVotes': _totalVotesAssigned,
        'totalVoters': _settings.totalVoters,
        'winner': _winnerName,
        'winnerStatus': _winnerStatus.name,
      },
    };
  }
}
