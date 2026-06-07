import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Esportazione dei risultati grezzi (CSV / JSON) via condivisione di file.
///
/// I dati provengono da `ScrutinyProvider.exportToCsv()` / `exportToJson()`:
/// questo servizio si limita a serializzarli su file temporaneo e a condividerli.
class DataExportService {
  /// Condivide i risultati in formato CSV.
  static Future<bool> shareCsv(String csv) {
    return _shareString(csv, 'scrutinio_risultati.csv', 'text/csv');
  }

  /// Condivide i risultati in formato JSON (indentato e leggibile).
  static Future<bool> shareJson(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return _shareString(
        encoder.convert(data), 'scrutinio_risultati.json', 'application/json');
  }

  static Future<bool> _shareString(
      String content, String filename, String mimeType) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        text: 'Voto Tracker — risultati scrutinio',
      );
      return true;
    } catch (e) {
      debugPrint("Error exporting data ($filename): $e");
      return false;
    }
  }
}
