import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class CandidateCard extends StatelessWidget {
  final int index;
  final Candidate candidate;

  const CandidateCard(
      {super.key, required this.index, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: candidate.rank == 1 
                                  ? colorScheme.primaryContainer 
                                  : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12), // Pill shape
                            ),
                            child: Text(
                                "#${candidate.rank}",
                                style: theme.textTheme.labelLarge?.copyWith(
                                    color: candidate.rank == 1 
                                      ? colorScheme.onPrimaryContainer 
                                      : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                )
                            )
                        ),
                        Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                                color: candidate.color, 
                                shape: BoxShape.circle,
                                border: Border.all(color: colorScheme.outlineVariant, width: 1)
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                            candidate.name,
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
                      tooltip: AppStrings.editName,
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                     Text(
                        '${candidate.votes}',
                        style: theme.textTheme.displayMedium?.copyWith(
                           color: colorScheme.onSurface,
                           fontWeight: FontWeight.w800
                        ),
                     ),
                     const SizedBox(width: 8),
                     Text(
                       AppStrings.votes, 
                       style: theme.textTheme.bodyLarge?.copyWith(
                         color: colorScheme.onSurfaceVariant
                       )
                     ),
                  ]
                ),
                 // Swing Analysis Display
                if (delta != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (delta >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          delta >= 0 ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: delta >= 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${delta >= 0 ? "+" : ""}${delta.toStringAsFixed(1)}%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: delta >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                           '(vs ${previousPercentage!.toStringAsFixed(1)}%)',
                           style: theme.textTheme.labelMedium?.copyWith(
                             color: colorScheme.onSurfaceVariant.withOpacity(0.8)
                           ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // Action Buttons - Using M3 styles
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    // Decrease Button
                    FilledButton.tonal(
                      onPressed: () {
                         HapticFeedback.selectionClick();
                         context.read<ScrutinyProvider>().vote(index, increment: false);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.onErrorContainer,
                        minimumSize: const Size(56, 56), // Larger touch target
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(), // Circular buttons for +/-
                      ),
                      child: const Icon(Icons.remove, size: 28),
                    ),
                    
                    const SizedBox(width: 32),
                    
                    // Increase Button - Filled (High emphasis)
                    FilledButton(
                      onPressed: () {
                          HapticFeedback.selectionClick();
                          context.read<ScrutinyProvider>().vote(index, increment: true);
                      },
                       style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary, // Or custom green
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size(72, 72), // Prominent Main Action
                        padding: EdgeInsets.zero,
                        elevation: 2,
                        shape: const CircleBorder(), // Circular buttons for +/-
                      ),
                      child: const Icon(Icons.add, size: 36),
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
    final prevController = TextEditingController(text: candidate.previousPercentage?.toString() ?? "");
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.editName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: AppStrings.candidateName,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prevController,
                decoration: const InputDecoration(
                    labelText: "Risultato Precedente (%)",
                    suffixText: "%",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                    hintText: "Es. 25.5"
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
          ]
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel, style: Theme.of(context).textTheme.labelLarge),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final provider = context.read<ScrutinyProvider>();
                provider.renameCandidate(index, nameController.text);
                
                if (prevController.text.isNotEmpty) {
                    final val = double.tryParse(prevController.text.replaceAll(',', '.'));
                    provider.setCandidatePreviousPercentage(index, val);
                } else {
                    provider.setCandidatePreviousPercentage(index, null);
                }
                
                Navigator.pop(context);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
