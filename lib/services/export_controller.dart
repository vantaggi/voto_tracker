import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/export_labels.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/services/data_export_service.dart';
import 'package:voto_tracker/services/pdf_export_service.dart';
import 'package:voto_tracker/services/social_share_service.dart';

/// Unico punto che prepara lo stato corrente per gli export (PNG, PDF, CSV,
/// JSON). I servizi girano fuori dall'albero dei widget: qui si risolvono una
/// volta sola le stringhe localizzate e il vincitore da mostrare.
class ExportController {
  ExportController(this._provider, this._l10n)
    : labels = ExportLabels.of(_l10n);

  final ScrutinyProvider _provider;
  final AppLocalizations _l10n;
  final ExportLabels labels;

  /// Nome mostrato come vincitore: la label di pareggio in caso di parità.
  String? get winnerName => _provider.isTie ? _l10n.tie : _provider.winnerName;

  String? get winnerLabel =>
      localizedWinnerLabel(_l10n, _provider.winnerStatus);

  Future<void> shareImage() => SocialShareService.shareResults(
    candidates: _provider.sortedCandidates,
    totalVotes: _provider.totalVotesAssigned,
    totalVoters: _provider.settings.totalVoters,
    remainingVotes: _provider.remainingVotes,
    labels: labels,
    winner: winnerName,
    winnerLabel: winnerLabel,
  );

  Future<void> exportPdf() => PdfExportService.exportToPdf(
    candidates: _provider.sortedCandidates,
    totalVotesAssigned: _provider.totalVotesAssigned,
    totalVoters: _provider.settings.totalVoters,
    remainingVotes: _provider.remainingVotes,
    historyPoints: _provider.historyPoints,
    labels: labels,
    winner: winnerName,
    winnerLabel: winnerLabel,
  );

  /// `false` se la condivisione è fallita.
  Future<bool> shareCsv() =>
      DataExportService.shareCsv(_provider.exportToCsv());

  /// `false` se la condivisione è fallita.
  Future<bool> shareJson() =>
      DataExportService.shareJson(_provider.exportToJson());
}
