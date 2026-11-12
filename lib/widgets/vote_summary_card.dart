import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_actions.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/export_sheet.dart';
import 'package:voto_tracker/widgets/vote_stacked_bar.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Riepilogo in cima alla Home (R2): barra con i colori dei candidati,
/// schede contate e rimanenti, chi è in testa.
///
/// Tre stati: nessuna scheda (spiega cosa fare), in corso, esito (eletto,
/// vittoria matematica, pareggio, ballottaggio, quorum non raggiunto).
class VoteSummaryCard extends StatelessWidget {
  const VoteSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    if (provider.totalVotesAssigned == 0 && !provider.canRedo) {
      return const _EmptySummary();
    }
    return _CountingSummary(provider: provider);
  }
}

class _EmptySummary extends StatelessWidget {
  const _EmptySummary();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final real = provider.candidates.where((c) => !c.isTechnical).length;
    return Card.filled(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.summaryEmptyTitle, style: tt.titleLarge),
            const SizedBox(height: AppSpacing.s),
            Text(
              l10n.summaryEmptyBody(real, provider.settings.totalVoters),
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),
            Wrap(
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.s,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => HomeActions.openSettings(context),
                  icon: const Icon(Icons.tune),
                  label: Text(l10n.summarySetup),
                ),
                FilledButton.icon(
                  onPressed: () => HomeActions.openBallotReading(context),
                  icon: const Icon(Icons.ballot_outlined),
                  label: Text(l10n.ballotReadingTitle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

    return Card.filled(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Semantics(
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (outcome) ...[
                Text(
                  localizedWinnerLabel(l10n, provider.winnerStatus) ?? '',
                  style: tt.labelLarge?.copyWith(
                    color: onBackground,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  localizedOutcomeHeadline(
                    l10n,
                    provider.winnerStatus,
                    provider.winnerName,
                  ),
                  style: tt.headlineMedium?.copyWith(
                    color: onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              _StackedBar(provider: provider),
              const SizedBox(height: AppSpacing.m),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: AppSpacing.l,
                  children: [
                    Text.rich(
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
                    ),
                    Text(
                      completed
                          ? l10n.summaryCompleted
                          : l10n.summaryRemaining(provider.remainingVotes),
                      style: tt.bodyLarge?.copyWith(
                        color: secondary,
                        fontFeatures: _tabular,
                      ),
                    ),
                  ],
                ),
              ),
              if (!outcome) ..._leader(context),
              if (completed) ...[
                const SizedBox(height: AppSpacing.l),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.surface,
                    foregroundColor: cs.primary,
                  ),
                  onPressed: () => showExportSheet(context),
                  icon: const Icon(Icons.ios_share),
                  label: Text(l10n.shareResults),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// "In testa X" (o "Pareggio in testa") e i voti che mancano alla vittoria.
  List<Widget> _leader(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final leaders = [
      for (final c in provider.candidates)
        if (!c.isTechnical && c.rank == 1 && c.votes > 0) c,
    ];
    if (leaders.isEmpty) return const [];
    final toWin = provider.votesUntilMajority;
    return [
      const SizedBox(height: AppSpacing.s),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.emoji_events_outlined, size: 18, color: cs.primary),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              [
                leaders.length == 1
                    ? l10n.summaryLeading(leaders.first.name)
                    : l10n.summaryLeadingTie,
                if (toWin != null && toWin > 0) l10n.votesToWin(toWin),
              ].join(' · '),
              style: tt.bodyMedium,
            ),
          ),
        ],
      ),
    ];
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
