import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';

/// FIX-006: il dialog "Modifica nome" chiudeva i suoi TextEditingController
/// appena si chiudeva, mentre l'animazione di uscita li usava ancora
/// (schermo rosso sul telefono: "used after being disposed", poi
/// "_dependents.isEmpty").
void main() {
  Future<ScrutinyProvider> openDialog(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({'locale': 'it'});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();
    final p = Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
    await tester.tap(find.byTooltip('Modifica candidato').first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    return p;
  }

  testWidgets('Salva: nessun errore durante l\'animazione di chiusura', (
    tester,
  ) async {
    final p = await openDialog(tester);
    await tester.enterText(find.byType(TextField).first, 'Rossi');
    await tester.enterText(find.byType(TextField).last, '42,5');
    await tester.tap(find.text('Salva'));
    // Frame per frame: l'errore nasceva a metà dell'animazione di uscita.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(p.candidates[0].name, 'Rossi');
    expect(p.candidates[0].previousPercentage, 42.5);
  });

  testWidgets('Annulla: nessun errore e nessuna modifica', (tester) async {
    final p = await openDialog(tester);
    final before = p.candidates[0].name;
    await tester.enterText(find.byType(TextField).first, 'Non salvare');
    // Quello del dialogo: anche la barra Annulla della Home dice "Annulla".
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Annulla'),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(p.candidates[0].name, before);
  });

  testWidgets('nome vuoto: Salva non chiude il dialog', (tester) async {
    await openDialog(tester);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('S6: colore dalla tavolozza e % con la virgola', (tester) async {
    final p = await openDialog(tester);
    expect(find.text('Modifica candidato'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Colore 5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(p.candidates[0].color, CandidatePalette.candidates[4]);

    p.setCandidatePreviousPercentage(0, 12.5);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Modifica candidato').first);
    await tester.pumpAndSettle();
    expect(find.text('12,5'), findsOneWidget);
  });
}
