import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voto_tracker/models/scrutiny.dart';

/// File dell'archivio non valido (altra app, formato sconosciuto, JSON rotto).
class ArchiveFormatException implements Exception {
  const ArchiveFormatException(this.reason);
  final String reason;

  @override
  String toString() => 'ArchiveFormatException: $reason';
}

/// Esporta e importa l'archivio degli scrutini in un file JSON (P7, FEAT-004),
/// per backup e cambio telefono. L'import non scrive niente: restituisce gli
/// scrutini letti e li aggiunge il provider, dopo la conferma dell'utente.
class ArchiveTransferService {
  static const String appId = 'voto_tracker';
  static const int format = 1;

  /// Contenuto del file: `{app, format, exportedAt, scrutinies: [...]}`.
  static String encode(List<Scrutiny> items, DateTime now) =>
      const JsonEncoder.withIndent('  ')
          .convert(envelope([for (final s in items) s.toJson()], now));

  /// Involucro del file con gli scrutini già in JSON (lo usa anche
  /// l'esportazione JSON dei risultati, che aggiunge il blocco `results`).
  static Map<String, dynamic> envelope(
    List<Map<String, dynamic>> scrutinies,
    DateTime now,
  ) => {
    'app': appId,
    'format': format,
    'exportedAt': now.toUtc().toIso8601String(),
    'scrutinies': scrutinies,
  };

  /// Legge un file prodotto da [encode]. Lancia [ArchiveFormatException] se
  /// il file non è un archivio di Voto Tracker leggibile.
  static List<Scrutiny> decode(String content) {
    final Object? data;
    try {
      data = jsonDecode(content);
    } on FormatException {
      throw const ArchiveFormatException('json');
    }
    if (data is! Map || data['app'] != appId) {
      throw const ArchiveFormatException('app');
    }
    if (data['format'] != format) {
      throw const ArchiveFormatException('format');
    }
    final list = data['scrutinies'];
    if (list is! List) throw const ArchiveFormatException('scrutinies');
    try {
      return [
        for (final e in list) Scrutiny.fromJson(Map<String, dynamic>.from(e)),
      ];
    } catch (_) {
      throw const ArchiveFormatException('scrutiny');
    }
  }

  /// Nome del file: `voto_tracker_archivio_AAAA-MM-GG.json`.
  static String fileName(DateTime now) =>
      'voto_tracker_archivio_${now.toIso8601String().substring(0, 10)}.json';

  /// Scrive il file e apre il menu Condividi. `false` se qualcosa fallisce.
  static Future<bool> share(List<Scrutiny> items) async {
    try {
      final now = DateTime.now();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${fileName(now)}');
      await file.writeAsString(encode(items, now));
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          text: 'Voto Tracker — archivio scrutini',
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Errore esportazione archivio: $e');
      return false;
    }
  }

  /// Fa scegliere un file all'utente e lo legge. `null` se annulla.
  /// Lancia [ArchiveFormatException] se il file non è valido.
  static Future<List<Scrutiny>?> pick() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (picked == null) return null;
    // readAsBytes funziona anche con gli URI content:// di Android.
    return decode(utf8.decode(await picked.readAsBytes()));
  }
}
