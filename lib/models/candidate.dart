import 'package:flutter/material.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Tipo di candidato. È l'**identità stabile** usata dalla logica (mai il nome,
/// che è localizzabile/rinominabile): `normal` = candidato reale,
/// `blank` = schede bianche, `spoiled` = schede nulle.
enum CandidateType { normal, blank, spoiled }

class Candidate {
  String name;
  int votes;
  Color color;
  CandidateType type;
  int rank = 0; // Transient property for display, initialized to 0
  double? previousPercentage; // For Swing Analysis

  Candidate({
    required this.name,
    required this.votes,
    required this.color,
    this.type = CandidateType.normal,
    this.rank = 0,
    this.previousPercentage,
  });

  /// True per schede bianche/nulle (candidati "tecnici"), escluse dal calcolo
  /// del vincitore.
  bool get isTechnical => type != CandidateType.normal;

  double getPercentage(int totalVotes) {
    return totalVotes > 0 ? (votes / totalVotes) * 100 : 0;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'votes': votes,
    'color': color.toARGB32(),
    'type': type.name,
    'previousPercentage': previousPercentage,
  };

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'],
      votes: json['votes'],
      color: Color(json['color']),
      type: _typeFromJson(json),
      rank: json['rank'] ?? 0,
      previousPercentage: json['previousPercentage'] != null
          ? (json['previousPercentage'] as num).toDouble()
          : null,
    );
  }

  /// Legge il tipo dal JSON; per i dati legacy (senza `type`) lo deduce dal nome
  /// storico delle schede tecniche.
  static CandidateType _typeFromJson(Map<String, dynamic> json) {
    final raw = json['type'];
    if (raw is String) {
      return CandidateType.values.firstWhere(
        (t) => t.name == raw,
        orElse: () => CandidateType.normal,
      );
    }
    final name = json['name'];
    if (name == AppStrings.blankVotes) return CandidateType.blank;
    if (name == AppStrings.nullVotes) return CandidateType.spoiled;
    return CandidateType.normal;
  }
}
