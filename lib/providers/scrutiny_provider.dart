import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class ScrutinyProvider extends ChangeNotifier {
  List<Candidate> _candidates = [];
  Settings _settings = Settings();

  // Vote Log History (Replacing Snapshot History)
  final List<int> _voteLog = [];
  Map<String, int> _baseVotes = {}; // For legacy data or manual overrides not in log

  // History accessors for UI consistency (simulated)
  bool get canUndo => _voteLog.isNotEmpty;
  bool get canRedo => false; // Redo is complex with this destructive rewrite model, disabling for now or could implement a 'redo log' but user didn't ask.

  // Calculated values - RESTORED
  int _totalVotesAssigned = 0;
  int _remainingVotes = 0;
  String? _winner;

  // Getters - RESTORED
  List<Candidate> get candidates => _candidates;
  Settings get settings => _settings;
  int get totalVotesAssigned => _totalVotesAssigned;
  int get remainingVotes => _remainingVotes;
  String? get winner => _winner;

  ScrutinyProvider() {
    _loadState();
  }

  // ... (Keep _initializeCandidates) ...
  void _initializeCandidates() {
    _candidates = List.generate(
      _settings.participantsCount,
      (index) {
          final List<Color> distinctColors = [
              Colors.red, Colors.blue, Colors.green, Colors.orange, 
              Colors.purple, Colors.teal, Colors.pink, Colors.brown,
              Colors.lime, Colors.indigo, Colors.cyan, Colors.deepOrange,
              Colors.lightGreen, Colors.blueGrey, Colors.amberAccent
          ];
          return Candidate(
            name: '${AppStrings.candidatePrefix} ${index + 1}',
            votes: 0,
            color: distinctColors[index % distinctColors.length],
          );
      },
    );
    if (_settings.showBlankVotes) {
      _candidates.add(Candidate(
          name: AppStrings.blankVotes, votes: 0, color: Colors.grey));
    }
    if (_settings.showNullVotes) {
      _candidates.add(Candidate(
          name: AppStrings.nullVotes, votes: 0, color: Colors.black));
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
        for (var c in _candidates) c.votes = 0;
        _recalculateState();
    } else {
        // Legacy migration: If no log but we have votes, those are now "base" (invisible to history graph) 
        // OR we try to reverse engineer? No, simpler to just start fresh or treat as base.
        // Let's treat current votes as Base Votes so they appear in counts but maybe as a starting flat line
    }

    _persistState();
    notifyListeners();
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('candidates', jsonEncode(_candidates));
    await prefs.setString('settings', jsonEncode(_settings));
    await prefs.setStringList('vote_log', _voteLog.map((e) => e.toString()).toList());
  }

  // NOTE: Replaces old _saveHistory
  void _recalculateState() {
      // 1. Reset votes to 0
      for (var c in _candidates) c.votes = 0;
      
      // 2. Replay Log
      for (int candidateIndex in _voteLog) {
          if (candidateIndex >= 0 && candidateIndex < _candidates.length) {
              _candidates[candidateIndex].votes++;
          }
      }
      
      _calculateResults();
  }

  void vote(int index, {bool increment = true}) {
    if (index < 0 || index >= _candidates.length) return;

    if (increment) {
        if (_remainingVotes <= 0) return;
        _voteLog.add(index);
    } else {
        // Rewriting History: Remove the LAST occurrences of this candidate index
        int lastIndex = _voteLog.lastIndexOf(index);
        if (lastIndex != -1) {
            _voteLog.removeAt(lastIndex);
        } else {
            // No history to remove, safe to ignore or handle base votes if implemented
            return;
        }
    }

    _recalculateState();
    _persistState();
    notifyListeners();
  }

  void undo() {
    if (_voteLog.isNotEmpty) {
        _voteLog.removeLast(); // Standard undo is just popping the last action
        _recalculateState();
        _persistState();
        notifyListeners();
    }
  }

  void redo() {
    // Not implemented in this sequential log model without a separate redo-stack
  }

  void reset() {
    _initializeCandidates();
    _voteLog.clear();
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
      final validCount = _candidates.where((c) => c.name != AppStrings.blankVotes && c.name != AppStrings.nullVotes).length;
      if (validCount != _settings.participantsCount) {
          _settings = Settings(
              totalVoters: _settings.totalVoters, 
              participantsCount: validCount,
              showBlankVotes: _candidates.any((c) => c.name == AppStrings.blankVotes),
              showNullVotes: _candidates.any((c) => c.name == AppStrings.nullVotes)
          );
      }

      _voteLog.clear();
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
    bool needsReset = _candidates.length != 
        (newSettings.participantsCount + (newSettings.showBlankVotes ? 1 : 0) + (newSettings.showNullVotes ? 1 : 0));
        
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
    // DO NOT sort _candidates in place to prevent UI jumping
    // Create a shadow list for ranking logic
    final sortedList = List<Candidate>.from(_candidates);
    sortedList.sort((a, b) => b.votes.compareTo(a.votes));

    // Assign ranks
    for (int i = 0; i < sortedList.length; i++) {
        sortedList[i].rank = i + 1;
    }

    _totalVotesAssigned = _candidates.fold(0, (sum, c) => sum + c.votes);
    _remainingVotes = _settings.totalVoters - _totalVotesAssigned;

    _winner = null;

    final validCandidates = sortedList
        .where((c) =>
            c.name != AppStrings.blankVotes && c.name != AppStrings.nullVotes)
        .toList();

    if (validCandidates.isEmpty) return;

    // Winner Calculation Logic (same as before)
    if (validCandidates.length >= 2) {
      final firstPlace = validCandidates[0];
      final secondPlace = validCandidates[1];
      final voteGap = firstPlace.votes - secondPlace.votes;

      if (_remainingVotes >= 0 && voteGap > _remainingVotes) {
        _winner = firstPlace.name;
        // Don't return early, we need to ensure stats are consistent
      }
    }

    if (_remainingVotes <= 0 && _totalVotesAssigned > 0) {
      if (validCandidates.length >= 2 &&
          validCandidates[0].votes == validCandidates[1].votes &&
          validCandidates[0].votes > 0) {
        _winner = AppStrings.tie;
      } else {
        _winner = validCandidates.first.name;
      }
    }
  }

  // Getter for sorted candidates (for charts/export)
  List<Candidate> get sortedCandidates {
      final list = List<Candidate>.from(_candidates);
      list.sort((a, b) => b.votes.compareTo(a.votes));
      return list;
  }

  Map<int, Map<String, int>> get historyPoints {
    Map<int, Map<String, int>> points = {};
    
    // Simulate replay to build graph
    // Initial state (0 votes or Base if implemented)
    Map<String, int> currentVotes = {for (var c in _candidates) c.name: 0};
    int currentTotal = 0;
    
    // Point 0
    points[0] = Map.from(currentVotes);

    for (int candidateIndex in _voteLog) {
        if (candidateIndex >= 0 && candidateIndex < _candidates.length) {
             String name = _candidates[candidateIndex].name;
             currentVotes[name] = (currentVotes[name] ?? 0) + 1;
             currentTotal++;
             
             // Snapshot at this step
             points[currentTotal] = Map.from(currentVotes);
        }
    }
    return points;
  }

  // Export Data Helper
  String exportToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Candidato,Voti,Percentuale');
    for (var c in _candidates) {
      buffer.writeln('${c.name},${c.votes},${c.getPercentage(_totalVotesAssigned).toStringAsFixed(2)}%');
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
              'winner': _winner
          }
      };
  }
}
