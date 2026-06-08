import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/screens/settings_dialog.dart';

void main() {
  // Locale di test = en: i pulsanti sono in inglese ("Cancel").

  testWidgets('interattiva dopo apertura/chiusura impostazioni (senza cambio lingua)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();

    // Baseline: l'interazione funziona PRIMA del dialog.
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('1 / 100'), findsOneWidget);

    // Apri e chiudi le impostazioni.
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsDialog), findsNothing);

    // Dopo la chiusura l'app deve essere ancora interattiva.
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('2 / 100'), findsOneWidget);
  });

  testWidgets('interattiva dopo cambio lingua e chiusura (Annulla)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Cambia lingua in Italiano dal selettore.
    await tester.tap(find.text('Italiano'), warnIfMissed: false);
    await tester.pumpAndSettle();

    final closeIt = find.text('Annulla');
    await tester.tap(closeIt.evaluate().isNotEmpty ? closeIt : find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsDialog), findsNothing);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('1 / 100'), findsOneWidget);
  });

  testWidgets('interattiva dopo cambio lingua e Salva impostazioni',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Italiano'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Chiudi con Salva (percorso con Navigator.pop + Future.delayed).
    final saveIt = find.text('Salva');
    await tester.tap(saveIt.evaluate().isNotEmpty ? saveIt : find.text('Save'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byType(SettingsDialog), findsNothing);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('1 / 100'), findsOneWidget);
  });
}
