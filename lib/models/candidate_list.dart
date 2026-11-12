import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/settings.dart';

/// Lista di candidati salvata (FEAT-008, P10): nomi, colori e impostazioni
/// da riusare per un nuovo scrutinio. Niente voti.
class CandidateList {
  CandidateList({
    required this.id,
    required this.name,
    required this.candidates,
    required this.settings,
  });

  final String id;
  String name;

  /// Solo i candidati veri (niente bianche e nulle), con 0 voti.
  final List<Candidate> candidates;
  final Settings settings;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'candidates': [for (final c in candidates) c.toJson()],
    'settings': settings.toJson(),
  };

  factory CandidateList.fromJson(Map<String, dynamic> json) => CandidateList(
    id: json['id'] as String,
    name: json['name'] as String,
    candidates: [
      for (final e in json['candidates'] as List)
        Candidate.fromJson(Map<String, dynamic>.from(e)),
    ],
    settings: Settings.fromJson(Map<String, dynamic>.from(json['settings'])),
  );
}
