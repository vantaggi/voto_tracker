import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Crea un provider con prefs vuote e attende che `_loadState` (async) si
/// stabilizzi, così i test partono da uno stato deterministico.
Future<ScrutinyProvider> _freshProvider() async {
  SharedPreferences.setMockInitialValues({});
  final provider = ScrutinyProvider();
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  return provider;
}

/// Riduce lo scrutinio a `count` candidati "puri" (senza schede bianche/nulle)
/// con un totale votanti noto: scenario controllato per i test sul vincitore.
Future<ScrutinyProvider> _providerWith(
    {required int candidates, required int voters}) async {
  final provider = await _freshProvider();
  provider.updateSettings(Settings(
    totalVoters: voters,
    participantsCount: candidates,
    showBlankVotes: false,
    showNullVotes: false,
  ));
  await Future<void>.delayed(Duration.zero);
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings', () {
    test('clampa totalVoters e participantsCount nel costruttore', () {
      final s = Settings(totalVoters: 0, participantsCount: 1);
      expect(s.totalVoters, 1);
      expect(s.participantsCount, AppStrings.minParticipants);
    });

    test('round-trip JSON', () {
      final s = Settings(
          totalVoters: 250,
          participantsCount: 5,
          showBlankVotes: false,
          showNullVotes: true);
      final r = Settings.fromJson(s.toJson());
      expect(r.totalVoters, 250);
      expect(r.participantsCount, 5);
      expect(r.showBlankVotes, false);
      expect(r.showNullVotes, true);
    });
  });

  group('ScrutinyProvider — stato iniziale', () {
    test('default: 4 candidati + bianche + nulle, nessun vincitore', () async {
      final p = await _freshProvider();
      expect(p.candidates.length, 6); // 4 + bianche + nulle
      expect(p.winner, isNull);
      expect(p.winnerLabel, isNull);
      expect(p.totalVotesAssigned, 0);
      expect(p.remainingVotes, 100);
      expect(p.canUndo, isFalse);
    });
  });

  group('ScrutinyProvider — voto e log', () {
    test('increment aumenta voti, totale e abilita undo', () async {
      final p = await _providerWith(candidates: 2, voters: 10);
      p.vote(0);
      p.vote(0);
      p.vote(1);
      expect(p.candidates[0].votes, 2);
      expect(p.candidates[1].votes, 1);
      expect(p.totalVotesAssigned, 3);
      expect(p.remainingVotes, 7);
      expect(p.canUndo, isTrue);
    });

    test('decrement rimuove l\'ultima occorrenza di quel candidato', () async {
      final p = await _providerWith(candidates: 2, voters: 10);
      p.vote(0);
      p.vote(0);
      p.vote(0, increment: false);
      expect(p.candidates[0].votes, 1);
      expect(p.totalVotesAssigned, 1);
    });

    test('undo annulla l\'ultima azione', () async {
      final p = await _providerWith(candidates: 2, voters: 10);
      p.vote(0);
      p.vote(1);
      p.undo();
      expect(p.candidates[1].votes, 0);
      expect(p.candidates[0].votes, 1);
      expect(p.totalVotesAssigned, 1);
    });

    test('non si vota oltre i votanti previsti', () async {
      final p = await _providerWith(candidates: 2, voters: 1);
      p.vote(0);
      p.vote(1); // remaining == 0 -> ignorato
      expect(p.totalVotesAssigned, 1);
      expect(p.candidates[1].votes, 0);
    });

    test('reset azzera voti e log', () async {
      final p = await _providerWith(candidates: 2, voters: 10);
      p.vote(0);
      p.vote(1);
      p.reset();
      expect(p.totalVotesAssigned, 0);
      expect(p.canUndo, isFalse);
    });
  });

  group('ScrutinyProvider — vincitore', () {
    test('vittoria matematica per vantaggio incolmabile', () async {
      final p = await _providerWith(candidates: 2, voters: 10);
      for (var i = 0; i < 6; i++) {
        p.vote(0);
      }
      p.vote(1);
      // gap 5 > remaining 3 -> vincitore deciso prima della fine
      expect(p.winner, '${AppStrings.candidatePrefix} 1');
      expect(p.winnerLabel, AppStrings.winnerMathematical);
    });

    test('pareggio a scrutinio chiuso', () async {
      final p = await _providerWith(candidates: 2, voters: 4);
      p.vote(0);
      p.vote(0);
      p.vote(1);
      p.vote(1);
      expect(p.remainingVotes, 0);
      expect(p.winner, AppStrings.tie);
      expect(p.winnerLabel, AppStrings.finalResult);
    });

    test('eletto a scrutinio chiuso', () async {
      final p = await _providerWith(candidates: 2, voters: 3);
      p.vote(0);
      p.vote(0);
      p.vote(1);
      expect(p.remainingVotes, 0);
      expect(p.winner, '${AppStrings.candidatePrefix} 1');
      expect(p.winnerLabel, AppStrings.winnerElected);
    });
  });

  group('ScrutinyProvider — export & history', () {
    test('exportToCsv contiene intestazione e totale', () async {
      final p = await _providerWith(candidates: 2, voters: 10);
      p.vote(0);
      final csv = p.exportToCsv();
      expect(csv, contains('Candidato,Voti,Percentuale'));
      expect(csv, contains('Totale Voti,1'));
    });

    test('historyPoints cresce con i voti partendo dal punto 0', () async {
      final p = await _providerWith(candidates: 2, voters: 10);
      p.vote(0);
      p.vote(1);
      final pts = p.historyPoints;
      expect(pts.containsKey(0), isTrue);
      expect(pts.length, 3); // punto 0 + due voti
    });
  });
}
