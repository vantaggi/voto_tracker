import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/services/wakelock_service.dart';

import 'home_test_utils.dart';

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
    handle.dispose();
  });

  testWidgets('Azzera scrutinio: dal menu, solo dopo la conferma', (
    tester,
  ) async {
    final provider = await pumpHome(tester, const Size(420, 900));
    provider.vote(0);
    provider.vote(1);
    await tester.pumpAndSettle();

    await tapHomeMenuItem(tester, Icons.restart_alt);
    expect(find.text('Azzerare lo scrutinio?'), findsOneWidget);
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(provider.totalVotesAssigned, 2);

    await tapHomeMenuItem(tester, Icons.restart_alt);
    await tester.tap(find.widgetWithText(FilledButton, 'Azzera'));
    await tester.pumpAndSettle();
    expect(provider.totalVotesAssigned, 0);
    expect(provider.canUndo, isFalse);
  });

  group('proiettore (P9)', () {
    setUp(() {
      WakelockService.reset();
      WakelockService.toggle = (_) async {};
    });

    Future<ScrutinyProvider> openProjector(
      WidgetTester tester,
      Size size,
    ) async {
      final p = await pumpHome(tester, size);
      for (final i in [0, 0, 0, 1]) {
        p.vote(i);
      }
      await tester.pumpAndSettle();
      await openHomeProjector(tester);
      return p;
    }

    testWidgets('una riga parlata per candidato', (tester) async {
      final handle = tester.ensureSemantics();
      await openProjector(tester, const Size(1280, 800));
      expect(
        find.bySemanticsLabel('1° posto, Candidato 1: 3 voti, 75,0%'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('2° posto, Candidato 2: 1 voti, 25,0%'),
        findsOneWidget,
      );
      handle.dispose();
    });

    for (final size in const [Size(360, 800), Size(1280, 800)]) {
      testWidgets('testo al 200% senza overflow (${size.width.toInt()} dp)', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await openProjector(tester, size);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
