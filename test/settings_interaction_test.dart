import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/app_settings_page.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/screens/settings_page.dart';

import 'home_test_utils.dart';

/// Impostazioni (S2): pagina sul telefono, finestra sul tablet, contatori,
/// e la Home resta usabile dopo la chiusura.
void main() {
  // Locale di test = en se non diversamente indicato.
  Future<ScrutinyProvider> pumpApp(
    WidgetTester tester,
    Size size, {
    String? locale,
  }) async {
    // MediaQuery segue la vista, non la superficie: si impostano entrambe.
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size * tester.view.devicePixelRatio;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({'locale': ?locale});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();
    return Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
  }

  testWidgets('telefono: pagina intera, chiusura con ×, Home interattiva', (
    tester,
  ) async {
    await pumpApp(tester, const Size(412, 915));
    await openHomeSettings(tester);
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Count settings'), findsOneWidget);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsNothing);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'^1 (di|of) 100 ')), findsOneWidget);
  });

  testWidgets('tablet: finestra', (tester) async {
    await pumpApp(tester, const Size(1280, 800));
    await openHomeSettings(tester);
    expect(
      find.ancestor(
        of: find.byType(SettingsPage),
        matching: find.byType(Dialog),
      ),
      findsOneWidget,
    );
  });

  testWidgets('i contatori cambiano votanti e candidati, Salva li applica', (
    tester,
  ) async {
    final p = await pumpApp(tester, const Size(412, 915));
    await openHomeSettings(tester);
    // Nessun campo prende il fuoco da solo (niente tastiera all'apertura).
    expect(
      FocusManager.instance.primaryFocus?.context?.widget,
      isNot(isA<EditableText>()),
    );

    await tester.tap(find.byTooltip('Increase Voters'));
    await tester.pump();
    await tester.tap(find.byTooltip('Increase Voters'));
    await tester.pump();
    await tester.tap(find.byTooltip('Decrease Candidates'));
    await tester.pumpAndSettle();
    expect(find.text('102'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byType(SettingsPage), findsNothing);
    expect(p.settings.totalVoters, 102);
    expect(p.settings.participantsCount, 3);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'^1 (di|of) 102 ')), findsOneWidget);
  });

  testWidgets('il − dei candidati si ferma al minimo', (tester) async {
    await pumpApp(tester, const Size(412, 915));
    await openHomeSettings(tester);
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byTooltip('Decrease Candidates'));
      await tester.pumpAndSettle();
    }
    final minus = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Decrease Candidates'),
        matching: find.byType(IconButton),
      ),
    );
    expect(minus.onPressed, isNull);
  });

  testWidgets('lingua: dalle impostazioni a Impostazioni dell\'app', (
    tester,
  ) async {
    await pumpApp(tester, const Size(412, 915));
    await openHomeSettings(tester);
    await tester.scrollUntilVisible(
      find.text('App settings'),
      200,
      scrollable: settingsScrollable,
    );
    await tester.tap(find.text('App settings'));
    await tester.pumpAndSettle();
    expect(find.byType(AppSettingsPage), findsOneWidget);

    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();
    expect(find.text("Impostazioni dell'app"), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'^1 di 100 ')), findsOneWidget);
  });

  testWidgets('Impostazioni dell\'app dal menu dell\'Archivio', (tester) async {
    await pumpApp(tester, const Size(412, 915), locale: 'it');
    await tester.tap(find.text('Archivio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Altre azioni dell\'archivio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Impostazioni dell'app"));
    await tester.pumpAndSettle();
    expect(find.byType(AppSettingsPage), findsOneWidget);
  });
}
