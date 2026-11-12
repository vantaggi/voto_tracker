import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/scrutiny.dart';
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
    case WinnerStatus.noMajority:
    case WinnerStatus.noQuorum:
      return l10n.finalResult;
  }
}

/// Testo grande dell'esito: nome del vincitore, "PAREGGIO", "BALLOTTAGGIO"
/// o "QUORUM NON RAGGIUNTO".
String localizedOutcomeHeadline(
  AppLocalizations l10n,
  WinnerStatus status,
  String? winnerName,
) {
  switch (status) {
    case WinnerStatus.tie:
      return l10n.tie;
    case WinnerStatus.noMajority:
      return l10n.outcomeNoMajority;
    case WinnerStatus.noQuorum:
      return l10n.outcomeNoQuorum;
    case WinnerStatus.none:
    case WinnerStatus.elected:
    case WinnerStatus.mathematical:
      return winnerName ?? '';
  }
}

/// Titolo da mostrare per uno scrutinio: quello scelto dall'utente oppure
/// "Scrutinio del <data di creazione>".
String scrutinyDisplayTitle(BuildContext context, Scrutiny s) {
  final title = s.title;
  if (title != null && title.isNotEmpty) return title;
  final date = MaterialLocalizations.of(context).formatMediumDate(s.createdAt);
  return AppLocalizations.of(context).defaultScrutinyTitle(date);
}

/// Percentuale con una cifra decimale nel formato della lingua ("40,0%" in
/// italiano, "40.0%" in inglese).
String formatPercent(BuildContext context, double value) =>
    '${formatOneDecimal(context, value)}%';

/// Numero con una cifra decimale nel formato della lingua ("40,0").
String formatOneDecimal(BuildContext context, double value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: 1,
  ).format(value);
}
