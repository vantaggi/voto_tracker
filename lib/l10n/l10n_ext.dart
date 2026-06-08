import 'package:flutter/widgets.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';

/// Scorciatoia per accedere alle stringhe localizzate: `context.l10n.save`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Nome da mostrare per un candidato: i candidati reali usano il nome (dato
/// editabile), le schede tecniche usano l'etichetta localizzata.
String localizedCandidateName(AppLocalizations l10n, Candidate c) {
  switch (c.type) {
    case CandidateType.normal:
      return c.name;
    case CandidateType.blank:
      return l10n.blankVotes;
    case CandidateType.spoiled:
      return l10n.spoiledVotes;
  }
}

/// Etichetta localizzata dello stato del vincitore (null se non c'è esito).
String? localizedWinnerLabel(AppLocalizations l10n, WinnerStatus status) {
  switch (status) {
    case WinnerStatus.none:
      return null;
    case WinnerStatus.elected:
      return l10n.winnerElected;
    case WinnerStatus.mathematical:
      return l10n.winnerMathematical;
    case WinnerStatus.tie:
      return l10n.finalResult;
  }
}
