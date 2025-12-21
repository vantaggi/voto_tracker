import 'package:flutter/material.dart';
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCard),
        side: BorderSide(color: candidate.color.withValues(alpha: 0.5), width: 1),
      ),
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
            const SizedBox(height: 16),
            Text(
              '${candidate.votes}',
              style: theme.textTheme.displayMedium
                  ?.copyWith(color: candidate.color, fontWeight: FontWeight.bold),
            ),
            Text(AppStrings.votes, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildVoteButton(
                    context: context,
                    icon: Icons.remove,
                    onPressed: () {
                        context.read<ScrutinyProvider>().vote(index, increment: false);
                    },
                    color: Colors.red.shade400),
                const SizedBox(width: 24),
                _buildVoteButton(
                    context: context,
                    icon: Icons.add,
                    onPressed: () {
                         context.read<ScrutinyProvider>().vote(index, increment: true);
                    },
                    color: Colors.green.shade600),
              ],
            ),
          ],
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
    final controller = TextEditingController(text: candidate.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.editName),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: AppStrings.candidateName,
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ScrutinyProvider>().renameCandidate(index, controller.text);
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
