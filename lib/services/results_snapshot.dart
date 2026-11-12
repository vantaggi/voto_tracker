import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/export_format.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/scrutiny.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';

/// Una riga dei risultati: candidato reale o scheda bianca / nulla.
class ResultRow {
  const ResultRow({
    required this.index,
    required this.rank,
    required this.name,
    required this.type,
    required this.votes,
    required this.percent,
    required this.color,
    this.previous,
  });

  /// Posizione del candidato nello scrutinio (indice della storia).
  final int index;

  /// Posizione in classifica fra i candidati reali; `null` per bianche e
  /// nulle, che non sono in classifica.
  final int? rank;

  /// Nome già localizzato ("Schede bianche" per le bianche).
  final String name;
  final CandidateType type;
  final int votes;

  /// Percentuale sulle schede contate.
  final double percent;

  /// Risultato precedente in percentuale, se l'utente l'ha inserito.
  final double? previous;
  final Color color;

  bool get isTechnical => type != CandidateType.normal;

  /// Variazione in punti percentuali rispetto a [previous].
  double? get change => previous == null ? null : percent - previous!;
}

/// Fotografia dei risultati per immagine, PDF, CSV e JSON (C1): un solo
/// punto che decide titolo, classifica, esito e storia, così i quattro
/// formati non possono dire cose diverse.
class ResultsSnapshot {
  const ResultsSnapshot({
    required this.title,
    required this.at,
    required this.status,
    required this.winnerName,
    required this.rule,
    required this.totalVoters,
    required this.counted,
    required this.remaining,
    required this.votesToWin,
    required this.rows,
    required this.history,
    this.eligibleVoters,
    this.scrutiny,
  });

  final String title;
  final DateTime at;
  final WinnerStatus status;

  /// Nome del vincitore (solo eletto o vittoria matematica).
  final String? winnerName;
  final VictoryRule rule;
  final int totalVoters;
  final int counted;
  final int remaining;
  final int? votesToWin;
  final int? eligibleVoters;

  /// Candidati reali in ordine di classifica, poi bianche e nulle.
  final List<ResultRow> rows;

  /// `history[k][i]`: voti del candidato `i` dopo `k` schede.
  final List<List<int>> history;

  /// Scrutinio completo (registro compreso) per il JSON reimportabile.
  final Scrutiny? scrutiny;

  Iterable<ResultRow> get candidates => rows.where((r) => !r.isTechnical);
  Iterable<ResultRow> get technical => rows.where((r) => r.isTechnical);

  int get validVotes => candidates.fold(0, (s, r) => s + r.votes);
  int votesOf(CandidateType type) =>
      rows.where((r) => r.type == type).fold(0, (s, r) => s + r.votes);

  bool get isComplete => remaining <= 0 && counted > 0;
  bool get hasPrevious => candidates.any((r) => r.previous != null);

  /// Primo in classifica, se ha almeno un voto.
  ResultRow? get leader {
    final first = candidates.firstOrNull;
    return first == null || first.votes == 0 ? null : first;
  }

  /// I primi due sono pari (con almeno un voto).
  bool get leaderTied {
    final top = candidates.take(2).toList();
    return top.length == 2 && top[0].votes > 0 && top[0].votes == top[1].votes;
  }

  /// Affluenza sugli aventi diritto, se il quorum è impostato.
  double? get turnout {
    final e = eligibleVoters;
    return e == null || e <= 0 ? null : counted / e * 100;
  }

  factory ResultsSnapshot.fromProvider(
    ScrutinyProvider p,
    AppLocalizations l10n,
    ExportFormat format, {
    required DateTime at,
  }) {
    final current = p.currentScrutiny;
    final title = (current?.title?.isNotEmpty ?? false)
        ? current!.title!
        : l10n.defaultScrutinyTitle(
            format.mediumDate(current?.createdAt ?? at),
          );
    return ResultsSnapshot.of(
      title: title,
      at: at,
      candidates: p.candidates,
      settings: p.settings,
      status: p.winnerStatus,
      winnerName: p.winnerName,
      votesToWin: p.votesUntilMajority,
      history: p.history,
      l10n: l10n,
      scrutiny: p.liveScrutiny(at),
    );
  }

  /// Costruisce la fotografia dai candidati nell'ordine dello scrutinio.
  factory ResultsSnapshot.of({
    required String title,
    required DateTime at,
    required List<Candidate> candidates,
    required Settings settings,
    required WinnerStatus status,
    required String? winnerName,
    required int? votesToWin,
    required List<List<int>> history,
    required AppLocalizations l10n,
    Scrutiny? scrutiny,
  }) {
    final votes = [for (final c in candidates) c.votes];
    final counted = votes.fold<int>(0, (s, v) => s + v);
    final order = ScrutinyEngine.ranking(votes);
    ResultRow row(int i, int? rank) {
      final c = candidates[i];
      return ResultRow(
        index: i,
        rank: rank,
        name: localizedCandidateName(l10n, c),
        type: c.type,
        votes: c.votes,
        percent: c.getPercentage(counted),
        previous: c.isTechnical ? null : c.previousPercentage,
        color: c.color,
      );
    }

    final real = [
      for (final i in order)
        if (!candidates[i].isTechnical) i,
    ];
    final rows = [
      for (var k = 0; k < real.length; k++) row(real[k], k + 1),
      for (final type in const [CandidateType.blank, CandidateType.spoiled])
        for (var i = 0; i < candidates.length; i++)
          if (candidates[i].type == type) row(i, null),
    ];
    return ResultsSnapshot(
      title: title,
      at: at,
      status: status,
      winnerName: winnerName,
      rule: settings.victoryRule,
      totalVoters: settings.totalVoters,
      counted: counted,
      remaining: settings.totalVoters - counted,
      votesToWin: votesToWin,
      eligibleVoters: settings.hasQuorum ? settings.eligibleVoters : null,
      rows: rows,
      history: history,
      scrutiny: scrutiny,
    );
  }
}

/// Passo "tondo" per un asse di numeri interi (1, 2, 5, 10, 20, 25, 50…),
/// in modo da avere al massimo [maxTicks] tacche fino a [maxValue].
int niceAxisStep(int maxValue, {int maxTicks = 5}) {
  if (maxValue <= maxTicks) return 1;
  var magnitude = 1;
  while (true) {
    for (final m in const [1, 2, 5]) {
      final step = m * magnitude;
      if (maxValue / step <= maxTicks) return step;
    }
    magnitude *= 10;
  }
}
