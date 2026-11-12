import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/export_format.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/services/data_export_service.dart';
import 'package:voto_tracker/services/pdf_export_service.dart';
import 'package:voto_tracker/services/pdf_palette.dart';
import 'package:voto_tracker/services/results_snapshot.dart';
import 'package:voto_tracker/services/social_share_service.dart';
import 'package:voto_tracker/theme/app_theme.dart';

/// Unico punto che prepara lo stato corrente per gli export (PNG, PDF, CSV,
/// JSON): una sola [ResultsSnapshot] con testi e formati della lingua.
class ExportController {
  ExportController(
    this._provider,
    this._l10n, {
    PdfPalette? palette,
    AppThemes? themes,
    DateTime Function()? clock,
  }) : palette = palette ?? PdfPalette.brand,
       _themes = themes ?? AppThemes.brand,
       _clock = clock ?? DateTime.now;

  final ScrutinyProvider _provider;
  final AppLocalizations _l10n;
  final AppThemes _themes;
  final DateTime Function() _clock;

  /// Colori del PDF: lo schema chiaro dell'app (colore dinamico compreso).
  final PdfPalette palette;

  Future<(ResultsSnapshot, ExportFormat)> snapshot() async {
    final format = await ExportFormat.load(_l10n.localeName);
    return (
      ResultsSnapshot.fromProvider(_provider, _l10n, format, at: _clock()),
      format,
    );
  }

  /// `false` se la condivisione è fallita (vale per tutti i metodi).
  Future<bool> shareImage() async {
    final (s, f) = await snapshot();
    return SocialShareService.shareResults(
      snapshot: s,
      l10n: _l10n,
      format: f,
      theme: _themes.dark,
    );
  }

  Future<bool> exportPdf() async {
    final (s, f) = await snapshot();
    try {
      return await PdfExportService.share(
        snapshot: s,
        l10n: _l10n,
        format: f,
        palette: palette,
      );
    } catch (e) {
      debugPrint('Errore PDF: $e');
      return false;
    }
  }

  Future<bool> shareCsv() async {
    final (s, f) = await snapshot();
    return DataExportService.share(
      content: DataExportService.csv(s, _l10n, f),
      fileName: ExportFormat.fileName(s.title, s.at, 'csv'),
      mimeType: 'text/csv',
      text: _l10n.exportShareText(s.title),
    );
  }

  Future<bool> shareJson() async {
    final (s, _) = await snapshot();
    return DataExportService.share(
      content: DataExportService.json(s, s.at),
      fileName: ExportFormat.fileName(s.title, s.at, 'json'),
      mimeType: 'application/json',
      text: _l10n.exportShareText(s.title),
    );
  }
}
