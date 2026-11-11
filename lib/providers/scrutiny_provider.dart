import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';
import 'package:voto_tracker/utils/app_constants.dart';

export 'package:voto_tracker/domain/scrutiny_engine.dart' show WinnerStatus;

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
  String? get winnerName => _winnerName;

  // Stringa di visualizzazione retro-compatibile: nome del vincitore, oppure
  // l'etichetta di pareggio in caso di parità.
  String? get winner {
    switch (_winnerStatus) {
      case WinnerStatus.none:
        return null;
      case WinnerStatus.tie:
        return AppStrings.tie;
      case WinnerStatus.elected:
      case WinnerStatus.mathematical:
        return _winnerName;
    }
  }

  // Etichetta coerente dello stato del vincitore (usata da UI, PDF e share).
  // Il vincitore è dichiarato per vantaggio matematicamente incolmabile, non per
  // maggioranza assoluta: l'etichetta riflette questa distinzione.
  String? get winnerLabel {
    switch (_winnerStatus) {
      case WinnerStatus.none:
        return null;
      case WinnerStatus.tie:
        return AppStrings.finalResult;
      case WinnerStatus.elected:
        return AppStrings.winnerElected;
      case WinnerStatus.mathematical:
        return AppStrings.winnerMathematical;
    }
  }

  /// Magic number: voti che mancano al primo per un vantaggio incolmabile
  /// sul secondo (vedi [ScrutinyEngine.evaluate]).
  int? get votesUntilMajority => _votesToWin;
  int? _votesToWin;

  ScrutinyProvider() {
    _loadState();
  }

  // ... (Keep _initializeCandidates) ...
  void _initializeCandidates() {
    _candidates = List.generate(
      _settings.participantsCount,
      (index) => Candidate(
        name: '${AppStrings.candidatePrefix} ${index + 1}',
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

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Settings
    final String? settingsJson = prefs.getString('settings');
    if (settingsJson != null) {
      try {
        _settings = Settings.fromJson(jsonDecode(settingsJson));
      } catch (e) {
        debugPrint("Error loading settings: $e");
      }
    }

    // Load Candidates (Legacy or Structure)
    final String? candidatesJson = prefs.getString('candidates');
    if (candidatesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(candidatesJson);
        _candidates = decoded.map((e) => Candidate.fromJson(e)).toList();
      } catch (e) {
        debugPrint("Error loading candidates: $e");
        _initializeCandidates();
      }
    } else {
      _initializeCandidates();
    }

    // Load Vote Log
    final List<String>? log = prefs.getStringList('vote_log');
    if (log != null) {
      _voteLog.clear();
      _voteLog.addAll(log.map((e) => int.parse(e)));
      // If we have a log, valid candidates votes are strictly derived from it + base
      // We assume loaded _candidates votes are the "base" if log exists?
      // Actually, safer to treat loaded candidates as having "base votes" equal to their current count
      // IF the log is empty. If log exists, we might need to reconcile.
      // Simplified approach: Clear candidates votes, and just replay log.
      // Assuming no "base" votes for now to ensure graph consistency.
      // If we want to support editing "base", we need a separate store.
      // For this task: Everything in graph comes from log.
      for (var c in _candidates) {
        c.votes = 0;
      }
      _recalculateState();
    } else {
      // Legacy migration: If no log but we have votes, those are now "base" (invisible to history graph)
      // OR we try to reverse engineer? No, simpler to just start fresh or treat as base.
      // Let's treat current votes as Base Votes so they appear in counts but maybe as a starting flat line
    }

    _calculateResults();
    _persistState();
    notifyListeners();
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('candidates', jsonEncode(_candidates));
    await prefs.setString('settings', jsonEncode(_settings));
    await prefs.setStringList(
      'vote_log',
      _voteLog.map((e) => e.toString()).toList(),
    );
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
    _persistState();
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
    _persistState();
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
    _persistState();
    notifyListeners();
  }

  void reset() {
    _initializeCandidates();
    _voteLog.clear();
    _redoStack.clear();
    _recalculateState();
    _persistState();
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
      );
    }

    _voteLog.clear();
    _redoStack.clear();
    _recalculateState();
    _persistState();
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
      _persistState();
      notifyListeners();
    }
  }

  void renameCandidate(int index, String newName) {
    if (index >= 0 && index < _candidates.length) {
      _candidates[index].name = newName;
      // History is based on index, so renaming is fine, no log rewriting needed
      _persistState();
      notifyListeners();
    }
  }

  void setCandidatePreviousPercentage(int index, double? value) {
    if (index >= 0 && index < _candidates.length) {
      _candidates[index].previousPercentage = value;
      _persistState();
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
        'winner': winner,
        'winnerStatus': _winnerStatus.name,
      },
    };
  }
}
