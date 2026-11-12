import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/models/scrutiny.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/archive_page.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/services/archive_transfer_service.dart';

/// P7: esporta e importa l'archivio in un file JSON.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ScrutinyProvider> loaded() async {
    SharedPreferences.setMockInitialValues({});
    final p = ScrutinyProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return p;
  }

  Scrutiny copy(Scrutiny s) => Scrutiny.fromJson(s.toJson());

  group('formato del file', () {
    test('andata e ritorno danno scrutini identici', () async {
      final p = await loaded();
      p.vote(0);
      p.vote(1);
      await p.newScrutiny();
      p.vote(2);
      await p.flushPendingSave();
      final now = DateTime.utc(2026, 11, 12, 10);
      final file = ArchiveTransferService.encode(p.archive, now);
      final back = ArchiveTransferService.decode(file);
      expect(
        back.map((s) => s.toJson()).toList(),
        p.archive.map((s) => s.toJson()).toList(),
      );
      expect(
        ArchiveTransferService.fileName(now),
        'voto_tracker_archivio_2026-11-12.json',
      );
      p.dispose();
    });

    test('file di un\'altra app, formato futuro o rotto: rifiutati', () {
      for (final bad in [
        '{rotto',
        '[]',
        '{"app": "altro", "format": 1, "scrutinies": []}',
        '{"app": "voto_tracker", "format": 99, "scrutinies": []}',
        '{"app": "voto_tracker", "format": 1, "scrutinies": [{"id": 1}]}',
      ]) {
        expect(
          () => ArchiveTransferService.decode(bad),
          throwsA(isA<ArchiveFormatException>()),
          reason: bad,
        );
      }
    });
  });

  group('importScrutinies', () {
    test('aggiunge, salta i doppioni identici, non sovrascrive', () async {
      final p = await loaded();
      final current = p.currentScrutinyId;
      p.vote(0);
      await p.flushPendingSave();
      final mine = copy(p.archive.single);

      // Stesso scrutinio identico: saltato.
      expect(await p.importScrutinies([copy(mine)]), (0, 1));

      // Stesso id ma con altre schede: entra con un id nuovo.
      final changed = copy(mine)..voteLog.add(1);
      // Uno nuovo.
      final other = copy(mine);
      final fresh = Scrutiny.fromJson({...other.toJson(), 'id': 'altro'});
      expect(await p.importScrutinies([changed, fresh]), (2, 0));

      expect(p.archive, hasLength(3));
      expect(p.archive.map((s) => s.id).toSet(), hasLength(3));
      expect(p.currentScrutinyId, current); // l'aperto non cambia
      expect(p.candidates[0].votes, 1);
      p.dispose();
    });

    test('gli importati sopravvivono al riavvio', () async {
      final p = await loaded();
      final s = Scrutiny.fromJson({...p.archive.single.toJson(), 'id': 'x'});
      await p.importScrutinies([s]);
      final again = ScrutinyProvider();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(again.archive.map((e) => e.id), contains('x'));
      p.dispose();
      again.dispose();
    });
  });

  testWidgets('dal menu dell\'archivio: conferma e messaggio', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({'locale': 'it'});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();
    final p = Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
    await tester.tap(find.text('Archivio'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Altre azioni dell\'archivio'), findsOneWidget);

    final incoming = [
      Scrutiny.fromJson({...p.archive.single.toJson(), 'id': 'a'}),
      Scrutiny.fromJson({...p.archive.single.toJson(), 'id': 'b'}),
    ];
    final context = tester.element(find.byType(ArchivePage));
    final done = importArchiveForTest(context, () async => incoming);
    await tester.pumpAndSettle();
    expect(find.textContaining('Nel file ci sono 2 scrutini'), findsOneWidget);
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();
    await done;
    await tester.pumpAndSettle();
    expect(find.text('Scrutini aggiunti: 2. Già presenti: 0.'), findsOneWidget);
    expect(p.archive, hasLength(3));

    // File non valido: solo un messaggio, archivio intatto.
    final bad = importArchiveForTest(
      context,
      () async => throw const ArchiveFormatException('app'),
    );
    await tester.pumpAndSettle();
    await bad;
    await tester.pumpAndSettle();
    expect(
      find.text('Questo file non è un archivio di Voto Tracker'),
      findsOneWidget,
    );
    expect(p.archive, hasLength(3));
  });
}
