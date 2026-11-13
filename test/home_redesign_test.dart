import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/widgets/charts/compare_chart.dart';
import 'package:voto_tracker/widgets/charts/trend_chart.dart';
import 'package:voto_tracker/widgets/candidate_row.dart';
import 'package:voto_tracker/widgets/undo_bar.dart';
import 'package:voto_tracker/widgets/vote_summary_card.dart';

/// Ridisegno della Home (R2-R6): riepilogo, righe, barra Annulla, grafici.
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
    expect(find.text('Tocca + per contare la prima scheda.'), findsOneWidget);
    expect(find.text('0 di 100 schede'), findsOneWidget);

    p.renameCandidate(0, 'Rossi');
    p.vote(0);
    p.vote(0);
    p.vote(1);
    await tester.pumpAndSettle();
    expect(find.text('Tocca + per contare la prima scheda.'), findsNothing);
    expect(find.text('97 rimanenti'), findsOneWidget);
    expect(find.textContaining('In testa Rossi'), findsOneWidget);
    expect(find.text('3 di 100 schede'), findsOneWidget);

    p.updateSettings(Settings(totalVoters: 3));
    await tester.pumpAndSettle();
    expect(find.text('ELETTO'), findsOneWidget);
    expect(find.text('Condividi'), findsOneWidget);
  });

  testWidgets('riepilogo: pareggio in testa con un voto a testa', (
    tester,
  ) async {
    final p = await pumpHome(tester, const Size(412, 915));
    p.renameCandidate(0, 'Rossi');
    p.vote(0);
    p.vote(1);
    await tester.pumpAndSettle();
    expect(find.text('Pareggio in testa'), findsOneWidget);
    expect(find.textContaining('In testa Rossi'), findsNothing);
    p.vote(1);
    await tester.pumpAndSettle();
    expect(find.text('In testa Candidato 2'), findsOneWidget);
  });

  testWidgets('al primo voto i + non si spostano (FIX-014)', (tester) async {
    await pumpHome(tester, const Size(412, 915));
    final plus = find.byIcon(Icons.add).first;
    final before = tester.getCenter(plus);
    // Tocchi veloci nello stesso punto, come col pollice.
    for (var i = 0; i < 5; i++) {
      await tester.tapAt(before);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(tester.getCenter(plus), before);
    final p = Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
    expect(p.candidates.first.votes, 5);
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

  testWidgets('barra Annulla: sempre presente, annulla l\'ultimo voto', (
    tester,
  ) async {
    final p = await pumpHome(tester, const Size(412, 915));
    // C'è già prima del primo voto, disattivata: non compare dal nulla.
    final bar = find.byType(UndoBar);
    expect(bar, findsOneWidget);
    final barTop = tester.getTopLeft(bar);
    expect(find.text('Annulla'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.ancestor(
              of: find.text('Annulla'),
              matching: find.byWidgetPredicate((w) => w is TextButton),
            ),
          )
          .onPressed,
      isNull,
    );

    p.renameCandidate(1, 'Bianchi');
    p.vote(1);
    await tester.pumpAndSettle();
    expect(find.text('Annulla Bianchi'), findsOneWidget);
    expect(tester.getTopLeft(bar), barTop);

    await tester.tap(find.text('Annulla Bianchi'));
    await tester.pumpAndSettle();
    expect(p.totalVotesAssigned, 0);
    await tester.tap(find.byIcon(Icons.redo));
    await tester.pumpAndSettle();
    expect(p.candidates[1].votes, 1);
    expect(tester.getTopLeft(bar), barTop);
  });

  testWidgets('barra Annulla: comandi lontani dalla colonna dei +', (
    tester,
  ) async {
    await pumpHome(tester, const Size(360, 780));
    final p = Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
    final redo = tester.getCenter(find.byIcon(Icons.redo));
    final plusButton = find
        .ancestor(
          of: find.byIcon(Icons.add).first,
          matching: find.byType(IconButton),
        )
        .first;
    expect(
      tester.getTopRight(find.byIcon(Icons.redo)).dx,
      lessThan(tester.getTopLeft(plusButton).dx),
    );
    // Ripeti non si sposta con la lunghezza del nome annullato.
    p.renameCandidate(0, 'Maria Antonietta De Santis Bevilacqua');
    p.vote(0);
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.byIcon(Icons.redo)), redo);
  });

  testWidgets('telefono in orizzontale: riepilogo accanto alla lista', (
    tester,
  ) async {
    await pumpHome(tester, const Size(891, 411));
    final summary = tester.getTopLeft(find.byType(VoteSummaryCard));
    final rows = tester.getTopRight(find.byType(CandidateGroup));
    expect(summary.dx, greaterThanOrEqualTo(rows.dx));
    // Almeno due righe di candidati visibili sopra la barra Annulla.
    final barTop = tester.getTopLeft(find.byType(UndoBar)).dy;
    final second = find.byType(CandidateRow).at(1);
    expect(tester.getBottomLeft(second).dy, lessThanOrEqualTo(barTop));
  });

  testWidgets('tocco sul nome apre Modifica candidato', (tester) async {
    await pumpHome(tester, const Size(412, 915));
    await tester.tap(find.text('Candidato 1'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('grafici: chiusi sul telefono, aperti sul tablet', (
    tester,
  ) async {
    await pumpHome(tester, const Size(412, 915));
    expect(find.byType(TrendChart), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Andamento e grafici'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Andamento e grafici'));
    await tester.pumpAndSettle();
    expect(find.byType(TrendChart), findsOneWidget);
    await tester.ensureVisible(find.text('Confronto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confronto'));
    await tester.pumpAndSettle();
    expect(find.byType(CompareChart), findsOneWidget);

    await pumpHome(tester, const Size(1280, 800));
    expect(find.byType(TrendChart), findsOneWidget);
  });
}
