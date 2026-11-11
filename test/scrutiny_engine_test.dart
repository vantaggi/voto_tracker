import 'package:flutter_test/flutter_test.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/settings.dart';

const n = CandidateType.normal;
const b = CandidateType.blank;
const s = CandidateType.spoiled;

ScrutinyOutcome eval(
  List<int> votes,
  int total, {
  List<CandidateType>? types,
  VictoryRule rule = VictoryRule.plurality,
  bool quorum = true,
}) => ScrutinyEngine.evaluate(
  types: types ?? List.filled(votes.length, n),
  votes: votes,
  totalVoters: total,
  rule: rule,
  quorumReached: quorum,
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

  group('maggioranza assoluta', () {
    const abs = VictoryRule.absoluteMajority;

    test('vittoria certa appena si supera la metà delle schede', () {
      final o = eval([6, 1, 0], 10, rule: abs); // 6 > 10/2
      expect(o.status, WinnerStatus.mathematical);
      expect(o.winnerIndex, 0);
      expect(o.votesToWin, 0);
    });

    test('a metà esatta non basta', () {
      expect(eval([5, 0], 10, rule: abs).status, WinnerStatus.none);
      expect(eval([5, 0], 10, rule: abs).votesToWin, 1);
    });

    test('scrutinio chiuso senza maggioranza: ballottaggio', () {
      final o = eval([4, 3, 3], 10, rule: abs);
      expect(o.status, WinnerStatus.noMajority);
      expect(o.winnerIndex, isNull);
      expect(o.status.isInconclusive, isTrue);
    });

    test('bianche e nulle contano per la soglia', () {
      // 5 voti su 10 schede, 5 bianche: nessuno supera la metà.
      final o = eval([5, 0, 5], 10, types: [n, n, b], rule: abs);
      expect(o.status, WinnerStatus.noMajority);
    });

    test('ballottaggio annunciato quando nessuno può più arrivarci', () {
      // 3, 3, 3 con 1 scheda mancante: il massimo è 4 < 6.
      expect(eval([3, 3, 3], 10, rule: abs).status, WinnerStatus.noMajority);
    });

    test('eletto a scrutinio chiuso', () {
      expect(eval([7, 3], 10, rule: abs).status, WinnerStatus.elected);
    });

    test('pareggio a scrutinio chiuso', () {
      expect(eval([5, 5], 10, rule: abs).status, WinnerStatus.tie);
    });
  });

  group('quorum', () {
    test('senza quorum nessun vincitore, con entrambe le regole', () {
      for (final rule in VictoryRule.values) {
        final open = eval([8, 1], 10, rule: rule, quorum: false);
        expect(open.status, WinnerStatus.noQuorum, reason: rule.name);
        expect(open.winnerIndex, isNull);
        final closed = eval([6, 4], 10, rule: rule, quorum: false);
        expect(closed.status, WinnerStatus.noQuorum, reason: rule.name);
      }
    });

    test('a inizio scrutinio non si segnala ancora nulla', () {
      expect(eval([0, 0], 10, quorum: false).status, WinnerStatus.none);
    });

    test('Settings.quorumReached confronta schede attese e aventi diritto', () {
      final s = Settings(
        totalVoters: 49,
        eligibleVoters: 100,
        quorumPercent: 50,
      );
      expect(s.quorumReached, isFalse);
      s.updateTotalVoters(50);
      expect(s.quorumReached, isTrue);
      expect(Settings(totalVoters: 1).quorumReached, isTrue);
    });

    test('le regole sopravvivono al JSON', () {
      final s = Settings.fromJson(
        Settings(
          victoryRule: VictoryRule.absoluteMajority,
          eligibleVoters: 120,
          quorumPercent: 40,
        ).toJson(),
      );
      expect(s.victoryRule, VictoryRule.absoluteMajority);
      expect(s.eligibleVoters, 120);
      expect(s.quorumPercent, 40);
      // JSON v1 senza i nuovi campi: maggioranza relativa, nessun quorum.
      final legacy = Settings.fromJson({'totalVoters': 10});
      expect(legacy.victoryRule, VictoryRule.plurality);
      expect(legacy.hasQuorum, isFalse);
    });
  });
}
