import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/settings.dart';

/// Uno scrutinio salvato nell'archivio: configurazione, candidati e registro
/// delle schede. I voti dei candidati si ricavano sempre dal registro
/// ([voteLog]), che è l'unica fonte di verità.
class Scrutiny {
  Scrutiny({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
    required this.candidates,
    List<int>? voteLog,
  }) : voteLog = voteLog ?? [];

  final String id;

  /// Titolo scelto dall'utente; `null` = titolo predefinito con la data.
  String? title;
  final DateTime createdAt;
  DateTime updatedAt;
  Settings settings;
  List<Candidate> candidates;
  final List<int> voteLog;

  int get ballotsCounted => voteLog.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'settings': settings.toJson(),
    'candidates': candidates.map((c) => c.toJson()).toList(),
    'voteLog': voteLog,
  };

  factory Scrutiny.fromJson(Map<String, dynamic> json) {
    final candidates = (json['candidates'] as List)
        .map((e) => Candidate.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final log = (json['voteLog'] as List? ?? const [])
        .map((e) => (e as num).toInt())
        .toList();
    return Scrutiny(
      id: json['id'] as String,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      settings: Settings.fromJson(Map<String, dynamic>.from(json['settings'])),
      candidates: candidates,
      voteLog: log,
    );
  }

  /// Copia come modello: stessi candidati (nomi, colori, tipi, percentuali
  /// precedenti) e impostazioni, registro vuoto.
  Scrutiny asTemplate({required String id, required DateTime now}) => Scrutiny(
    id: id,
    title: title,
    createdAt: now,
    updatedAt: now,
    settings: Settings.fromJson(settings.toJson()),
    candidates: [
      for (final c in candidates)
        Candidate(
          name: c.name,
          votes: 0,
          color: c.color,
          type: c.type,
          previousPercentage: c.previousPercentage,
        ),
    ],
  );
}
