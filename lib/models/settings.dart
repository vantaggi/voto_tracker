import 'dart:math' as math;

import 'package:voto_tracker/utils/app_constants.dart';

/// Regola per dichiarare il vincitore (FEAT-005).
/// - `plurality`: maggioranza relativa, vince chi ha più voti (comportamento
///   storico dell'app).
/// - `absoluteMajority`: serve più della metà delle schede (bianche e nulle
///   comprese); altrimenti il risultato è "maggioranza non raggiunta".
enum VictoryRule { plurality, absoluteMajority }

class Settings {
  int _totalVoters;
  int _participantsCount;
  bool _showBlankVotes;
  bool _showNullVotes;

  Settings({
    int totalVoters = 100,
    int participantsCount = 4,
    this._showBlankVotes = true,
    this._showNullVotes = true,
    this.victoryRule = VictoryRule.plurality,
    this.eligibleVoters,
    this.quorumPercent,
  }) : _totalVoters = math.max(1, totalVoters),
       _participantsCount = math.max(
         AppStrings.minParticipants,
         participantsCount,
       );

  /// Regola di vittoria.
  VictoryRule victoryRule;

  /// Aventi diritto al voto, per il quorum di affluenza (null = nessun quorum).
  int? eligibleVoters;

  /// Quorum di affluenza in percentuale degli aventi diritto (null = nessuno).
  int? quorumPercent;

  /// Quorum attivo solo se sono impostati sia gli aventi diritto sia la soglia.
  bool get hasQuorum =>
      eligibleVoters != null && eligibleVoters! > 0 && quorumPercent != null;

  /// Affluenza sufficiente: le schede attese ([totalVoters]) raggiungono la
  /// soglia. Sempre vero se il quorum non è impostato.
  bool get quorumReached =>
      !hasQuorum || totalVoters * 100 >= eligibleVoters! * quorumPercent!;

  int get totalVoters => _totalVoters;
  int get participantsCount => _participantsCount;
  bool get showBlankVotes => _showBlankVotes;
  bool get showNullVotes => _showNullVotes;

  void updateTotalVoters(int count) => _totalVoters = math.max(1, count);

  void updateParticipantsCount(int count) =>
      _participantsCount = math.max(AppStrings.minParticipants, count);
  void updateShowBlankVotes(bool show) => _showBlankVotes = show;
  void updateShowNullVotes(bool show) => _showNullVotes = show;

  Map<String, dynamic> toJson() => {
    'totalVoters': _totalVoters,
    'participantsCount': _participantsCount,
    'showBlankVotes': _showBlankVotes,
    'showNullVotes': _showNullVotes,
    'victoryRule': victoryRule.name,
    'eligibleVoters': eligibleVoters,
    'quorumPercent': quorumPercent,
  };

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      totalVoters: json['totalVoters'] ?? 100,
      participantsCount: json['participantsCount'] ?? 4,
      showBlankVotes: json['showBlankVotes'] ?? true,
      showNullVotes: json['showNullVotes'] ?? true,
      victoryRule: VictoryRule.values.firstWhere(
        (r) => r.name == json['victoryRule'],
        orElse: () => VictoryRule.plurality,
      ),
      eligibleVoters: (json['eligibleVoters'] as num?)?.toInt(),
      quorumPercent: (json['quorumPercent'] as num?)?.toInt(),
    );
  }
}
