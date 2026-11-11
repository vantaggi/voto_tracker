import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';

/// UI-004: testo grande (textScaler 2.0) senza overflow ed etichette parlate
/// per voti e pulsanti.
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

  for (final size in const [Size(360, 800), Size(1280, 800)]) {
    testWidgets('textScaler 2.0 senza overflow (${size.width.toInt()} dp)', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final provider = await pumpHome(tester, size);
      provider.vote(0);
      provider.vote(1);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('voti e pulsanti hanno etichette semantiche', (tester) async {
    final handle = tester.ensureSemantics();
    final provider = await pumpHome(tester, const Size(420, 900));
    provider.vote(0);
    provider.vote(0);
    await tester.pumpAndSettle();

    // La card unisce le etichette dei figli: il conteggio parlato è dentro.
    expect(
      find.bySemanticsLabel(RegExp('Candidato 1: 2 voti')),
      findsOneWidget,
    );
    final cards = provider.candidates.length;
    expect(
      find.bySemanticsLabel(RegExp(r'^Aggiungi un voto a .+')),
      findsNWidgets(cards),
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Togli un voto a .+')),
      findsNWidgets(cards),
    );
    // Il pulsante è in fondo alla lista: portalo in vista.
    await tester.ensureVisible(find.text('TIENI PREMUTO PER RESETTARE'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.bySemanticsLabel('TIENI PREMUTO PER RESETTARE')),
      matchesSemantics(
        label: 'TIENI PREMUTO PER RESETTARE',
        hint: 'Tieni premuto per azzerare lo scrutinio',
        isButton: true,
        hasLongPressAction: true,
      ),
    );
    handle.dispose();
  });
}
