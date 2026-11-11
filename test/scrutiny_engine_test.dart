import 'package:flutter_test/flutter_test.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/models/candidate.dart';

const n = CandidateType.normal;
const b = CandidateType.blank;
const s = CandidateType.spoiled;

ScrutinyOutcome eval(
  List<int> votes,
  int total, {
  List<CandidateType>? types,
}) => ScrutinyEngine.evaluate(
  types: types ?? List.filled(votes.length, n),
  votes: votes,
  totalVoters: total,
);

void main() {
  group('tally e history', () {
    test('tally conta il registro e ignora indici fuori intervallo', () {
      expect(ScrutinyEngine.tally(3, [0, 2, 2, 5, -1]), [1, 0, 2]);
    });

    test('history parte da zero e ha un punto per scheda valida', () {
      final h = ScrutinyEngine.history(2, [0, 1, 9, 0]);
      expect(h, [
        [0, 0],
        [1, 0],
        [1, 1],
        [2, 1],
      ]);
    });
  });

  group('classifica', () {
    test('ordinamento stabile: a parità vale l\'ordine originale', () {
      expect(ScrutinyEngine.ranking([3, 5, 3, 5]), [1, 3, 0, 2]);
      expect(eval([3, 5, 3, 5], 100).ranks, [3, 1, 4, 2]);
    });
  });

  group('vincitore', () {
    test('nessuno a inizio scrutinio', () {
      final o = eval([0, 0, 0], 10);
      expect(o.status, WinnerStatus.none);
      expect(o.winnerIndex, isNull);
      expect(o.remaining, 10);
    });

    test('vantaggio matematico a scrutinio aperto', () {
      // 6 a 1 con 3 schede mancanti: il secondo arriva al massimo a 4.
      final o = eval([1, 6, 0], 10);
      expect(o.status, WinnerStatus.mathematical);
      expect(o.winnerIndex, 1);
    });

    test('vantaggio pari alle schede mancanti non basta', () {
      final o = eval([5, 2], 10); // il secondo può arrivare a 5
      expect(o.status, WinnerStatus.none);
    });

    test('eletto a scrutinio chiuso', () {
      final o = eval([4, 3, 3], 10);
      expect(o.status, WinnerStatus.elected);
      expect(o.winnerIndex, 0);
    });

    test('pareggio a scrutinio chiuso', () {
      final o = eval([5, 5], 10);
      expect(o.status, WinnerStatus.tie);
      expect(o.winnerIndex, isNull);
    });

    test('bianche e nulle non vincono ma contano nel totale', () {
      final o = eval([1, 2, 6, 1], 10, types: [n, n, b, s]);
      expect(o.totalAssigned, 10);
      expect(o.status, WinnerStatus.elected);
      expect(o.winnerIndex, 1);
      expect(o.ranks[2], 1); // in classifica le bianche restano prime
    });
  });

  group('magic number', () {
    test('voti mancanti per il vantaggio incolmabile', () {
      // primo 4, secondo 2, mancano 4: serve (2+4-4)/2 floor +1 = 2.
      expect(eval([4, 2], 10).votesToWin, 2);
    });

    test('zero quando la vittoria è già matematica', () {
      expect(eval([8, 1], 10).votesToWin, 0);
    });

    test('ignora bianche e nulle in testa', () {
      // Le bianche (8) non sono il "primo": il confronto è fra 1 e 0.
      final o = eval([1, 0, 8], 20, types: [n, n, b]);
      expect(o.votesToWin, ((0 + 11 - 1) / 2).floor() + 1);
    });

    test('con un solo candidato reale vale la maggioranza assoluta', () {
      expect(eval([3, 1], 10, types: [n, b]).votesToWin, 3);
    });

    test('null senza candidati reali', () {
      expect(eval([2], 10, types: [b]).votesToWin, isNull);
    });
  });
}
