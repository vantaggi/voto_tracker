import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/widgets/candidate_row.dart';

/// FIX-015: durante lo scrutinio i tasti + e − non si spostano mai sotto il
/// dito, né quando cambia chi è in testa, né alla vittoria matematica, né a
/// scrutinio completo; e i nomi restano nell'ordine di inserimento.
void main() {
  Future<ScrutinyProvider> pumpHome(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({'locale': 'it'});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();
    final p = Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
    p.updateSettings(Settings(totalVoters: 9));
    for (var i = 0; i < 3; i++) {
      p.renameCandidate(i, 'Nome ${String.fromCharCode(65 + i)}');
    }
    await tester.pumpAndSettle();
    return p;
  }

  /// Centri di tutti i + e i − visibili, nell'ordine dell'albero.
  List<Offset> buttonCenters(WidgetTester tester) => [
    for (final icon in [Icons.add, Icons.remove])
      ...tester
          .widgetList(find.byIcon(icon))
          .map((w) => tester.getCenter(find.byWidget(w))),
  ];

  List<double> nameTops(WidgetTester tester) => [
    for (var i = 0; i < 3; i++)
      tester
          .getTopLeft(
            find.descendant(
              of: find.byType(CandidateRow),
              matching: find.text('Nome ${String.fromCharCode(65 + i)}'),
            ),
          )
          .dy,
  ];

  for (final size in const [Size(360, 740), Size(412, 915)]) {
    testWidgets(
      'scrutinio intero con il pollice: tasti e nomi fermi (${size.width.toInt()} dp)',
      (tester) async {
        final p = await pumpHome(tester, size);
        final buttons = buttonCenters(tester);
        final names = nameTops(tester);
        expect(names, orderedEquals([...names]..sort()));

        // Sorpassi continui fra B e C, poi C vince prima della fine
        // (vittoria matematica) e chiude lo scrutinio; poi una correzione col −.
        const sequence = [1, 2, 2, 1, 1, 2, 2, 2, 2];
        for (final c in sequence) {
          final plus = find.byIcon(Icons.add).at(c);
          await tester.tapAt(tester.getCenter(plus));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();
          expect(buttonCenters(tester), buttons, reason: 'dopo + su $c');
          expect(nameTops(tester), names, reason: 'dopo + su $c');
        }
        expect(p.remainingVotes, 0);
        expect(p.candidates.map((c) => c.votes).take(3), [0, 3, 6]);

        await tester.tapAt(tester.getCenter(find.byIcon(Icons.remove).at(2)));
        await tester.pumpAndSettle();
        expect(
          buttonCenters(tester),
          buttons,
          reason: 'dopo − a scrutinio chiuso',
        );
        expect(nameTops(tester), names);
      },
    );
  }
}
