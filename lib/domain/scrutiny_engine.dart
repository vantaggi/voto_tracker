import 'package:voto_tracker/models/candidate.dart';

/// Stato del vincitore. Identità stabile (non basata su stringhe):
/// `mathematical` = vantaggio incolmabile a scrutinio aperto,
/// `elected` = primo a scrutinio chiuso, `tie` = pareggio finale.
enum WinnerStatus { none, mathematical, elected, tie }

/// Esito di uno scrutinio calcolato da [ScrutinyEngine]. Tutti gli indici si
/// riferiscono all'ordine dei candidati passato all'engine (quello mostrato a
/// schermo, che non viene mai riordinato).
class ScrutinyOutcome {
  const ScrutinyOutcome({
    required this.totalAssigned,
    required this.remaining,
    required this.ranks,
    required this.status,
    required this.winnerIndex,
    required this.votesToWin,
  });

  /// Schede scrutinate (bianche e nulle comprese).
  final int totalAssigned;

  /// Schede ancora da scrutinare (`totalVoters - totalAssigned`).
  final int remaining;

  /// Posizione in classifica (da 1) per ogni candidato, schede tecniche
  /// comprese. A parità di voti vale l'ordine originale.
  final List<int> ranks;

  final WinnerStatus status;

  /// Indice del vincitore; `null` se non c'è o in caso di pareggio.
  final int? winnerIndex;

  /// "Magic number": voti che mancano al primo per avere un vantaggio
  /// incolmabile sul secondo. `null` se non ci sono candidati reali.
  final int? votesToWin;
}

/// Logica pura dello scrutinio: niente Flutter, niente persistenza, niente
/// stato. Il provider le passa i dati e ne espone il risultato alla UI.
class ScrutinyEngine {
  const ScrutinyEngine._();

  /// Voti per candidato ricavati dal registro delle schede (indici).
  /// Gli indici fuori intervallo vengono ignorati.
  static List<int> tally(int candidateCount, Iterable<int> log) {
    final votes = List<int>.filled(candidateCount, 0);
    for (final i in log) {
      if (i >= 0 && i < candidateCount) votes[i]++;
    }
    return votes;
  }

  /// Andamento dello scrutinio: l'elemento `k` contiene i voti di ogni
  /// candidato dopo le prime `k` schede valide del registro (l'elemento 0 è
  /// tutto a zero).
  static List<List<int>> history(int candidateCount, Iterable<int> log) {
    var current = List<int>.filled(candidateCount, 0);
    final points = [List<int>.of(current)];
    for (final i in log) {
      if (i < 0 || i >= candidateCount) continue;
      current = List<int>.of(current)..[i] += 1;
      points.add(current);
    }
    return points;
  }

  /// Indici ordinati per voti decrescenti; a parità vale l'ordine originale
  /// (ordinamento stabile, la classifica non "salta" fra un voto e l'altro).
  static List<int> ranking(List<int> votes) {
    final order = List<int>.generate(votes.length, (i) => i);
    order.sort((a, b) {
      final byVotes = votes[b].compareTo(votes[a]);
      return byVotes != 0 ? byVotes : a.compareTo(b);
    });
    return order;
  }

  /// Calcola totali, classifica, vincitore e magic number.
  ///
  /// Solo i candidati [CandidateType.normal] possono vincere; bianche e nulle
  /// contano nel totale scrutinato.
  static ScrutinyOutcome evaluate({
    required List<CandidateType> types,
    required List<int> votes,
    required int totalVoters,
  }) {
    assert(types.length == votes.length);
    final order = ranking(votes);
    final ranks = List<int>.filled(votes.length, 0);
    for (var pos = 0; pos < order.length; pos++) {
      ranks[order[pos]] = pos + 1;
    }

    final total = votes.fold<int>(0, (sum, v) => sum + v);
    final remaining = totalVoters - total;
    final valid = order.where((i) => types[i] == CandidateType.normal).toList();

    var status = WinnerStatus.none;
    int? winner;
    int? votesToWin;

    if (valid.isNotEmpty) {
      final first = votes[valid[0]];
      if (valid.length >= 2) {
        final second = votes[valid[1]];
        // Vantaggio incolmabile: anche se tutte le schede mancanti andassero
        // al secondo, il primo resterebbe davanti.
        if (remaining >= 0 && first - second > remaining) {
          status = WinnerStatus.mathematical;
          winner = valid[0];
        }
        final needed = ((second + remaining - first) / 2).floor() + 1;
        votesToWin = needed < 0 ? 0 : needed;
      } else {
        final majority = (totalVoters / 2).floor() + 1;
        votesToWin = first >= majority ? 0 : majority - first;
      }

      if (remaining <= 0 && total > 0) {
        final tie =
            valid.length >= 2 &&
            votes[valid[0]] == votes[valid[1]] &&
            votes[valid[0]] > 0;
        status = tie ? WinnerStatus.tie : WinnerStatus.elected;
        winner = tie ? null : valid[0];
      }
    }

    return ScrutinyOutcome(
      totalAssigned: total,
      remaining: remaining,
      ranks: ranks,
      status: status,
      winnerIndex: winner,
      votesToWin: votesToWin,
    );
  }
}
