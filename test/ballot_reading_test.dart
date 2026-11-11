import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/ballot_reading_screen.dart';
import 'package:voto_tracker/screens/home_page.dart';

/// FEAT-006: modalità lettura scheda.
void main() {
  Future<ScrutinyProvider> openReading(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({'locale': 'it'});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();
    final p = Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
    await tester.tap(find.byTooltip('Lettura schede'));
    await tester.pumpAndSettle();
    expect(find.byType(BallotReadingScreen), findsOneWidget);
    return p;
  }

  Future<void> tapBallot(WidgetTester tester, int i) async {
    await tester.tap(find.byKey(ValueKey('ballot-$i')));
    await tester.pump(BallotReadingScreen.tapGuard);
    await tester.pumpAndSettle();
  }

  testWidgets('una scheda alla volta, con numero e ultima registrata', (
    tester,
  ) async {
    final p = await openReading(tester);
    expect(find.text('Scheda 1 di 100'), findsOneWidget);

    await tapBallot(tester, 0);
    await tapBallot(tester, 1);
    expect(p.candidates[0].votes, 1);
    expect(p.candidates[1].votes, 1);
    expect(find.text('Scheda 3 di 100'), findsOneWidget);
    expect(find.text('Ultima: Candidato 2'), findsOneWidget);
  });

  testWidgets('doppio tocco rapido conta una scheda sola', (tester) async {
    final p = await openReading(tester);
    await tester.tap(find.byKey(const ValueKey('ballot-0')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const ValueKey('ballot-0')));
    await tester.pumpAndSettle();
    expect(p.candidates[0].votes, 1);
  });

  testWidgets('annulla toglie l\'ultima scheda', (tester) async {
    final p = await openReading(tester);
    await tapBallot(tester, 2);
    await tester.tap(find.text('Annulla ultima'));
    await tester.pumpAndSettle();
    expect(p.totalVotesAssigned, 0);
    expect(find.text('Scheda 1 di 100'), findsOneWidget);
  });

  testWidgets('a scrutinio completo i pulsanti si disattivano', (tester) async {
    final p = await openReading(tester);
    p.updateSettings(Settings(totalVoters: 2));
    await tester.pumpAndSettle();
    await tapBallot(tester, 0);
    await tapBallot(tester, 0);
    expect(find.text('Scrutinio completato'), findsOneWidget);
    await tapBallot(tester, 1);
    expect(p.totalVotesAssigned, 2);
  });
}
