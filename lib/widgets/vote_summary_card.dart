import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/export_sheet.dart';
import 'package:voto_tracker/widgets/vote_stacked_bar.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Riepilogo in cima alla Home (R2): chi è in testa (o l'esito), barra con i
/// colori dei candidati, schede contate e rimanenti.
///
/// Stati: nessuna scheda, in corso, esito (eletto, vittoria matematica,
/// pareggio, ballottaggio, quorum non raggiunto). Tutti hanno la stessa
/// struttura e la stessa altezza: due righe di testo da una riga ciascuna, la
/// barra e la riga dei numeri, dove a scrutinio completo "Condividi" prende il
/// posto delle schede rimanenti. Così la lista sotto non si sposta mai mentre
/// si vota e il + resta sotto il dito (FIX-014, FIX-015).
class VoteSummaryCard extends StatelessWidget {
  const VoteSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _CountingSummary(provider: context.watch<ScrutinyProvider>());
  }
}

class _CountingSummary extends StatelessWidget {
  const _CountingSummary({required this.provider});

  final ScrutinyProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final outcome = provider.hasWinner;
    final inconclusive = provider.isInconclusive;
    final background = !outcome
        ? cs.surfaceContainerHigh
        : inconclusive
        ? cs.tertiaryContainer
        : cs.primaryContainer;
    final onBackground = !outcome
        ? cs.onSurface
        : inconclusive
        ? cs.onTertiaryContainer
        : cs.onPrimaryContainer;
    final secondary = outcome ? onBackground : cs.onSurfaceVariant;
    final completed = provider.remainingVotes <= 0;

    final big = tt.headlineSmall?.copyWith(
      color: onBackground,
      fontWeight: FontWeight.bold,
    );
    final small = outcome
        ? tt.labelLarge?.copyWith(color: onBackground, letterSpacing: 1.2)
        : tt.bodyMedium?.copyWith(color: secondary);
    final (:headline, :detail) = _texts(context);
    final headlineText = _OneLine(headline, style: big);
    final detailText = _OneLine(detail, style: small);

    return Card.filled(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Semantics(
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // L'esito ha l'etichetta sopra ("ELETTO" e il nome); durante lo
              // scrutinio la riga grande è chi è in testa e sotto quanto manca.
              if (outcome) ...[
                detailText,
                headlineText,
              ] else ...[
                headlineText,
                detailText,
              ],
              const SizedBox(height: AppSpacing.m),
              _StackedBar(provider: provider),
              const SizedBox(height: AppSpacing.s),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppDimensions.summaryNumbersRow,
                ),
                // Una riga sola anche col testo grande: se andasse a capo il
                // riepilogo cambierebbe altezza a ogni voto.
                child: LayoutBuilder(
                  builder: (context, constraints) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${provider.totalVotesAssigned} ',
                                style: tt.headlineSmall?.copyWith(
                                  color: onBackground,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: _tabular,
                                ),
                              ),
                              TextSpan(
                                text: l10n.summaryOfTotal(
                                  provider.settings.totalVoters,
                                ),
                                style: tt.bodyLarge?.copyWith(color: secondary),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.55,
                        ),
                        child: completed
                            ? FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: cs.surface,
                                  foregroundColor: cs.primary,
                                ),
                                onPressed: () => showExportSheet(context),
                                icon: const Icon(Icons.ios_share),
                                label: Text(
                                  l10n.shareResults,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Text(
                                l10n.summaryRemaining(provider.remainingVotes),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodyLarge?.copyWith(
                                  color: secondary,
                                  fontFeatures: _tabular,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Riga grande e riga piccola del riepilogo, secondo lo stato.
  ({String headline, String detail}) _texts(BuildContext context) {
    final l10n = context.l10n;
    if (provider.hasWinner) {
      return (
        headline: localizedOutcomeHeadline(
          l10n,
          provider.winnerStatus,
          provider.winnerName,
        ),
        detail: localizedWinnerLabel(l10n, provider.winnerStatus) ?? '',
      );
    }
    // Tutti quelli col massimo dei voti: il rank a parità segue l'ordine di
    // inserimento, quindi da solo non vede i pareggi in testa.
    final real = provider.candidates.where((c) => !c.isTechnical);
    final top = real.fold(0, (m, c) => c.votes > m ? c.votes : m);
    final leaders = [
      for (final c in real)
        if (top > 0 && c.votes == top) c,
    ];
    if (leaders.isEmpty) {
      return (headline: l10n.summaryEmptyTitle, detail: l10n.summaryEmptyHint);
    }
    final toWin = provider.votesUntilMajority;
    return (
      headline: leaders.length == 1
          ? l10n.summaryLeading(leaders.first.name)
          : l10n.summaryLeadingTie,
      detail: toWin != null && toWin > 0 ? l10n.votesToWin(toWin) : '',
    );
  }
}

/// Testo su una sola riga che occupa sempre la stessa altezza, anche vuoto:
/// i cambi di testo non cambiano l'altezza del riepilogo.
class _OneLine extends StatelessWidget {
  const _OneLine(this.text, {required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      // Uno spazio non separabile tiene l'altezza della riga se il testo è
      // vuoto.
      text.isEmpty ? '\u00A0' : text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Barra impilata del riepilogo: candidati in classifica, poi bianche e
/// nulle, su tutte le schede attese.
class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.provider});

  final ScrutinyProvider provider;

  @override
  Widget build(BuildContext context) {
    return VoteStackedBar(
      total: provider.settings.totalVoters,
      segments: [
        for (final c in <Candidate>[
          ...provider.sortedCandidates.where((c) => !c.isTechnical),
          ...provider.candidates.where((c) => c.isTechnical),
        ])
          (color: c.color, votes: c.votes),
      ],
    );
  }
}
