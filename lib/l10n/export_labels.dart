import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Etichette localizzate per le superfici di export (PDF, immagine social) che
/// girano **fuori** dall'albero dei widget e quindi non hanno `BuildContext`.
/// Si costruisce da `AppLocalizations` (in un punto che ha il context) e si passa
/// al servizio.
class ExportLabels {
  final String appTitlePro;
  final String reportSubtitle;
  final String winnerFallback;
  final String countedVotes;
  final String remaining;
  final String completion;
  final String ranking;
  final String trend;
  final String insufficientData;
  final String completionShort;
  final String colPosition;
  final String colCandidate;
  final String colVotes;
  final String colStatus;
  final String leader;
  final String generatedWithPro;
  final String pageFooter;
  final String updateLabel;
  final String liveScrutiny;
  final String partialRanking;
  final String generatedWith;
  final String countedShort;
  final String tie;
  final String blankVotes;
  final String spoiledVotes;

  const ExportLabels({
    required this.appTitlePro,
    required this.reportSubtitle,
    required this.winnerFallback,
    required this.countedVotes,
    required this.remaining,
    required this.completion,
    required this.ranking,
    required this.trend,
    required this.insufficientData,
    required this.completionShort,
    required this.colPosition,
    required this.colCandidate,
    required this.colVotes,
    required this.colStatus,
    required this.leader,
    required this.generatedWithPro,
    required this.pageFooter,
    required this.updateLabel,
    required this.liveScrutiny,
    required this.partialRanking,
    required this.generatedWith,
    required this.countedShort,
    required this.tie,
    required this.blankVotes,
    required this.spoiledVotes,
  });

  factory ExportLabels.of(AppLocalizations l10n) => ExportLabels(
        appTitlePro: AppStrings.appTitlePro,
        reportSubtitle: l10n.reportSubtitle,
        winnerFallback: l10n.winnerFallback,
        countedVotes: l10n.scrutinisedVotes,
        remaining: l10n.remaining,
        completion: l10n.completion,
        ranking: l10n.rankingTitle,
        trend: l10n.trendTitle,
        insufficientData: l10n.insufficientData,
        completionShort: l10n.completionShort,
        colPosition: l10n.colPosition,
        colCandidate: l10n.colCandidate,
        colVotes: l10n.votesShort,
        colStatus: l10n.colStatus,
        leader: l10n.leader,
        generatedWithPro: l10n.generatedWithPro,
        pageFooter: l10n.pageFooter,
        updateLabel: l10n.updateLabel,
        liveScrutiny: l10n.liveScrutiny,
        partialRanking: l10n.partialRanking,
        generatedWith: l10n.generatedWith,
        countedShort: l10n.countedShort,
        tie: l10n.tie,
        blankVotes: l10n.blankVotes,
        spoiledVotes: l10n.spoiledVotes,
      );

  /// Nome da mostrare per un candidato nelle esportazioni.
  String nameOf(Candidate c) {
    switch (c.type) {
      case CandidateType.normal:
        return c.name;
      case CandidateType.blank:
        return blankVotes;
      case CandidateType.spoiled:
        return spoiledVotes;
    }
  }
}
