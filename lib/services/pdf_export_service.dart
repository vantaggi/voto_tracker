import 'package:flutter/material.dart' hide Widget, StatelessWidget, StatefulWidget;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class PdfExportService {
  static Future<void> exportToPdf({
    required List<Candidate> candidates,
    required int totalVotesAssigned,
    required int totalVoters,
    required int remainingVotes,
    required Map<int, Map<String, int>> historyPoints,
    String? winner,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Organize data for single page layout
    final validCandidates = candidates.where((c) => c.votes > 0).toList();

    doc.addPage(
      pw.Page( // Single Page constraint (MultiPage would paginate)
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          margin: const pw.EdgeInsets.all(24),
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildModernHeader(winner),
              pw.SizedBox(height: 15),
              _buildStatsStrip(totalVotesAssigned, totalVoters, remainingVotes),
              pw.SizedBox(height: 20),
              
              // Row: Left (Bar Chart + Pie), Right (History) ??? 
              // Better: Row -> Left (Current Standings + Pie), Right (Chart)
              // Let's split 50/50
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                   pw.Expanded(
                       flex: 4,
                       child: pw.Column(
                           children: [
                               _buildBarChart(candidates, totalVotesAssigned),
                               pw.SizedBox(height: 20),
                               _buildDonutChart(candidates, totalVotesAssigned),
                           ]
                       )
                   ),
                   pw.SizedBox(width: 20),
                   pw.Expanded(
                       flex: 6,
                       child: _buildHistoryChart(historyPoints, candidates)
                   ),
                ]
              ),
              
              pw.Spacer(),
              
              _buildCompactTable(candidates, totalVotesAssigned),
              
              pw.SizedBox(height: 10),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'scrutinio_report.pdf');
  }

  static pw.Widget _buildModernHeader(String? winner) {
      return pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                      pw.Text(AppStrings.appTitlePro.toUpperCase(), 
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)
                      ),
                      pw.Text('Report Ufficiale', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                  ]
              ),
              if (winner != null)
              pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                      color: PdfColors.amber,
                      borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text("VINCITORE: $winner", 
                      style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))
              ),
              pw.Text(
                  DateTime.now().toString().substring(0, 16),
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)
              )
          ]
      );
  }

  static pw.Widget _buildStatsStrip(int totalVotesAssigned, int totalVoters, int remainingVotes) {
      return pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey50,
              borderRadius: pw.BorderRadius.circular(8)
          ),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                  _buildCompactStat("Voti Scrutinati", "$totalVotesAssigned / $totalVoters"),
                  _buildCompactStat("Rimanenti", "$remainingVotes"),
                  _buildCompactStat("Completamento", "${(totalVoters > 0 ? (totalVotesAssigned / totalVoters * 100) : 0).toStringAsFixed(1)}%"),
              ]
          )
      );
  }

  static pw.Widget _buildCompactStat(String label, String value) {
      return pw.Column(
          children: [
              pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
              pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey500)),
          ]
      );
  }

  static pw.Widget _buildBarChart(List<Candidate> candidates, int totalVotes) {
    if (candidates.isEmpty) return pw.Container();
    final maxVotes = candidates.isEmpty ? 10 : candidates.map((c) => c.votes).reduce((a, b) => a > b ? a : b);
    final scale = maxVotes > 0 ? 100.0 / maxVotes : 0.0; // Reduced width to fit in column

    return pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey200),
            borderRadius: pw.BorderRadius.circular(8)
        ),
        padding: const pw.EdgeInsets.all(10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Classifica', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),
            pw.SizedBox(height: 5),
            ...candidates.map((c) {
              final barWidth = c.votes * scale;
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(c.name, style: const pw.TextStyle(fontSize: 9), maxLines: 1, overflow: pw.TextOverflow.clip),
                    ),
                    pw.Expanded(
                        flex: 7,
                        child: pw.Row(
                            children: [
                                pw.Container(
                                  width: barWidth > 0 ? barWidth : 1, 
                                  height: 8,
                                  decoration: pw.BoxDecoration(
                                    color: PdfColor.fromInt(c.color.toARGB32()),
                                    borderRadius: pw.BorderRadius.circular(2)
                                  ),
                                ),
                                pw.SizedBox(width: 4),
                                pw.Text('${c.votes}', style: const pw.TextStyle(fontSize: 8)),
                            ]
                        )
                    )
                  ],
                ),
              );
            }).toList(),
          ],
        )
    );
  }

  static pw.Widget _buildHistoryChart(
      Map<int, Map<String, int>> historyPoints, List<Candidate> candidates) {
    if (historyPoints.length < 2) return pw.Container(height: 200, child: pw.Center(child: pw.Text("Dati non sufficienti per il grafico")));

    final sortedKeys = historyPoints.keys.toList()..sort();
    
    final validCandidates = candidates.where((c) => c.name != AppStrings.blankVotes && c.name != AppStrings.nullVotes);
    
    final datasets = <pw.Dataset>[];
    for(var c in validCandidates) {
         final data = <pw.PointChartValue>[];
         for(var x in sortedKeys) {
             final y = historyPoints[x]?[c.name] ?? 0;
             data.add(pw.PointChartValue(x.toDouble(), y.toDouble()));
         }
         datasets.add(pw.LineDataSet(
             data: data,
             color: PdfColor.fromInt(c.color.toARGB32()),
             pointSize: 1,
             isCurved: true, 
             lineWidth: 1.5,
         ));
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
            border: pw.Border.all(color: PdfColors.grey200),
            borderRadius: pw.BorderRadius.circular(8)
        ),
        padding: const pw.EdgeInsets.all(12),
        height: 250, // Fixed height for alignment
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
                pw.Text('Andamento Voti', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
                pw.Expanded(
                    child: pw.Chart(
                        grid: pw.CartesianGrid(
                            xAxis: pw.FixedAxis(xAxisLabels, textStyle: const pw.TextStyle(fontSize: 8)),
                            yAxis: pw.FixedAxis(yAxisSteps, textStyle: const pw.TextStyle(fontSize: 8)),
                        ),
                        datasets: datasets,
                    )
                )
            ]
        )
    );
  }
  
  static pw.Widget _buildDonutChart(List<Candidate> candidates, int totalVotes) {
       if (totalVotes == 0) return pw.Container();
       final validCandidates = candidates.where((c) => c.votes > 0).toList();
       
       return pw.Container(
           height: 120,
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
                                           innerRadius: 25, // DONUT EFFECT
                                           legend: null 
                                       );
                                   }).toList()
                               ),
                               pw.Column(
                                   mainAxisSize: pw.MainAxisSize.min,
                                   children: [
                                       pw.Text("$totalVotes", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                       pw.Text("voti", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey))
                                   ]
                               )
                           ]
                       )
                   ),
                   pw.SizedBox(width: 10),
                   pw.Column(
                       mainAxisAlignment: pw.MainAxisAlignment.center,
                       crossAxisAlignment: pw.CrossAxisAlignment.start,
                       children: validCandidates.take(5).map((c) => 
                           pw.Padding(
                               padding: const pw.EdgeInsets.only(bottom: 2),
                               child: pw.Row(
                                   children: [
                                       pw.Container(width: 8, height: 8, color: PdfColor.fromInt(c.color.toARGB32())),
                                       pw.SizedBox(width: 4),
                                       pw.Text("${c.getPercentage(totalVotes).toStringAsFixed(1)}%", style: const pw.TextStyle(fontSize: 8))
                                   ]
                               )
                           )
                       ).toList()
                   )
               ]
           )
       );
  }

  static pw.Widget _buildCompactTable(List<Candidate> candidates, int totalVotes) {
    return pw.TableHelper.fromTextArray(
      headers: ['POS', 'CANDIDATO', 'VOTI', '%', 'STATUS'],
      data: candidates.asMap().entries.map((entry) {
        final c = entry.value;
        final index = entry.key + 1;
        return [
          '$index',
          c.name,
          '${c.votes}',
          '${c.getPercentage(totalVotes).toStringAsFixed(1)}%',
          (index == 1) ? 'LEADER' : '' 
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellHeight: 20,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
        padding: const pw.EdgeInsets.only(top: 10),
        decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))
        ),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
                pw.Text('Generato con Voto Tracker Pro', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                pw.Text('Pagina 1 di 1', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            ]
        )
    );
  }
}
