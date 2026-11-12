import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/export_format.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/services/pdf_palette.dart';
import 'package:voto_tracker/services/results_snapshot.dart';

/// "Verbale dei risultati" (C3): A4 verticale, più pagine se servono.
/// Intestazione con titolo e data, esito, numeri chiave, una sola tabella
/// dei risultati con barre, andamento a gradini e, a scrutinio completo,
/// le righe per le firme.
class PdfExportService {
  const PdfExportService._();

  /// Linee dell'andamento al massimo (le altre restano nella tabella).
  static const int maxTrendLines = 8;

  /// Crea il PDF e apre il menu Condividi.
  static Future<bool> share({
    required ResultsSnapshot snapshot,
    required AppLocalizations l10n,
    required ExportFormat format,
    PdfPalette? palette,
  }) async {
    final bytes = await build(
      snapshot: snapshot,
      l10n: l10n,
      format: format,
      palette: palette,
      base: await PdfGoogleFonts.robotoRegular(),
      bold: await PdfGoogleFonts.robotoBold(),
    );
    return Printing.sharePdf(
      bytes: bytes,
      filename: ExportFormat.fileName(snapshot.title, snapshot.at, 'pdf'),
    );
  }

  /// Il documento. Separato da [share] per i test (caratteri locali).
  static Future<Uint8List> build({
    required ResultsSnapshot snapshot,
    required AppLocalizations l10n,
    required ExportFormat format,
    PdfPalette? palette,
    pw.Font? base,
    pw.Font? bold,
  }) {
    final p = palette ?? PdfPalette.brand;
    final s = snapshot;
    final doc = pw.Document(title: s.title, creator: 'Voto Tracker');
    final small = pw.TextStyle(fontSize: 8, color: p.textVariant);
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 32),
          theme: base == null
              ? null
              : pw.ThemeData.withFont(base: base, bold: bold ?? base),
        ),
        footer: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  '${s.title} · ${format.dateTime(s.at)}',
                  style: small,
                  maxLines: 1,
                ),
              ),
              pw.Text(
                '${l10n.exportFooterApp} · '
                '${l10n.pdfPage('${ctx.pageNumber}', '${ctx.pagesCount}')}',
                style: small,
              ),
            ],
          ),
        ),
        build: (ctx) => [
          ..._header(s, l10n, format, p),
          pw.SizedBox(height: 16),
          _outcome(s, l10n, format, p),
          pw.SizedBox(height: 16),
          _keyNumbers(s, l10n, format, p),
          pw.SizedBox(height: 18),
          pw.Text(
            l10n.pdfResults,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: p.text,
            ),
          ),
          pw.SizedBox(height: 6),
          _table(s, l10n, format, p),
          pw.SizedBox(height: 4),
          pw.Text(
            [l10n.pdfNote, if (s.hasPrevious) l10n.pdfNoteChange].join(' '),
            style: small,
          ),
          if (s.counted >= 2) ...[
            pw.SizedBox(height: 18),
            ..._trend(s, l10n, p),
          ],
          if (s.isComplete) ...[pw.SizedBox(height: 36), _signatures(l10n, p)],
        ],
      ),
    );
    return doc.save();
  }

  static List<pw.Widget> _header(
    ResultsSnapshot s,
    AppLocalizations l10n,
    ExportFormat f,
    PdfPalette p,
  ) => [
    pw.Text(
      l10n.pdfTitle,
      style: pw.TextStyle(
        fontSize: 9,
        letterSpacing: 1.5,
        color: p.accent,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
    pw.SizedBox(height: 4),
    pw.Text(
      s.title,
      style: pw.TextStyle(
        fontSize: 24,
        fontWeight: pw.FontWeight.bold,
        color: p.text,
      ),
    ),
    pw.Text(
      [
        f.dateTime(s.at),
        s.rule == VictoryRule.plurality
            ? l10n.rulePlurality
            : l10n.ruleAbsoluteMajority,
        l10n.pdfExpectedVoters('${s.totalVoters}'),
      ].join(' · '),
      style: pw.TextStyle(fontSize: 10, color: p.textVariant),
    ),
  ];

  static pw.Widget _outcome(
    ResultsSnapshot s,
    AppLocalizations l10n,
    ExportFormat f,
    PdfPalette p,
  ) {
    final (bg, fg) = p.outcomeColors(
      s.status == WinnerStatus.none || s.leader == null
          ? WinnerStatus.none
          : s.status,
    );
    final leader = s.leader;
    final pw.Widget child;
    if (s.winnerName != null && leader != null) {
      child = pw.Row(
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                localizedWinnerLabel(l10n, s.status) ?? '',
                style: pw.TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: fg,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                s.winnerName!,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: fg,
                ),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Text(
            l10n.pdfWinnerDetail(
              '${leader.votes}',
              '${s.counted}',
              f.percent(leader.percent),
            ),
            style: pw.TextStyle(fontSize: 11, color: fg),
          ),
        ],
      );
    } else if (s.status.isInconclusive) {
      child = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            localizedWinnerLabel(l10n, s.status) ?? '',
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 1.5,
              color: fg,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            localizedOutcomeHeadline(l10n, s.status, null),
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      );
    } else {
      child = pw.Text(
        l10n.pdfProvisional('${s.counted}', '${s.totalVoters}'),
        style: pw.TextStyle(fontSize: 11, color: fg),
      );
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  static pw.Widget _keyNumbers(
    ResultsSnapshot s,
    AppLocalizations l10n,
    ExportFormat f,
    PdfPalette p,
  ) {
    pw.Widget item(String value, String label) => pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: p.text,
            ),
          ),
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 8, color: p.textVariant),
          ),
        ],
      ),
    );
    final turnout = s.turnout;
    return pw.Row(
      children: [
        item(
          l10n.pdfCountedOf('${s.counted}', '${s.totalVoters}'),
          l10n.pdfKeyCounted,
        ),
        item('${math.max(0, s.remaining)}', l10n.pdfKeyRemaining),
        item('${s.validVotes}', l10n.pdfKeyValid),
        if (s.technical.isNotEmpty)
          item(
            s.technical.map((r) => '${r.votes}').join(' · '),
            l10n.pdfKeyBlankSpoiled,
          ),
        if (turnout != null) item(f.percent(turnout), l10n.pdfKeyTurnout),
      ],
    );
  }

  static pw.Widget _table(
    ResultsSnapshot s,
    AppLocalizations l10n,
    ExportFormat f,
    PdfPalette p,
  ) {
    const cell = pw.EdgeInsets.symmetric(vertical: 6);
    pw.Widget text(
      String t, {
      bool right = false,
      bool strong = false,
      bool muted = false,
      double size = 10,
    }) => pw.Padding(
      padding: cell,
      child: pw.Text(
        t,
        textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: size,
          color: muted ? p.textVariant : p.text,
          fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
    pw.Widget head(String t, {bool right = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Text(
        t,
        textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          color: p.textVariant,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
    final change = s.hasPrevious;
    final firstTechnical = s.rows.indexWhere((r) => r.isTechnical);
    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        children: [
          head(''),
          head(l10n.pdfColCandidate),
          head(''),
          head(l10n.pdfColVotes, right: true),
          head('%', right: true),
          if (change) head(l10n.pdfColChange, right: true),
        ],
      ),
      for (final (i, r) in s.rows.indexed)
        pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          decoration: i == firstTechnical
              ? pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: p.text, width: 0.8),
                  ),
                )
              : null,
          children: [
            text(r.rank?.toString() ?? '', muted: true),
            pw.Padding(
              padding: cell,
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 8,
                    height: 8,
                    decoration: pw.BoxDecoration(
                      color: PdfPalette.of(r.color),
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Flexible(
                    child: pw.Text(
                      r.name,
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: r.isTechnical ? p.textVariant : p.text,
                        fontWeight: r.rank == 1 && r.votes > 0
                            ? pw.FontWeight.bold
                            : pw.FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(right: 8),
              child: pw.LayoutBuilder(
                builder: (ctx, box) => pw.Container(
                  height: 6,
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    width: math.max(
                      0.0,
                      (box?.maxWidth ?? 0) * (r.percent / 100).clamp(0, 1),
                    ),
                    height: 6,
                    decoration: pw.BoxDecoration(
                      color: PdfPalette.of(r.color),
                      borderRadius: pw.BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            text('${r.votes}', right: true, strong: true, size: 11),
            text(f.percent(r.percent), right: true),
            if (change)
              text(
                r.change == null ? '' : f.signedPoints(r.change!),
                right: true,
                muted: true,
              ),
          ],
        ),
      pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: p.text, width: 0.8)),
        ),
        children: [
          pw.SizedBox(),
          text(l10n.pdfTotal, strong: true, size: 11),
          pw.SizedBox(),
          text('${s.counted}', right: true, strong: true, size: 11),
          text(f.percent(s.counted == 0 ? 0 : 100), right: true),
          if (change) pw.SizedBox(),
        ],
      ),
    ];
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(24),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FixedColumnWidth(40),
        4: const pw.FixedColumnWidth(48),
        if (change) 5: const pw.FixedColumnWidth(70),
      },
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: p.line, width: 0.5),
        bottom: pw.BorderSide(color: p.line, width: 0.5),
      ),
      children: rows,
    );
  }

  /// Andamento a gradini dei primi [maxTrendLines] candidati reali.
  static List<pw.Widget> _trend(
    ResultsSnapshot s,
    AppLocalizations l10n,
    PdfPalette p,
  ) {
    final lines = s.candidates.take(maxTrendLines).toList();
    final h = s.history;
    final maxX = h.length - 1;
    final top = lines.fold<int>(0, (m, r) => math.max(m, r.votes));
    final yStep = niceAxisStep(math.max(1, top));
    final maxY = math.max(yStep, (top / yStep).ceil() * yStep);
    final xStep = niceAxisStep(maxX, maxTicks: 6);
    final small = pw.TextStyle(fontSize: 8, color: p.textVariant);
    return [
      pw.Text(
        l10n.pdfTrend,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          color: p.text,
        ),
      ),
      pw.SizedBox(height: 6),
      pw.SizedBox(
        height: 170,
        child: pw.Chart(
          grid: pw.CartesianGrid(
            xAxis: pw.FixedAxis(
              [for (var x = 0; x < maxX; x += xStep) x, maxX],
              textStyle: small,
              divisions: false,
            ),
            yAxis: pw.FixedAxis(
              [for (var y = 0; y <= maxY; y += yStep) y],
              textStyle: small,
              divisions: true,
              divisionsColor: p.line,
            ),
          ),
          datasets: [
            for (final r in lines)
              pw.LineDataSet(
                drawPoints: false,
                isCurved: false,
                lineWidth: 2,
                color: PdfPalette.of(r.color),
                data: [
                  for (var k = 0; k < h.length; k++) ...[
                    if (k > 0)
                      pw.PointChartValue(
                        k.toDouble(),
                        h[k - 1][r.index].toDouble(),
                      ),
                    pw.PointChartValue(k.toDouble(), h[k][r.index].toDouble()),
                  ],
                ],
              ),
          ],
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          for (final r in lines)
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Container(
                  width: 10,
                  height: 3,
                  color: PdfPalette.of(r.color),
                ),
                pw.SizedBox(width: 4),
                pw.Text(r.name, style: small),
              ],
            ),
          pw.Text(l10n.pdfTrendAxes, style: small),
        ],
      ),
    ];
  }

  static pw.Widget _signatures(AppLocalizations l10n, PdfPalette p) => pw.Row(
    children: [
      for (final role in [l10n.pdfSignPresident, l10n.pdfSignTellers])
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(right: 24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 28),
                pw.Container(height: 0.6, color: p.text),
                pw.SizedBox(height: 4),
                pw.Text(
                  role,
                  style: pw.TextStyle(fontSize: 9, color: p.textVariant),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
