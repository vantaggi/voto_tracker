import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/widgets/charts/history_chart.dart';
import 'package:voto_tracker/widgets/charts/percentage_chart.dart';

/// Ridisegno della Home (R2-R6): riepilogo, righe, pillola Annulla, grafici.
void main() {
  Future<ScrutinyProvider> pumpHome(WidgetTester tester, Size size) async {
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

  testWidgets('riepilogo: vuoto, in corso, eletto', (tester) async {
    final p = await pumpHome(tester, const Size(412, 915));
    expect(find.text('Nessuna scheda ancora'), findsOneWidget);
    expect(find.text('Imposta'), findsOneWidget);

    p.renameCandidate(0, 'Rossi');
    p.vote(0);
    p.vote(0);
    p.vote(1);
    await tester.pumpAndSettle();
    expect(find.text('Nessuna scheda ancora'), findsNothing);
    expect(find.text('97 rimanenti'), findsOneWidget);
    expect(find.textContaining('In testa Rossi'), findsOneWidget);
    expect(find.text('3 di 100 schede'), findsOneWidget);

    p.updateSettings(Settings(totalVoters: 3));
    await tester.pumpAndSettle();
    expect(find.text('ELETTO'), findsOneWidget);
    expect(find.text('Completato'), findsOneWidget);
    expect(find.text('Condividi i risultati'), findsOneWidget);
  });

  testWidgets('a scrutinio completo i + sono disattivati', (tester) async {
    final p = await pumpHome(tester, const Size(412, 915));
    p.updateSettings(Settings(totalVoters: 1));
    p.vote(0);
    await tester.pumpAndSettle();
    final adds = tester.widgetList<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(IconButton),
      ),
    );
    expect(adds, isNotEmpty);
    expect(adds.every((b) => b.onPressed == null), isTrue);
  });

  testWidgets('pillola: compare dopo un voto e annulla quel voto', (
    tester,
  ) async {
    final p = await pumpHome(tester, const Size(412, 915));
    expect(find.byIcon(Icons.undo), findsNothing);
    p.renameCandidate(1, 'Bianchi');
    p.vote(1);
    await tester.pumpAndSettle();
    expect(find.text('Annulla Bianchi'), findsOneWidget);

    await tester.tap(find.text('Annulla Bianchi'));
    await tester.pumpAndSettle();
    expect(p.totalVotesAssigned, 0);
    // Resta per poter ripristinare.
    await tester.tap(find.byIcon(Icons.redo));
    await tester.pumpAndSettle();
    expect(p.candidates[1].votes, 1);
  });

  testWidgets('tocco sul nome apre Modifica Nome', (tester) async {
    await pumpHome(tester, const Size(412, 915));
    await tester.tap(find.text('Candidato 1'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('grafici: chiusi sul telefono, aperti sul tablet', (
    tester,
  ) async {
    await pumpHome(tester, const Size(412, 915));
    expect(find.byType(HistoryChart), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Andamento e grafici'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Andamento e grafici'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryChart), findsOneWidget);
    await tester.tap(find.text('Percentuali'));
    await tester.pumpAndSettle();
    expect(find.byType(PercentageChart), findsOneWidget);

    await pumpHome(tester, const Size(1280, 800));
    expect(find.byType(HistoryChart), findsOneWidget);
  });
}
