import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class ScrutinyProvider extends ChangeNotifier {
  List<Candidate> _candidates = [];
  Settings _settings = Settings();

  // History for Undo/Redo
  final List<String> _history = []; // Json strings of candidates list
  int _historyIndex = -1;

  // Calculated values
  int _totalVotesAssigned = 0;
  int _remainingVotes = 0;
  String? _winner;

  // Getters
  List<Candidate> get candidates => _candidates;
  Settings get settings => _settings;
  int get totalVotesAssigned => _totalVotesAssigned;
  int get remainingVotes => _remainingVotes;
  String? get winner => _winner;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  ScrutinyProvider() {
    _loadState();
  }

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
    final String? candidatesJson = prefs.getString('candidates');
    final String? settingsJson = prefs.getString('settings');

    if (settingsJson != null) {
      try {
        _settings = Settings.fromJson(jsonDecode(settingsJson));
      } catch (e) {
        debugPrint("Error loading settings: $e");
      }
    }

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

    _calculateResults();
    // Initialize history with current state
    _history.clear();
    _historyIndex = -1;
    _saveHistory(); 
    
    notifyListeners();
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('candidates', jsonEncode(_candidates));
    await prefs.setString('settings', jsonEncode(_settings));
  }

  void _saveHistory() {
    // Remove any redo history
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    final currentState = jsonEncode(_candidates);
    // Avoid duplicates if usage is frequent
    if (_history.isEmpty || _history.last != currentState) {
        _history.add(currentState);
        _historyIndex++;
    }
  }

  void vote(int index, {bool increment = true}) {
    if (index < 0 || index >= _candidates.length) return;

    if (!increment && _candidates[index].votes <= 0) return;

    if (increment) {
      if (_remainingVotes <= 0) return; // Prevent overvoting
      _candidates[index].votes++;
    } else {
      _candidates[index].votes--;
    }

    _calculateResults();
    _saveHistory();
    _persistState();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _historyIndex--;
    _restoreStateFromHistory();
  }

  void redo() {
    if (!canRedo) return;
    _historyIndex++;
    _restoreStateFromHistory();
  }

  void _restoreStateFromHistory() {
    final String state = _history[_historyIndex];
    final List<dynamic> decoded = jsonDecode(state);
    _candidates = decoded.map((e) => Candidate.fromJson(e)).toList();
    _calculateResults();
    _persistState();
    notifyListeners();
  }

  void reset() {
    _initializeCandidates();
    _history.clear();
    _historyIndex = -1;
    _calculateResults();
    _saveHistory();
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
      _saveHistory(); // Save name change to history? Maybe not strict requirement but good QoL
      _persistState();
      notifyListeners();
    }
  }

  void _calculateResults() {
    // Sort logic: higher votes first
    _candidates.sort((a, b) => b.votes.compareTo(a.votes));

    _totalVotesAssigned = _candidates.fold(0, (sum, c) => sum + c.votes);
    _remainingVotes = _settings.totalVoters - _totalVotesAssigned;

    _winner = null;

    final validCandidates = _candidates
        .where((c) =>
            c.name != AppStrings.blankVotes && c.name != AppStrings.nullVotes)
        .toList();

    if (validCandidates.isEmpty) return;

    // Mathematical Winner Limit
    if (validCandidates.length >= 2) {
      final firstPlace = validCandidates[0];
      final secondPlace = validCandidates[1];
      final voteGap = firstPlace.votes - secondPlace.votes;

      // Note: usage of remainingVotes. If overvoting, remainingVotes is negative.
      // Logic still holds: if gap > remaining (where remaining is negative), gap > neg is true IF gap is positive enough.
      // But standard logic implies remainingVotes >= 0.
      if (_remainingVotes >= 0 && voteGap > _remainingVotes) {
        _winner = firstPlace.name;
        return;
      }
    }

    // End of scrutiny
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

  Map<int, Map<String, int>> get historyPoints {
    Map<int, Map<String, int>> points = {};
    for (String jsonStr in _history) {
        try {
            List<dynamic> list = jsonDecode(jsonStr);
            int total = 0;
            Map<String, int> votes = {};
            for (var item in list) {
                String name = item['name'];
                int v = item['votes'];
                total += v;
                votes[name] = v;
            }
            points[total] = votes;
        } catch(e) {
            debugPrint("Error parsing history: $e");
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
