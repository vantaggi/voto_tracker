import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Apre una voce del menu ⋮ della Home (proiettore, impostazioni, azzera)
/// cercandola per icona, così funziona in ogni lingua.
Future<void> tapHomeMenuItem(WidgetTester tester, IconData icon) async {
  await tester.tap(find.byIcon(Icons.more_vert));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(icon));
  await tester.pumpAndSettle();
}

/// Impostazioni dal menu ⋮ della Home.
Future<void> openHomeSettings(WidgetTester tester) =>
    tapHomeMenuItem(tester, Icons.settings_outlined);

/// Modalità proiettore dal menu ⋮ della Home.
Future<void> openHomeProjector(WidgetTester tester) =>
    tapHomeMenuItem(tester, Icons.tv);
