import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/app_theme.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/keep_screen_on.dart';

/// Modalità proiettore: classifica a tutto schermo, tema scuro.
/// P9: una riga parlata per candidato, esito annunciato appena cambia,
/// testo di sistema limitato a 1,5x e nessun overflow sul telefono.
class ProjectorModeScreen extends StatelessWidget {
  const ProjectorModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema scuro sempre: più contrasto nelle stanze buie.
    return KeepScreenOn(
      child: Theme(
        data: context.read<AppThemes>().dark,
        child: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            // I testi sono già enormi: oltre 1,5x uscirebbero dallo schermo.
            return MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.5,
              child: Scaffold(
                backgroundColor: colorScheme.surface,
                appBar: AppBar(
                  title: Text(context.l10n.projectorMode),
                  backgroundColor: Colors.transparent,
                  foregroundColor: colorScheme.onSurfaceVariant,
                  elevation: 0,
                ),
                body: Consumer<ScrutinyProvider>(
                  builder: (context, provider, child) {
                    final candidates = provider.sortedCandidates
                        .where((c) => c.votes > 0)
                        .toList();
                    final totalVotes = provider.totalVotesAssigned;

                    if (candidates.isEmpty) {
                      return Center(
                        child: Text(
                          context.l10n.waitingForData,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    // Il primo è il massimo: la lista è in ordine.
                    final maxVotes = candidates.first.votes;

                    return Column(
                      children: [
                        _buildHeader(context, provider),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final compact =
                                  constraints.maxWidth <
                                  AppDimensions.compactBreakpoint;
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact
                                      ? AppSpacing.l
                                      : AppSpacing.xxl,
                                  vertical: AppSpacing.xl,
                                ),
                                itemCount: candidates.length,
                                itemBuilder: (context, index) => _ProjectorRow(
                                  position: index + 1,
                                  candidate: candidates[index],
                                  totalVotes: totalVotes,
                                  maxVotes: maxVotes,
                                  compact: compact,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ScrutinyProvider provider) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.hasWinner) {
      final label = localizedWinnerLabel(l10n, provider.winnerStatus) ?? '';
      final winnerText = localizedOutcomeHeadline(
        l10n,
        provider.winnerStatus,
        provider.winnerName,
      );

      // P9: l'esito viene annunciato appena cambia.
      return Semantics(
        liveRegion: true,
        container: true,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          width: double.infinity,
          decoration: BoxDecoration(
            color: provider.isInconclusive
                ? colorScheme.tertiaryContainer
                : colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: provider.isInconclusive
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                winnerText.toUpperCase(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: provider.isInconclusive
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.how_to_vote_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.l),
          Flexible(
            child: Text(
              "${l10n.votesTotal}: ${provider.totalVotesAssigned} / ${provider.settings.totalVoters}",
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Una riga della classifica: barra di avanzamento sullo sfondo, posizione,
/// nome, percentuale e voti.
class _ProjectorRow extends StatelessWidget {
  const _ProjectorRow({
    required this.position,
    required this.candidate,
    required this.totalVotes,
    required this.maxVotes,
    required this.compact,
  });

  final int position;
  final Candidate candidate;
  final int totalVotes;
  final int maxVotes;

  /// Telefono in verticale: margini più stretti.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = candidate.getPercentage(totalVotes);
    final progress = maxVotes > 0 ? candidate.votes / maxVotes : 0.0;
    final isFirst = position == 1;
    final name = localizedCandidateName(l10n, candidate);
    final gap = compact ? AppSpacing.l : AppSpacing.xl;

    // TalkBack legge una riga sola; il disegno sotto è escluso.
    return Semantics(
      container: true,
      label: l10n.projectorRowSemantics(
        position,
        name,
        candidate.votes,
        percentage.toStringAsFixed(1),
      ),
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xl),
          // Altezza minima, non fissa: col testo grande la riga cresce.
          constraints: const BoxConstraints(minHeight: 100),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: candidate.color.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(
                        AppShapes.extraLargeCard,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: gap,
                  vertical: AppSpacing.l,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isFirst
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          AppShapes.largeIncreased,
                        ),
                        border: isFirst
                            ? Border.all(color: colorScheme.primary, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$position',
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isFirst
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      flex: 2,
                      child: Text(
                        name.toUpperCase(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Percentuale e voti si rimpiccioliscono invece di uscire
                    // dallo schermo.
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(
                                width: compact ? AppSpacing.l : AppSpacing.xxl,
                              ),
                              Text(
                                '${candidate.votes}',
                                style: textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: candidate.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
