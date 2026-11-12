import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;
import 'package:intl/intl.dart' show DateFormat, Intl, NumberFormat;

/// Formattazione comune di immagine, PDF, CSV e grafici (C1): date, decimali
/// e variazioni nel formato della lingua dell'app. Non dipende da Flutter.
class ExportFormat {
  ExportFormat(String locale)
    : locale = Intl.canonicalizedLocale(locale),
      _number = NumberFormat('0.0', Intl.canonicalizedLocale(locale));

  /// Prepara i dati delle date per [locale] (serve fuori dall'app, nei test
  /// e nei servizi; nell'app li carica già la localizzazione di Material).
  static Future<ExportFormat> load(String locale) async {
    await initializeDateFormatting(Intl.canonicalizedLocale(locale));
    return ExportFormat(locale);
  }

  final String locale;
  final NumberFormat _number;

  /// La lingua scrive i decimali con la virgola (italiano): il CSV usa
  /// allora il punto e virgola come separatore, come Excel.
  bool get decimalComma => _number.symbols.DECIMAL_SEP == ',';

  /// Una cifra decimale, senza separatore delle migliaia: "40,0".
  String decimal(double value) => _number.format(_round(value));

  /// "40,0%".
  String percent(double value) => '${decimal(value)}%';

  /// Variazione in punti con il segno: "+6,7", "−5,0", "0,0".
  String signedPoints(double delta) {
    final r = _round(delta);
    if (r == 0) return decimal(0);
    return '${r > 0 ? '+' : '−'}${decimal(r.abs())}';
  }

  /// "12 novembre 2026, 10:28".
  String dateTime(DateTime d) =>
      '${DateFormat.yMMMMd(locale).format(d)}, ${DateFormat.Hm(locale).format(d)}';

  /// "12 nov 2026 · 10:28".
  String shortDateTime(DateTime d) =>
      '${DateFormat.yMMMd(locale).format(d)} · ${DateFormat.Hm(locale).format(d)}';

  /// "12 nov 2026".
  String mediumDate(DateTime d) => DateFormat.yMMMd(locale).format(d);

  static double _round(double v) => (v * 10).roundToDouble() / 10;

  /// Nome del file da condividere: "Consiglio di classe 3B - 2026-11-12.csv".
  /// I caratteri che i file system non accettano diventano trattini.
  static String fileName(String title, DateTime date, String extension) {
    var clean = title
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // Niente punti in fondo (Windows) né nomi lunghissimi.
    clean = clean.replaceAll(RegExp(r'[. ]+$'), '');
    if (clean.length > 80) clean = clean.substring(0, 80).trim();
    if (clean.isEmpty) clean = 'Voto Tracker';
    final day =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return '$clean - $day.$extension';
  }
}
