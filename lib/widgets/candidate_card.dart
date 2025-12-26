import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:flutter/services.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class CandidateCard extends StatelessWidget {
  final int index;
  final Candidate candidate;

  const CandidateCard(
      {super.key, required this.index, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ScrutinyProvider>();
    final totalVotes = provider.totalVotesAssigned;
    final currentPercentage = candidate.getPercentage(totalVotes);
    final previousPercentage = candidate.previousPercentage;
    double? delta;
    if (previousPercentage != null) {
      delta = currentPercentage - previousPercentage;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCard),
        side: BorderSide(color: candidate.color.withValues(alpha: 0.5), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCard),
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
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: candidate.rank == 1 ? Colors.amber : Colors.grey.shade200,
                                shape: BoxShape.circle,
                            ),
                            child: Text(
                                "${candidate.rank}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: candidate.rank == 1 ? Colors.white : Colors.black
                                )
                            )
                        ),
                        Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                                color: candidate.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                            candidate.name,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                            ),
                        ),
                        ],
                    ),
                    ),
                    IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditNameDialog(context),
                    tooltip: AppStrings.editName,
                    ),
                ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                     Text(
                        '${candidate.votes}',
                        style: theme.textTheme.displayMedium
                            ?.copyWith(color: candidate.color, fontWeight: FontWeight.bold),
                     ),
                     const SizedBox(width: 4),
                     Text(AppStrings.votes, style: theme.textTheme.bodyMedium),
                  ]
                ),
                 // Swing Analysis Display
                if (delta != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        delta >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: delta >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${delta >= 0 ? "+" : ""}${delta.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: delta >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                         '(vs ${previousPercentage!.toStringAsFixed(1)}%)',
                         style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 10),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    _buildVoteButton(
                        context: context,
                        icon: Icons.remove,
                        onPressed: () {
                            HapticFeedback.selectionClick();
                            context.read<ScrutinyProvider>().vote(index, increment: false);
                        },
                        color: Colors.red.shade400),
                    const SizedBox(width: 24),
                    _buildVoteButton(
                        context: context,
                        icon: Icons.add,
                        onPressed: () {
                             HapticFeedback.selectionClick();
                             context.read<ScrutinyProvider>().vote(index, increment: true);
                        },
                        color: Colors.green.shade600),
                ],
                ),
            ],
            ),
        ),
      ),
    );
  }

  Widget _buildVoteButton(
      {required BuildContext context,
      required IconData icon,
      required VoidCallback onPressed,
      required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: color,
        iconSize: 32,
        onPressed: onPressed,
        splashRadius: 28,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontWeight: FontWeight.bold)),
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
