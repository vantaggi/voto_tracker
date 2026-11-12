import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/export_format.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/scrutiny.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/services/archive_transfer_service.dart';
import 'package:voto_tracker/services/data_export_service.dart';
import 'package:voto_tracker/services/pdf_export_service.dart';
import 'package:voto_tracker/services/results_snapshot.dart';
import 'package:voto_tracker/theme/app_theme.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';
import 'package:voto_tracker/widgets/social_results_card.dart';

final it = lookupAppLocalizations(const Locale('it'));
final en = lookupAppLocalizations(const Locale('en'));
final at = DateTime(2026, 11, 12, 10, 28);

/// Fotografia di prova: [votes] per i candidati reali, poi bianche e nulle.
ResultsSnapshot snap({
  List<String>? names,
  List<int> votes = const [6, 4, 2, 0],
  int blank = 1,
  int spoiled = 1,
  int voters = 30,
  List<double?>? previous,
  WinnerStatus status = WinnerStatus.none,
  String? winner,
  AppLocalizations? l10n,
}) {
  final n = names ?? ['Rossi', 'Bianchi', 'Verdi, Neri', '=SOMMA(A1)'];
  final candidates = [
    for (var i = 0; i < votes.length; i++)
      Candidate(
        name: n[i % n.length],
        votes: votes[i],
        color: CandidatePalette.candidates[i % 8],
        previousPercentage: previous?[i],
      ),
    Candidate(
      name: 'b',
      votes: blank,
      color: CandidatePalette.blank,
      type: CandidateType.blank,
    ),
    Candidate(
      name: 's',
      votes: spoiled,
      color: CandidatePalette.spoiled,
      type: CandidateType.spoiled,
    ),
  ];
  final log = <int>[
    for (var i = 0; i < candidates.length; i++)
      for (var k = 0; k < candidates[i].votes; k++) i,
  ];
  final settings = Settings(
    totalVoters: voters,
    participantsCount: votes.length,
  );
  return ResultsSnapshot.of(
    title: 'Consiglio di classe 3B',
    at: at,
    candidates: candidates,
    settings: settings,
    status: status,
    winnerName: winner,
    votesToWin: 5,
    history: ScrutinyEngine.history(candidates.length, log),
    l10n: l10n ?? it,
    scrutiny: Scrutiny(
      id: 'abc',
      title: 'Consiglio di classe 3B',
      createdAt: at,
      updatedAt: at,
      settings: settings,
      candidates: candidates,
      voteLog: log,
    ),
  );
}

