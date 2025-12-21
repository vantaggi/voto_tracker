import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/candidate_card.dart';

class CandidatesSection extends StatelessWidget {
  const CandidatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StatsHeader(),
        Expanded(
          child: Consumer<ScrutinyProvider>(
            builder: (context, provider, child) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingAll),
                itemCount: provider.candidates.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CandidateCard(
                      index: index,
                      candidate: provider.candidates[index],
                    ),
                  );
                },
              );
            },
          ),
        ),
        const ControlButtons(),
      ],
    );
  }
}

class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(builder: (context, provider, child) {
      final theme = Theme.of(context);
      
      // Winner Banner
      if (provider.winner != null) {
          return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: provider.winner == AppStrings.tie ? Colors.orange : Colors.amber,
              child: Column(
                  children: [
                      Text(AppStrings.winner, 
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                      Text(provider.winner!, 
                          style: theme.textTheme.displayMedium?.copyWith(color: Colors.black)),
                  ]
              )
          );
      }
      
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingAll),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, Icons.how_to_vote, AppStrings.scrutinisedVotes, 
                '${provider.totalVotesAssigned} / ${provider.settings.totalVoters}'),
            _buildStatItem(context, Icons.pending, "Rimanenti", 
                '${provider.remainingVotes}'),
          ],
        ),
      );
    });
  }
  
  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
      final theme = Theme.of(context);
      return Column(
          children: [
              Icon(icon, color: theme.colorScheme.primary),
              Text(value, style: theme.textTheme.titleLarge),
              Text(label, style: theme.textTheme.bodySmall),
          ]
      );
  }
}

class ControlButtons extends StatelessWidget {
    const ControlButtons({super.key});
    
    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(AppDimensions.paddingAll),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    IconButton(
                        onPressed: context.watch<ScrutinyProvider>().canUndo ? 
                            () => context.read<ScrutinyProvider>().undo() : null,
                        icon: const Icon(Icons.undo),
                        tooltip: "Undo",
                    ),
                    IconButton(
                        onPressed: context.watch<ScrutinyProvider>().canRedo ? 
                            () => context.read<ScrutinyProvider>().redo() : null,
                        icon: const Icon(Icons.redo),
                        tooltip: "Redo",
                    ),
                    IconButton(
                        onPressed: () => _exportData(context),
                        icon: const Icon(Icons.copy),
                        tooltip: AppStrings.exportData,
                    ),
                    IconButton(
                         icon: const Icon(Icons.refresh),
                         color: Colors.red,
                         tooltip: AppStrings.reset,
                         onPressed: () => _confirmReset(context),
                    )
                ]
            )
        );
    }
    
    void _exportData(BuildContext context) {
        final csv = context.read<ScrutinyProvider>().exportToCsv();
        Clipboard.setData(ClipboardData(text: csv));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.dataCopied))
        );
    }
    
    void _confirmReset(BuildContext context) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text(AppStrings.confirmReset),
                content: const Text(AppStrings.resetConfirmation),
                actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () {
                             context.read<ScrutinyProvider>().reset();
                             Navigator.pop(context);
                        },
                        child: const Text(AppStrings.reset),
                    )
                ]
            )
        );
    }
}
