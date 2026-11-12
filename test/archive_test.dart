import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/archive_page.dart';
import 'package:voto_tracker/screens/home_page.dart';

/// FEAT-004 + UI-005: archivio scrutini e navigazione adattiva.
void main() {
  Future<ScrutinyProvider> pumpApp(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({'locale': 'it'});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();
    return Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
  }

  testWidgets('NavigationBar sotto 600 dp, NavigationRail sopra', (
    tester,
  ) async {
    await pumpApp(tester, const Size(420, 900));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    await tester.binding.setSurfaceSize(const Size(1000, 800));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('flusso completo: nuovo, duplica, riapri, rinomina, elimina', (
    tester,
  ) async {
    final p = await pumpApp(tester, const Size(420, 900));
    p.vote(0);
    p.vote(0);
    p.renameCandidate(0, 'Rossi');
    final firstId = p.currentScrutinyId!;
    await tester.pumpAndSettle();

    // Vai all'archivio: c'è lo scrutinio aperto con 2 schede.
    await tester.tap(find.text('Archivio'));
    await tester.pumpAndSettle();
    expect(find.byType(ArchivePage), findsOneWidget);
    expect(find.textContaining('2 su 100 schede'), findsOneWidget);
    expect(find.textContaining('In testa: Rossi'), findsOneWidget);

    // Nuovo scrutinio: si torna al conteggio, a zero.
    await tester.tap(find.text('Nuovo scrutinio'));
    await tester.pumpAndSettle();
    expect(p.totalVotesAssigned, 0);
    expect(p.archive, hasLength(2));
    expect(find.byType(NavigationBar), findsOneWidget);
    final secondId = p.currentScrutinyId!;
    expect(secondId, isNot(firstId));

    // Riapri il primo dall'archivio: i voti ci sono ancora.
    await tester.tap(find.text('Archivio'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('In testa: Rossi'));
    await tester.pumpAndSettle();
    expect(p.currentScrutinyId, firstId);
    expect(p.candidates[0].votes, 2);
    expect(p.candidates[0].name, 'Rossi');

    // Duplica come modello: stessi candidati, nessuna scheda.
    await tester.tap(find.text('Archivio'));
    await tester.pumpAndSettle();
    final firstTile = find.ancestor(
      of: find.textContaining('In testa: Rossi'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: firstTile, matching: find.byIcon(Icons.more_vert)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplica come modello'));
    await tester.pumpAndSettle();
    expect(p.archive, hasLength(3));
    expect(p.candidates[0].name, 'Rossi');
    expect(p.totalVotesAssigned, 0);

    // Rinomina lo scrutinio aperto.
    await tester.tap(find.text('Archivio'));
    await tester.pumpAndSettle();
    final currentTile = find.ancestor(
      of: find.textContaining('Aperto ·'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: currentTile, matching: find.byIcon(Icons.more_vert)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rinomina'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Assemblea di classe');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('Assemblea di classe'), findsOneWidget);

    // Elimina con conferma: "Annulla" non elimina, "Elimina" sì.
    Future<void> openDelete() async {
      final tile = find.ancestor(
        of: find.text('Assemblea di classe'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(of: tile, matching: find.byIcon(Icons.more_vert)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elimina'));
      await tester.pumpAndSettle();
      expect(find.text('Eliminare lo scrutinio?'), findsOneWidget);
    }

    await openDelete();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(p.archive, hasLength(3));

    await openDelete();
    await tester.tap(find.widgetWithText(FilledButton, 'Elimina'));
    await tester.pumpAndSettle();
    expect(p.archive, hasLength(2));
    expect(find.text('Assemblea di classe'), findsNothing);
    // Era quello aperto: ora è aperto un altro scrutinio esistente.
    expect(p.archive.map((s) => s.id), contains(p.currentScrutinyId));
  });

  test('eliminare l\'unico scrutinio ne crea uno nuovo', () async {
    SharedPreferences.setMockInitialValues({});
    final p = ScrutinyProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    final only = p.currentScrutinyId!;
    await p.deleteScrutiny(only);
    expect(p.archive, hasLength(1));
    expect(p.currentScrutinyId, isNot(only));
  });

  test('l\'archivio sopravvive al riavvio', () async {
    SharedPreferences.setMockInitialValues({});
    final p = ScrutinyProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    p.vote(1);
    await p.newScrutiny();
    p.vote(0);
    await p.flushPendingSave();

    final again = ScrutinyProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(again.archive, hasLength(2));
    expect(again.currentScrutinyId, p.currentScrutinyId);
    expect(again.candidates[0].votes, 1);
  });
}