void main() {
  late ExportFormat fit;
  late ExportFormat fen;
  setUpAll(() async {
    fit = await ExportFormat.load('it');
    fen = await ExportFormat.load('en');
  });

  group('C1 formattazione', () {
    test('decimali, percentuali e variazioni nella lingua', () {
      expect(fit.decimal(40), '40,0');
      expect(fit.percent(26.666), '26,7%');
      expect(fen.percent(26.666), '26.7%');
      expect(fit.signedPoints(6.66), '+6,7');
      expect(fit.signedPoints(-5), '−5,0');
      expect(fit.signedPoints(0.01), '0,0');
      expect(fit.decimal(1234.5), '1234,5'); // niente migliaia nel CSV
    });

    test('date in italiano', () {
      expect(fit.dateTime(at), '12 novembre 2026, 10:28');
      expect(fit.shortDateTime(at), '12 nov 2026 · 10:28');
    });

    test('nomi file da titolo e data', () {
      expect(
        ExportFormat.fileName('Consiglio di classe 3B', at, 'csv'),
        'Consiglio di classe 3B - 2026-11-12.csv',
      );
      expect(
        ExportFormat.fileName('3A/3B: "finale"?', at, 'pdf'),
        '3A-3B- -finale-- - 2026-11-12.pdf',
      );
      expect(
        ExportFormat.fileName('  ', at, 'png'),
        'Voto Tracker - 2026-11-12.png',
      );
    });

    test('passo degli assi: tacche intere e tonde', () {
      expect(niceAxisStep(4), 1);
      expect(niceAxisStep(12), 5);
      expect(niceAxisStep(52), 20);
      expect(niceAxisStep(100), 20);
    });
  });

  group('fotografia', () {
    test('classifica dei reali, poi bianche e nulle senza posizione', () {
      final s = snap(votes: [2, 6, 4, 0]);
      expect(
        [for (final r in s.rows) r.name],
        [
          'Bianchi',
          'Verdi, Neri',
          'Rossi',
          '=SOMMA(A1)',
          'Schede bianche',
          'Schede nulle',
        ],
      );
      expect([for (final r in s.rows) r.rank], [1, 2, 3, 4, null, null]);
      expect(s.counted, 14);
      expect(s.validVotes, 12);
      expect(s.leader!.name, 'Bianchi');
    });
  });

  group('C4 CSV', () {
    test('formato per Excel italiano', () {
      final csv = DataExportService.csv(
        snap(previous: [35, null, null, null]),
        it,
        fit,
      );
      expect(csv.startsWith('﻿'), isTrue);
      final lines = csv.substring(1).split('\r\n');
      expect(
        lines[0],
        '"Posizione";"Candidato";"Tipo";"Voti";"Percentuale";'
        '"Percentuale precedente";"Variazione"',
      );
      expect(lines[1], '1;"Rossi";"candidato";6;42,9;35,0;7,9');
      expect(lines[3], '3;"Verdi, Neri";"candidato";2;14,3;;');
      expect(lines[4], "4;\"'=SOMMA(A1)\";\"candidato\";0;0,0;;");
      expect(lines[5], ';"Schede bianche";"bianca";1;7,1;;');
      expect(csv, isNot(contains('Total')));
      expect(csv, isNot(contains('%')));
    });

    test('in inglese virgola e punto', () {
      final csv = DataExportService.csv(snap(l10n: en), en, fen);
      expect(csv, contains('"Position","Candidate"'));
      expect(csv, contains('1,"Rossi","candidate",6,42.9,,'));
    });

    test('virgolette nei nomi raddoppiate', () {
      expect(DataExportService.csvText('Il "Bello"'), '"Il ""Bello"""');
      expect(DataExportService.csvText('+39 333'), '"\'+39 333"');
    });
  });

  group('C4 JSON', () {
    test('formato dell\'Archivio, si reimporta, con i risultati', () {
      final text = DataExportService.json(snap(), at);
      final back = ArchiveTransferService.decode(text);
      expect(back, hasLength(1));
      expect(back.single.title, 'Consiglio di classe 3B');
      expect(back.single.voteLog, hasLength(14));
      final data = jsonDecode(text) as Map<String, dynamic>;
      final results = data['scrutinies'][0]['results'] as Map;
      expect(results['counted'], 14);
      expect(results['complete'], isFalse);
      final rows = results['rows'] as List;
      expect(rows.first['name'], 'Rossi');
      expect(rows.first['percentage'], 42.86);
      expect(rows.first['color'], matches(RegExp(r'^#[0-9A-F]{6}$')));
      expect(rows.last['type'], 'spoiled');
    });
  });

  group('C3 PDF', () {
    pw.Font? font(String name) {
      final root = Platform.environment['FLUTTER_ROOT'];
      final f = File('$root/bin/cache/artifacts/material_fonts/$name');
      return f.existsSync()
          ? pw.Font.ttf(ByteData.sublistView(f.readAsBytesSync()))
          : null;
    }

    Future<String> pdf(ResultsSnapshot s) async {
      final bytes = await PdfExportService.build(
        snapshot: s,
        l10n: it,
        format: fit,
        base: font('Roboto-Regular.ttf'),
        bold: font('Roboto-Bold.ttf'),
      );
      expect(bytes.length, greaterThan(1000));
      return latin1.decode(bytes);
    }

    test(
      'in corso, completo con vincitore, 12 candidati su più pagine',
      () async {
        await pdf(snap());
        await pdf(
          snap(
            voters: 14,
            status: WinnerStatus.elected,
            winner: 'Rossi',
            previous: [35, 40, null, null],
          ),
        );
        final many = await pdf(
          snap(
            names: [for (var i = 1; i <= 40; i++) 'Candidato numero $i'],
            votes: [for (var i = 0; i < 40; i++) 40 - i],
            voters: 2000,
          ),
        );
        // Più di una pagina: il PDF ha più oggetti /Page.
        expect(
          RegExp(r'/Type\s*/Page\b').allMatches(many).length,
          greaterThan(1),
        );
      },
    );
  });

  group('C2 immagine', () {
    Future<void> pumpCard(WidgetTester tester, ResultsSnapshot s) async {
      await tester.binding.setSurfaceSize(const Size(600, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Center(
            child: SocialResultsCard(snapshot: s, l10n: it, format: fit),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(SocialResultsCard)),
        const Size(540, 675),
      );
    }

    testWidgets('in corso: in testa e righe con le barre', (tester) async {
      await pumpCard(tester, snap());
      expect(find.text('In corso'), findsOneWidget);
      expect(find.text('In testa Rossi'), findsOneWidget);
      expect(find.text('Consiglio di classe 3B'), findsOneWidget);
      expect(
        find.text('Schede bianche 1   ·   Schede nulle 1'),
        findsOneWidget,
      );
    });

    testWidgets('eletto, nomi lunghi: niente overflow', (tester) async {
      await pumpCard(
        tester,
        snap(
          names: ['Maria Antonietta Bianchi De Rossi Lunghissimo', 'B'],
          votes: [20, 10],
          voters: 32,
          status: WinnerStatus.elected,
          winner: 'Maria Antonietta Bianchi De Rossi Lunghissimo',
        ),
      );
      expect(find.text('Risultato finale'), findsOneWidget);
      expect(find.text('ELETTO'), findsOneWidget);
    });

    testWidgets('troppi candidati: "+N altri"', (tester) async {
      await pumpCard(
        tester,
        snap(
          names: [for (var i = 1; i <= 20; i++) 'Nome $i'],
          votes: [for (var i = 0; i < 20; i++) 20 - i],
          voters: 400,
        ),
      );
      expect(find.textContaining(' altri'), findsOneWidget);
    });
  });
}
