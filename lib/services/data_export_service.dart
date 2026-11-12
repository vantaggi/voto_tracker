import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/export_format.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/services/archive_transfer_service.dart';
import 'package:voto_tracker/services/results_snapshot.dart';

/// Risultati in CSV e JSON (C4). La costruzione del contenuto è pura e
/// testata; [share] scrive il file temporaneo e apre il menu Condividi.
class DataExportService {
  const DataExportService._();

  /// CSV per il foglio di calcolo nella lingua dell'app: in italiano `;` e
  /// virgola decimale (come Excel italiano), in inglese `,` e punto. BOM
  /// UTF-8 per gli accenti, testi tra virgolette, niente righe di totale.
  static String csv(ResultsSnapshot s, AppLocalizations l10n, ExportFormat f) {
    final sep = f.decimalComma ? ';' : ',';
    String number(double? v) => v == null ? '' : f.decimal(v);
    String type(CandidateType t) => switch (t) {
      CandidateType.normal => l10n.csvTypeCandidate,
      CandidateType.blank => l10n.csvTypeBlank,
      CandidateType.spoiled => l10n.csvTypeSpoiled,
    };
    final lines = [
      [
        l10n.csvPosition,
        l10n.csvCandidate,
        l10n.csvType,
        l10n.csvVotes,
        l10n.csvPercent,
        l10n.csvPrevious,
        l10n.csvChange,
      ].map(csvText).join(sep),
      for (final r in s.rows)
        [
          r.rank?.toString() ?? '',
          csvText(r.name),
          csvText(type(r.type)),
          '${r.votes}',
          number(r.percent),
          number(r.previous),
          number(r.change),
        ].join(sep),
    ];
    return '﻿${lines.join('\r\n')}\r\n';
  }

  /// Campo di testo CSV: tra virgolette, virgolette interne raddoppiate.
  /// Un testo che inizia con `= + - @` (o tab, a capo) prende un apostrofo
  /// davanti, così il foglio di calcolo non lo esegue come formula.
  static String csvText(String value) {
    final safe = RegExp(r'^[=+\-@\t\r\n]').hasMatch(value) ? "'$value" : value;
    return '"${safe.replaceAll('"', '""')}"';
  }

  /// JSON nel formato dell'Archivio (si reimporta da "Importa da file"), con
  /// in più il blocco `results` già calcolato per altri programmi.
  static String json(ResultsSnapshot s, DateTime now) {
    final scrutiny = s.scrutiny;
    return const JsonEncoder.withIndent('  ').convert(
      ArchiveTransferService.envelope([
        if (scrutiny != null) {...scrutiny.toJson(), 'results': results(s)},
      ], now),
    );
  }

  /// Risultati calcolati: esito, numeri e righe in ordine di classifica.
  static Map<String, dynamic> results(ResultsSnapshot s) => {
    'title': s.title,
    'complete': s.isComplete,
    'status': s.status.name,
    'winner': s.winnerName,
    'rule': s.rule.name,
    'expectedBallots': s.totalVoters,
    'counted': s.counted,
    'remaining': s.remaining < 0 ? 0 : s.remaining,
    'rows': [
      for (final r in s.rows)
        {
          'rank': r.rank,
          'name': r.name,
          'type': r.type.name,
          'votes': r.votes,
          'percentage': _two(r.percent),
          'previousPercentage': r.previous,
          'change': r.change == null ? null : _two(r.change!),
          'color': hexColor(r.color),
        },
    ],
  };

  static double _two(double v) => (v * 100).roundToDouble() / 100;

  /// "#RRGGBB".
  static String hexColor(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  /// Scrive [content] in un file temporaneo e lo condivide. `false` se
  /// qualcosa fallisce.
  static Future<bool> share({
    required String content,
    required String fileName,
    required String mimeType,
    required String text,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: mimeType)],
          text: text,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Errore esportazione ($fileName): $e');
      return false;
    }
  }
}
