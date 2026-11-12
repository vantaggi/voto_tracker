import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/screens/projector_mode_screen.dart';
import 'package:voto_tracker/services/wakelock_service.dart';

/// P11: flusso completo sul dispositivo vero.
///
/// Si lancia dal PC col telefono collegato, sulla build di debug:
///   flutter test integration_test -d <id-telefono>
/// I dati sono finti (SharedPreferences in memoria): non tocca gli scrutini
/// della build di debug né, tanto meno, quelli della release.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<ScrutinyProvider> start(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'it'});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();
    return Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
  }

  testWidgets('voto, annulla, ripeti, Modifica nome', (tester) async {
    final p = await start(tester);
    final add = find.byIcon(Icons.add).first;
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(p.totalVotesAssigned, 2);

    await tester.ensureVisible(find.byIcon(Icons.undo).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.undo).first);
    await tester.pumpAndSettle();
    expect(p.totalVotesAssigned, 1);
    await tester.tap(find.byIcon(Icons.redo).first);
    await tester.pumpAndSettle();
    expect(p.totalVotesAssigned, 2);

    // Il dialog che il 2026-11-11 mandava l'app in errore alla chiusura.
    await tester.ensureVisible(find.byTooltip('Modifica Nome').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Modifica Nome').first);
    await tester.pumpAndSettle();
    final field = find.byType(TextField).first;
    await tester.enterText(field, 'Rossi');
    await tester.tap(find.text('Salva').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(p.candidates.first.name, 'Rossi');

    // Il salvataggio raggruppato arriva sul disco.
    await p.flushPendingSave();
    expect(p.hasPendingSave, isFalse);
  });

  testWidgets('archivio: nuovo scrutinio e ritorno al primo', (tester) async {
    final p = await start(tester);
    p.vote(0);
    p.vote(1);
    await tester.pumpAndSettle();
    final first = p.currentScrutinyId!;

    await tester.tap(find.text('Archivio').first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FloatingActionButton, 'Nuovo scrutinio'),
    );
    await tester.pumpAndSettle();
    expect(p.currentScrutinyId, isNot(first));
    expect(p.totalVotesAssigned, 0);

    await p.openScrutiny(first);
    await tester.pumpAndSettle();
    expect(p.totalVotesAssigned, 2);
  });

  testWidgets('il proiettore si apre e si chiude', (tester) async {
    WakelockService.toggle = (_) async {};
    final p = await start(tester);
    p.vote(0);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Modalità Proiettore'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.byType(ProjectorModeScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });
}
