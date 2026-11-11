import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/data/scrutiny_repository.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';

/// Dati come li salva la 1.2/1.3 (schema v1): candidati con `type`, registro
/// delle schede come lista di stringhe.
Map<String, Object> v12Data() => {
  'settings': jsonEncode({
    'totalVoters': 30,
    'participantsCount': 3,
    'showBlankVotes': true,
    'showNullVotes': true,
  }),
  'candidates': jsonEncode([
    {
      'name': 'Rossi',
      'votes': 4,
      'color': 0xFFD84B41,
      'type': 'normal',
      'previousPercentage': 40.5,
    },
    {
      'name': 'Bianchi',
      'votes': 2,
      'color': 0xFF007FD7,
      'type': 'normal',
      'previousPercentage': null,
    },
    {
      'name': 'Verdi',
      'votes': 1,
      'color': 0xFF049023,
      'type': 'normal',
      'previousPercentage': null,
    },
    {
      'name': 'Schede Bianche',
      'votes': 1,
      'color': 0xFF8B8B8B,
      'type': 'blank',
      'previousPercentage': null,
    },
    {
      'name': 'Schede Nulle',
      'votes': 1,
      'color': 0xFF000000,
      'type': 'spoiled',
      'previousPercentage': null,
    },
  ]),
  'vote_log': ['0', '1', '0', '3', '2', '0', '4', '1', '0'],
};

List<Candidate> defaults(Settings s) => [
  Candidate(name: 'Default', votes: 0, color: CandidatePalette.forIndex(0)),
];

void main() {
  final fixed = DateTime(2026, 11, 11, 22);

  Future<(ScrutinyRepository, SharedPreferences)> repo(
    Map<String, Object> data,
  ) async {
    SharedPreferences.setMockInitialValues(data);
    final prefs = await SharedPreferences.getInstance();
    return (ScrutinyRepository(prefs, clock: () => fixed), prefs);
  }

  group('migrazione v1 → v2', () {
    test('dati 1.2 reali: nessuna perdita', () async {
      final (r, prefs) = await repo(v12Data());
      final archive = await r.load(createDefault: defaults);

      expect(archive.items, hasLength(1));
      final s = archive.current;
      expect(s.settings.totalVoters, 30);
      expect(s.settings.participantsCount, 3);
      expect(s.candidates.map((c) => c.name), [
        'Rossi',
        'Bianchi',
        'Verdi',
        'Schede Bianche',
        'Schede Nulle',
      ]);
      expect(s.candidates.map((c) => c.type), [
        CandidateType.normal,
        CandidateType.normal,
        CandidateType.normal,
        CandidateType.blank,
        CandidateType.spoiled,
      ]);
      expect(s.candidates[0].previousPercentage, 40.5);
      expect(s.candidates[1].color.toARGB32(), 0xFF007FD7);
      expect(s.voteLog, [0, 1, 0, 3, 2, 0, 4, 1, 0]);
      expect(s.createdAt, fixed);

      // Schema aggiornato, chiavi v1 lasciate come copia di sicurezza.
      expect(prefs.getInt(ScrutinyRepository.kSchemaVersion), 2);
      expect(prefs.getString('candidates'), v12Data()['candidates']);
      expect(prefs.getStringList('vote_log'), v12Data()['vote_log']);
    });

    test(
      'dati 1.1 senza tipo né registro: voti convertiti in registro',
      () async {
        final (r, _) = await repo({
          'candidates': jsonEncode([
            {'name': 'A', 'votes': 2, 'color': 0xFFD84B41},
            {'name': 'Schede Nulle', 'votes': 1, 'color': 0xFF000000},
          ]),
        });
        final s = (await r.load(createDefault: defaults)).current;
        expect(s.candidates[1].type, CandidateType.spoiled);
        expect(s.voteLog, [0, 0, 1]);
      },
    );

    test('installazione nuova: scrutinio di default', () async {
      final (r, _) = await repo({});
      final s = (await r.load(createDefault: defaults)).current;
      expect(s.candidates.single.name, 'Default');
      expect(s.voteLog, isEmpty);
    });

    test('la migrazione avviene una volta sola', () async {
      final (r, prefs) = await repo(v12Data());
      final first = await r.load(createDefault: defaults);
      // Dopo la migrazione le chiavi v1 non vengono più lette.
      await prefs.setStringList('vote_log', ['0']);
      final again = await ScrutinyRepository(prefs)
          .load(createDefault: defaults);
      expect(again.current.id, first.current.id);
      expect(again.current.voteLog, hasLength(9));
    });
  });

  group('v2', () {
    test('salva e rilegge archivio e scrutinio aperto', () async {
      final (r, prefs) = await repo({});
      final archive = await r.load(createDefault: defaults);
      final copy = archive.current.asTemplate(id: r.newId(), now: fixed);
      archive.items.add(copy);
      archive.currentId = copy.id;
      copy.voteLog.addAll([0, 0]);
      await r.save(archive);

      final back = await ScrutinyRepository(prefs)
          .load(createDefault: defaults);
      expect(back.items, hasLength(2));
      expect(back.currentId, copy.id);
      expect(back.current.voteLog, [0, 0]);
    });

    test('archivio illeggibile: messo da parte, non sovrascritto', () async {
      final (r, prefs) = await repo({
        ScrutinyRepository.kSchemaVersion: 2,
        ScrutinyRepository.kScrutinies: '{rotto',
      });
      final archive = await r.load(createDefault: defaults);
      expect(archive.items, hasLength(1));
      expect(prefs.getString(ScrutinyRepository.kCorruptBackup), '{rotto');
    });
  });

  test('il provider riapre i dati 1.2 migrati con gli stessi totali', () async {
    SharedPreferences.setMockInitialValues(v12Data());
    final p = ScrutinyProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(p.candidates.map((c) => c.votes), [4, 2, 1, 1, 1]);
    expect(p.totalVotesAssigned, 9);
    expect(p.remainingVotes, 21);
    expect(p.canUndo, isTrue);
  });
}
