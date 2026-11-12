import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:voto_tracker/l10n/export_labels.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/services/pdf_palette.dart';

class PdfExportService {
  static Future<void> exportToPdf({
    required List<Candidate> candidates,
    required int totalVotesAssigned,
    required int totalVoters,
    required int remainingVotes,
    required Map<int, Map<String, int>> historyPoints,
    required ExportLabels labels,
    String? winner,
    String? winnerLabel,
    WinnerStatus status = WinnerStatus.none,
    PdfPalette? palette,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final p = palette ?? PdfPalette.brand;

    doc.addPage(
      pw.Page(
        // Single Page constraint (MultiPage would paginate)
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildModernHeader(winner, winnerLabel, status, labels, p),
              pw.SizedBox(height: 24),
              _buildStatsStrip(
                totalVotesAssigned,
                totalVoters,
                remainingVotes,
                labels,
                p,
              ),
              pw.SizedBox(height: 24),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      children: [
                        _buildBarChart(
                          candidates,
                          totalVotesAssigned,
                          labels,
                          p,
                        ),
                        pw.SizedBox(height: 24),
                        _buildDonutChart(
                          candidates,
                          totalVotesAssigned,
                          totalVoters,
                          labels,
                          p,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 24),
                  pw.Expanded(
                    flex: 6,
                    child: _buildHistoryChart(
                      historyPoints,
                      candidates,
                      labels,
                      p,
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              _buildCompactTable(
                candidates,
                totalVotesAssigned,
                labels,
                status,
                p,
              ),

              pw.SizedBox(height: 16),
              _buildFooter(labels, p),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'scrutinio_report.pdf',
    );
  }

  /// Testo dell'etichetta dell'esito nel PDF, `null` se lo scrutinio non ha
  /// ancora un esito. Es. "ELETTO: Rossi", "RISULTATO FINALE: Pareggio".
  static String? outcomeText(
    String? winner,
    String? winnerLabel,
    ExportLabels labels,
  ) => winner == null
      ? null
      : '${winnerLabel ?? labels.winnerFallback}: $winner';

  /// Il candidato in testa si segna nella tabella solo se è davvero solo in
  /// testa: non con un pareggio.
  static bool marksLeader(WinnerStatus status) => status != WinnerStatus.tie;

  static pw.Widget _buildModernHeader(
    String? winner,
    String? winnerLabel,
    WinnerStatus status,
    ExportLabels labels,
    PdfPalette p,
  ) {
    final text = outcomeText(winner, winnerLabel, labels);
    final (chip, onChip) = p.outcomeColors(status);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              labels.appTitlePro.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: p.title,
                letterSpacing: 1.2,
              ),
            ),
            pw.Text(
              labels.reportSubtitle,
              style: pw.TextStyle(
                fontSize: 10,
                color: p.subtitle,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        if (text != null)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: chip,
              borderRadius: pw.BorderRadius.circular(16), // M3 Medium Shape
            ),
            child: pw.Text(
              text,
              style: pw.TextStyle(
                color: onChip,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              DateTime.now().toString().substring(0, 10),
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.Text(
              DateTime.now().toString().substring(11, 16),
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildStatsStrip(
    int totalVotesAssigned,
    int totalVoters,
    int remainingVotes,
    ExportLabels labels,
    PdfPalette p,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: pw.BoxDecoration(
        color: p.strip,
        borderRadius: pw.BorderRadius.circular(16), // M3 Medium Shape
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildCompactStat(
            labels.countedVotes.toUpperCase(),
            "$totalVotesAssigned / $totalVoters",
            p,
          ),
          pw.Container(width: 1, height: 24, color: p.divider),
          _buildCompactStat(
            labels.remaining.toUpperCase(),
            "$remainingVotes",
            p,
          ),
          pw.Container(width: 1, height: 24, color: p.divider),
          _buildCompactStat(
            labels.completion,
            "${(totalVoters > 0 ? (totalVotesAssigned / totalVoters * 100) : 0).toStringAsFixed(1)}%",
            p,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCompactStat(String label, String value, PdfPalette p) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: p.onStrip,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 8, color: p.onStrip, letterSpacing: 1),
        ),
      ],
    );
  }

  static pw.Widget _buildBarChart(
    List<Candidate> candidates,
    int totalVotes,
    ExportLabels labels,
    PdfPalette p,
  ) {
    if (candidates.isEmpty) return pw.Container();
    final maxVotes = candidates.isEmpty
        ? 10
        : candidates.map((c) => c.votes).reduce((a, b) => a > b ? a : b);
    final scale = maxVotes > 0 ? 100.0 / maxVotes : 0.0;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: p.border),
        borderRadius: pw.BorderRadius.circular(16),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            labels.ranking,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 12),
          ...candidates.map((c) {
            final barWidth = c.votes * scale;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      labels.nameOf(c),
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey800,
                      ),
                      maxLines: 2,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                  pw.Expanded(
                    flex: 6,
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: barWidth > 0 ? barWidth : 1,
                          height: 10, // Thicker bars
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromInt(c.color.toARGB32()),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                        ),
                        pw.SizedBox(width: 6),
                        pw.Text(
                          '${c.votes}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildHistoryChart(
    Map<int, Map<String, int>> historyPoints,
    List<Candidate> candidates,
    ExportLabels labels,
    PdfPalette p,
  ) {
    if (historyPoints.length < 2) {
      return pw.Container(
        height: 200,
        child: pw.Center(child: pw.Text(labels.insufficientData)),
      );
    }

    final sortedKeys = historyPoints.keys.toList()..sort();

    final validCandidates = candidates.where((c) => !c.isTechnical);

    final datasets = <pw.Dataset>[];
    for (var c in validCandidates) {
      final data = <pw.PointChartValue>[];
      for (var x in sortedKeys) {
        final y = historyPoints[x]?[c.name] ?? 0;
        data.add(pw.PointChartValue(x.toDouble(), y.toDouble()));
      }
      datasets.add(
        pw.LineDataSet(
          data: data,
          color: PdfColor.fromInt(c.color.toARGB32()),
          pointSize: 0, // No dots for cleaner look
          isCurved: true,
          lineWidth: 2,
        ),
      );
    }

    // Calculate max Y for scaling
    double maxY = 0;
    for (var c in validCandidates) {
      if (c.votes > maxY) maxY = c.votes.toDouble();
    }
    maxY = (maxY * 1.1).ceilToDouble();
    if (maxY < 10) maxY = 10;

    final double step = maxY / 5;
    final yAxisSteps = List.generate(6, (i) => (i * step).round());

    final int xStep = (sortedKeys.length / 8).ceil();
    final xAxisLabels = <int>[];
    for (int i = 0; i < sortedKeys.length; i += xStep) {
      xAxisLabels.add(sortedKeys[i]);
    }
    if (xAxisLabels.isEmpty || xAxisLabels.last != sortedKeys.last) {
      xAxisLabels.add(sortedKeys.last);
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: p.border),
        borderRadius: pw.BorderRadius.circular(16),
      ),
      padding: const pw.EdgeInsets.all(16),
      height: 280,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            labels.trend,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Expanded(
            child: pw.Chart(
              grid: pw.CartesianGrid(
                xAxis: pw.FixedAxis(
                  xAxisLabels,
                  textStyle: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                yAxis: pw.FixedAxis(
                  yAxisSteps,
                  textStyle: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              datasets: datasets,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDonutChart(
    List<Candidate> candidates,
    int totalVotes,
    int totalVoters,
    ExportLabels labels,
    PdfPalette p,
  ) {
    if (totalVotes == 0) return pw.Container();
    final validCandidates = candidates.where((c) => c.votes > 0).toList();

    return pw.Container(
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Stack(
              alignment: pw.Alignment.center,
              children: [
                pw.Chart(
                  grid: pw.PieGrid(),
                  datasets: validCandidates.map((c) {
                    return pw.PieDataSet(
                      value: c.votes.toDouble(),
                      color: PdfColor.fromInt(c.color.toARGB32()),
                      innerRadius: 30, // DONUT EFFECT
                      legend: null,
                    );
                  }).toList(),
                ),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      "${(totalVotes / (totalVoters > 0 ? totalVoters : 1) * 100).toInt()}%",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: p.title,
                      ),
                    ),
                    pw.Text(
                      labels.completionShort,
                      style: pw.TextStyle(fontSize: 6, color: p.subtitle),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: validCandidates
                .take(5)
                .map(
                  (c) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 8,
                          height: 8,
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromInt(c.color.toARGB32()),
                            borderRadius: pw.BorderRadius.circular(2),
                          ),
                        ),
                        pw.SizedBox(width: 4),
                        pw.Text(
                          "${c.getPercentage(totalVotes).toStringAsFixed(1)}%",
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCompactTable(
    List<Candidate> candidates,
    int totalVotes,
    ExportLabels labels,
    WinnerStatus status,
    PdfPalette p,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: p.border),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.ClipRRect(
        verticalRadius: 12,
        horizontalRadius: 12,
        child: pw.TableHelper.fromTextArray(
          headers: [
            labels.colPosition,
            labels.colCandidate,
            labels.colVotes.toUpperCase(),
            '%',
            labels.colStatus,
          ],
          data: candidates.asMap().entries.map((entry) {
            final c = entry.value;
            final index = entry.key + 1;
            return [
              '$index',
              labels.nameOf(c),
              '${c.votes}',
              '${c.getPercentage(totalVotes).toStringAsFixed(1)}%',
              (index == 1 && marksLeader(status)) ? labels.leader : '',
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: p.onHeader,
          ),
          headerDecoration: pw.BoxDecoration(color: p.header),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellHeight: 24,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.center,
          },
          oddRowDecoration: pw.BoxDecoration(color: p.stripe),
        ),
      ),
    );
  }

  static pw.Widget _buildFooter(ExportLabels labels, PdfPalette p) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: p.border)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            labels.generatedWithPro,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            labels.pageFooter,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }
}
