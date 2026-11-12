import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';

import 'home_test_utils.dart';

/// S1: cambiare le impostazioni non deve cancellare nomi e colori, e prima
/// di perdere voti l'app lo dice.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ScrutinyProvider> fresh() async {
    SharedPreferences.setMockInitialValues({});
    final p = ScrutinyProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return p;
  }

  group('updateSettings (D1)', () {
    test(
      'più candidati: i primi tengono nome, colore e % precedente',
      () async {
        final p = await fresh();
        p.renameCandidate(0, 'Rossi');
        p.renameCandidate(1, 'Bianchi');
        p.setCandidatePreviousPercentage(0, 40);
        final color0 = p.candidates[0].color;
        p.vote(0);
        p.updateSettings(Settings(participantsCount: 5));
        final real = p.candidates.where((c) => !c.isTechnical).toList();
        expect(real.length, 5);
        expect(real[0].name, 'Rossi');
        expect(real[1].name, 'Bianchi');
        expect(real[0].color, color0);
        expect(real[0].previousPercentage, 40);
        expect(p.totalVotesAssigned, 0);
        expect(p.canUndo, isFalse);
      },
    );

    test('meno candidati: restano i primi', () async {
      final p = await fresh();
      p.renameCandidate(0, 'Rossi');
      p.renameCandidate(3, 'Verdi');
      p.updateSettings(Settings(participantsCount: 2));
      final names = [
        for (final c in p.candidates)
          if (!c.isTechnical) c.name,
      ];
      expect(names.first, 'Rossi');
      expect(names.length, 2);
      expect(names, isNot(contains('Verdi')));
    });

    test('scambiare bianche con nulle è un cambio di righe', () async {
      final p = await fresh();
      p.vote(0);
      final swap = Settings(showBlankVotes: false, showNullVotes: true);
      p.updateSettings(Settings(showBlankVotes: true, showNullVotes: false));
      p.vote(0);
      expect(p.ballotsLostWith(swap), 1);
    });

    test('cambiare solo i votanti tiene i voti', () async {
      final p = await fresh();
      p.vote(0);
      p.vote(1);
      final next = Settings(totalVoters: 50);
      expect(p.ballotsLostWith(next), 0);
      p.updateSettings(next);
      expect(p.totalVotesAssigned, 2);
    });

    test('ballotsLostWith conta le schede che si perderebbero', () async {
      final p = await fresh();
      p.vote(0);
      p.vote(1);
      p.vote(1);
      expect(p.ballotsLostWith(Settings(participantsCount: 3)), 3);
    });
  });

  test('reset (D2) azzera i voti e tiene i nomi', () async {
    final p = await fresh();
    p.renameCandidate(0, 'Rossi');
    p.setCandidatePreviousPercentage(0, 12.5);
    p.vote(0);
    p.reset();
    expect(p.candidates[0].name, 'Rossi');
    expect(p.candidates[0].previousPercentage, 12.5);
    expect(p.totalVotesAssigned, 0);
    expect(p.canUndo, isFalse);
    expect(p.canRedo, isFalse);
  });

  testWidgets('le impostazioni avvisano prima di azzerare i voti', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();
    final p = Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
    p.vote(0);
    p.vote(1);
    await tester.pumpAndSettle();

    await openHomeSettings(tester);
    expect(find.byKey(const ValueKey('settingsResetWarning')), findsNothing);
    expect(find.text('Save'), findsOneWidget);

    // Spegnere le bianche cambia le righe dello scrutinio.
    await tester.tap(find.widgetWithText(SwitchListTile, 'Blank votes'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('settingsResetWarning')), findsOneWidget);
    expect(find.textContaining('the 2 counted ballots'), findsOneWidget);
    expect(find.text('Save and reset'), findsOneWidget);
  });
}
