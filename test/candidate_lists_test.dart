import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/data/templates_repository.dart';
import 'package:voto_tracker/main.dart';

import 'home_test_utils.dart';

import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';

/// FEAT-008 (P10): liste di candidati e impostazioni predefinite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ScrutinyProvider> loaded([
    Map<String, Object> prefs = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(prefs);
    final p = ScrutinyProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return p;
  }

  List<String> normalNames(ScrutinyProvider p) => [
    for (final c in p.candidates)
      if (c.type == CandidateType.normal) c.name,
  ];

  test('salva una lista e ci apre un nuovo scrutinio', () async {
    final p = await loaded();
    p.renameCandidate(0, 'Rossi');
    p.renameCandidate(1, 'Bianchi');
    p.updateSettings(
      Settings(
        totalVoters: 40,
        participantsCount: 4,
        victoryRule: VictoryRule.absoluteMajority,
      ),
    );
    p.renameCandidate(0, 'Rossi');
    p.renameCandidate(1, 'Bianchi');
    p.vote(0);
    await p.saveCandidateList('Consiglio di classe');
    expect(p.candidateLists.single.candidates, hasLength(4));

    await p.newScrutinyFromList(p.candidateLists.single.id);
    expect(normalNames(p).take(2), ['Rossi', 'Bianchi']);
    expect(p.totalVotesAssigned, 0);
    expect(p.settings.totalVoters, 40);
    expect(p.settings.victoryRule, VictoryRule.absoluteMajority);
    expect(p.currentScrutiny!.title, 'Consiglio di classe');
    expect(p.archive, hasLength(2));
    p.dispose();
  });

  test('stesso nome: la lista viene sostituita; si può eliminare', () async {
    final p = await loaded();
    await p.saveCandidateList('A');
    p.renameCandidate(0, 'Nuovo');
    await p.saveCandidateList(' a ');
    expect(p.candidateLists, hasLength(1));
    expect(p.candidateLists.single.candidates.first.name, 'Nuovo');
    await p.deleteCandidateList(p.candidateLists.single.id);
    expect(p.candidateLists, isEmpty);
    p.dispose();
  });

  test('liste e predefinite sopravvivono al riavvio', () async {
    final p = await loaded();
    await p.saveCandidateList('Lista');
    p.updateSettings(Settings(totalVoters: 25, participantsCount: 3));
    await p.setDefaultSettingsFromCurrent();
    await p.flushPendingSave();
    final again = ScrutinyProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(again.candidateLists.single.name, 'Lista');
    expect(again.defaultSettings!.totalVoters, 25);
    p.dispose();
    again.dispose();
  });

  test('nuovo scrutinio vuoto usa le impostazioni predefinite', () async {
    final p = await loaded();
    p.updateSettings(Settings(totalVoters: 25, participantsCount: 3));
    await p.setDefaultSettingsFromCurrent();
    p.updateSettings(Settings(totalVoters: 300, participantsCount: 6));
    await p.newScrutiny();
    expect(p.settings.totalVoters, 25);
    expect(p.settings.participantsCount, 3);

    await p.setDefaultSettingsFromCurrent(clear: true);
    p.updateSettings(Settings(totalVoters: 300, participantsCount: 6));
    await p.newScrutiny();
    expect(p.settings.totalVoters, 300); // di nuovo copia dell'aperto
    p.dispose();
  });

  test('dati illeggibili: si riparte senza liste, l\'app parte', () async {
    final p = await loaded({
      TemplatesRepository.kLists: '{rotto',
      TemplatesRepository.kDefaultSettings: jsonEncode('x'),
    });
    expect(p.candidateLists, isEmpty);
    expect(p.defaultSettings, isNull);
    expect(p.candidates, isNotEmpty);
    p.dispose();
  });

  testWidgets(
    'dalle impostazioni alla lista, poi nuovo scrutinio dalla lista',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({'locale': 'it'});
      await tester.pumpWidget(const VotoTrackerApp());
      await tester.pumpAndSettle();
      final p = Provider.of<ScrutinyProvider>(
        tester.element(find.byType(HomePage)),
        listen: false,
      );
      p.renameCandidate(0, 'Rossi');
      await tester.pumpAndSettle();

      await openHomeSettings(tester);
      await tester.scrollUntilVisible(
        find.text('Salva i candidati come lista'),
        200,
        scrollable: settingsScrollable,
      );
      await tester.tap(find.text('Salva i candidati come lista'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Assemblea');
      await tester.tap(find.widgetWithText(FilledButton, 'Salva').last);
      await tester.pumpAndSettle();
      expect(p.candidateLists.single.name, 'Assemblea');
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      // Lascia sparire la SnackBar "Lista salvata".
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archivio'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FloatingActionButton, 'Nuovo scrutinio'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Scrutinio vuoto'), findsOneWidget);
      await tester.tap(find.text('Assemblea'));
      await tester.pumpAndSettle();
      expect(p.archive, hasLength(2));
      expect(p.candidates.first.name, 'Rossi');
      expect(find.byType(HomePage), findsOneWidget);
    },
  );
}
