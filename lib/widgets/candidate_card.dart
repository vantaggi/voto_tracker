import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/trend_colors.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class CandidateCard extends StatelessWidget {
  final int index;
  final Candidate candidate;

  const CandidateCard({
    super.key,
    required this.index,
    required this.candidate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final trend = TrendColors.of(context);
    final name = localizedCandidateName(l10n, candidate);

    final provider = context.watch<ScrutinyProvider>();
    final totalVotes = provider.totalVotesAssigned;
    final currentPercentage = candidate.getPercentage(totalVotes);
    final previousPercentage = candidate.previousPercentage;
    double? delta;
    if (previousPercentage != null) {
      delta = currentPercentage - previousPercentage;
    }

    return Card(
      clipBehavior: Clip.hardEdge, // Ensure ripple respects rounded corners
      child: InkWell(
        onLongPress: () => _showEditNameDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingAll),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Rank Badge
                        if (candidate.rank > 0 && candidate.votes > 0)
                          Container(
                            margin: const EdgeInsets.only(right: AppSpacing.m),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.m,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: candidate.rank == 1
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                AppShapes.medium,
                              ), // Pill shape
                            ),
                            child: Text(
                              "#${candidate.rank}",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: candidate.rank == 1
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: candidate.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Text(
                            localizedCandidateName(l10n, candidate),
                            style: theme.textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditNameDialog(context),
                    tooltip: l10n.editName,
                    style: IconButton.styleFrom(
                      minimumSize: const Size.square(AppTouch.minTarget),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Semantics(
                label: l10n.candidateVotesSemantics(name, candidate.votes),
                excludeSemantics: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${candidate.votes}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      l10n.votes,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Swing Analysis Display
              if (delta != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.s,
                    top: AppSpacing.xs,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: (delta >= 0 ? trend.positive : trend.negative)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppShapes.small),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          delta >= 0 ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: delta >= 0 ? trend.positive : trend.negative,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${delta >= 0 ? "+" : ""}${delta.toStringAsFixed(1)}%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: delta >= 0 ? trend.positive : trend.negative,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '(vs ${previousPercentage!.toStringAsFixed(1)}%)',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.l),
              // Action Buttons - Using M3 styles
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrease Button
                  FilledButton.tonal(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.read<ScrutinyProvider>().vote(
                        index,
                        increment: false,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.onErrorContainer,
                      minimumSize: const Size(56, 56), // Larger touch target
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(), // Circular buttons for +/-
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 28,
                      semanticLabel: l10n.removeVoteFor(name),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xxl),

                  // Increase Button - Filled (High emphasis)
                  FilledButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.read<ScrutinyProvider>().vote(
                        index,
                        increment: true,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary, // Or custom green
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(72, 72), // Prominent Main Action
                      padding: EdgeInsets.zero,
                      elevation: 2,
                      shape: const CircleBorder(), // Circular buttons for +/-
                    ),
                    child: Icon(
                      Icons.add,
                      size: 36,
                      semanticLabel: l10n.addVoteFor(name),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final nameController = TextEditingController(text: candidate.name);
    final prevController = TextEditingController(
      text: candidate.previousPercentage?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.editName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.candidateName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.l),
              TextField(
                controller: prevController,
                decoration: InputDecoration(
                  labelText: l10n.previousResultLabel,
                  suffixText: "%",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.percent),
                  hintText: l10n.previousResultHint,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final provider = context.read<ScrutinyProvider>();
                  provider.renameCandidate(index, nameController.text);

                  if (prevController.text.isNotEmpty) {
                    final val = double.tryParse(
                      prevController.text.replaceAll(',', '.'),
                    );
                    provider.setCandidatePreviousPercentage(index, val);
                  } else {
                    provider.setCandidatePreviousPercentage(index, null);
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      prevController.dispose();
    });
  }
}
