import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/data/scrutiny_repository.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';

/// P3: i voti si salvano a gruppi, ma niente va perso.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ScrutinyProvider> loaded() async {
    SharedPreferences.setMockInitialValues({});
    final p = ScrutinyProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return p;
  }

  Future<List<int>> savedVoteLog() async {
    final prefs = await SharedPreferences.getInstance();
    final items =
        jsonDecode(prefs.getString(ScrutinyRepository.kScrutinies)!) as List;
    return List<int>.from((items.single as Map)['voteLog'] as List);
  }

  test('una raffica di voti non scrive finché il timer non scade', () async {
    final p = await loaded();
    final before = await savedVoteLog();
    for (var i = 0; i < 10; i++) {
      p.vote(i.isEven ? 0 : 1);
    }
    expect(p.hasPendingSave, isTrue);
    expect(await savedVoteLog(), before);

    await Future<void>.delayed(
      ScrutinyProvider.saveDelay + const Duration(milliseconds: 100),
    );
    expect(p.hasPendingSave, isFalse);
    expect(await savedVoteLog(), hasLength(10));
  });

  test('flushPendingSave salva subito', () async {
    final p = await loaded();
    p.vote(0);
    p.vote(1);
    await p.flushPendingSave();
    expect(p.hasPendingSave, isFalse);
    expect(await savedVoteLog(), [0, 1]);
  });

  test(
    'annulla e ripeti passano dallo stesso salvataggio raggruppato',
    () async {
      final p = await loaded();
      p.vote(0);
      p.vote(1);
      p.undo();
      await p.flushPendingSave();
      expect(await savedVoteLog(), [0]);
      p.redo();
      await p.flushPendingSave();
      expect(await savedVoteLog(), [0, 1]);
    },
  );

  test('un\'azione sull\'archivio salva prima i voti in attesa', () async {
    final p = await loaded();
    final first = p.currentScrutinyId;
    p.vote(1);
    await p.newScrutiny();
    expect(p.hasPendingSave, isFalse);
    await p.openScrutiny(first!);
    expect(p.candidates[1].votes, 1);
  });

  test('dispose con un salvataggio in attesa scrive comunque', () async {
    final p = await loaded();
    p.vote(0);
    p.dispose();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(await savedVoteLog(), [0]);
  });
}
