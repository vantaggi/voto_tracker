import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/data/scrutiny_repository.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/models/candidate.dart';
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
    if (_settings.showBlankVotes) {
      _candidates.add(
        Candidate(
          name: AppStrings.blankVotes,
          votes: 0,
          color: CandidatePalette.blank,
          type: CandidateType.blank,
        ),
      );
    }
    if (_settings.showNullVotes) {
      _candidates.add(
        Candidate(
          name: AppStrings.nullVotes,
          votes: 0,
          color: CandidatePalette.spoiled,
          type: CandidateType.spoiled,
        ),
      );
    }
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
    _settings = Settings.fromJson(_settings.toJson());
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

  void reset() {
    _initializeCandidates();
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

  void updateSettings(Settings newSettings) {
    _settings = newSettings;
    // When settings change (e.g. number of candidates), we usually reset.
    // Ideally we should prompt user, but for now we follow simple logic:
    // If participants count changed, reset.
    // If just total voters changed, recalculate.

    // We can try to be smart:
    bool needsReset =
        _candidates.length !=
        (newSettings.participantsCount +
            (newSettings.showBlankVotes ? 1 : 0) +
            (newSettings.showNullVotes ? 1 : 0));

    if (needsReset) {
      reset();
    } else {
      _calculateResults();
      _scheduleSave();
      notifyListeners();
    }
  }

  void renameCandidate(int index, String newName) {
    if (index >= 0 && index < _candidates.length) {
      _candidates[index].name = newName;
      // History is based on index, so renaming is fine, no log rewriting needed
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
