import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/l10n/export_labels.dart';
import 'package:voto_tracker/models/candidate.dart';

class SocialResultsCard extends StatelessWidget {
  final List<Candidate> candidates;
  final int totalVotes;
  final int totalVoters;
  final int remainingVotes;
  final ExportLabels labels;
  final String? winner;
  final String? winnerLabel;

  const SocialResultsCard({
    super.key,
    required this.candidates,
    required this.totalVotes,
    required this.totalVoters,
    required this.remainingVotes,
    required this.labels,
    this.winner,
    this.winnerLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Top 5 candidates only
    final topCandidates = candidates.take(5).toList();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Explicitly using a dark background for social share images regardless of light/dark theme context
    // But since we are passing AppTheme.darkTheme, we can use theme colors directly.
    return Container(
      width:
          1080 /
          2, // Scaled down for display, will be captured at higher pixel ratio
      height: 1350 / 2, // 4:5 Aspect Ratio (Instagram Portrait)
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        // Subtle gradient overlay for extra polish
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.surface, colorScheme.surfaceContainer],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${labels.updateLabel} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    labels.liveScrutiny,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    "${labels.countedShort}: $totalVotes / $totalVoters (${(totalVotes / (totalVoters == 0 ? 1 : totalVoters) * 100).toStringAsFixed(1)}%)\n${labels.remaining}: $remainingVotes",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.how_to_vote_outlined,
                color: colorScheme.primary.withValues(alpha: 0.5),
                size: 64,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Winner Badge (if present)
          if (winner != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(
                  24,
                ), // M3 Medium/Large shape
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    winnerLabel ?? labels.winnerFallback,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    winner!.toUpperCase(),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // List Header
          if (winner == null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.l),
              child: Text(
                labels.partialRanking,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Candidates List
          Expanded(
            child: Column(
              children: topCandidates.asMap().entries.map((entry) {
                final index = entry.key;
                final c = entry.value;
                final p = c.getPercentage(totalVotes);
                final bool isFirst = index == 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.m),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.m,
                    horizontal: AppSpacing.l,
                  ),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppShapes.large),
                    border: isFirst
                        ? Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.5),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        alignment: Alignment.center,
                        child: Text(
                          "${index + 1}.",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isFirst
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          labels.nameOf(c),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isFirst
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        "${p.toStringAsFixed(1)}%",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.l),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: c.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppShapes.small),
                          border: Border.all(
                            color: c.color.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          "${c.votes}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: c.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(),
          const SizedBox(height: AppSpacing.l),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.s),
                Text(
                  labels.generatedWith,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
