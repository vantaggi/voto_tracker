import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/services/pdf_export_service.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/candidate_card.dart';

class CandidatesSection extends StatelessWidget {
  final bool isScrollable;
  const CandidatesSection({super.key, this.isScrollable = true});

  @override
  Widget build(BuildContext context) {
    // If not scrollable (e.g. inside SingleChildScrollView), we use shrinkWrap and physics NeverScrollable
    return Column(
      children: [
        const StatsHeader(),
        if (isScrollable) 
            Expanded(child: _buildList())
        else 
            _buildList(),
        const ControlButtons(),
      ],
    );
  }

  Widget _buildList() {
      return Consumer<ScrutinyProvider>(
            builder: (context, provider, child) {
              return ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingAll),
                shrinkWrap: !isScrollable,
                physics: isScrollable ? null : const NeverScrollableScrollPhysics(),
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
          );
  }
}

class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(builder: (context, provider, child) {
      final theme = Theme.of(context);
      
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingAll),
        child: Column(
          children: [
            // Winner Banner (Stacked on top if present)
            if (provider.winner != null)
                Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: provider.winner == AppStrings.tie ? Colors.orange : Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2)
                            )
                        ]
                    ),
                    child: Column(
                        children: [
                            Text(AppStrings.winner, 
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                            Text(provider.winner!, 
                                style: theme.textTheme.displayMedium?.copyWith(color: Colors.black)),
                        ]
                    )
                ),

            // ALWAYS Show Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, Icons.how_to_vote, AppStrings.scrutinisedVotes, 
                    '${provider.totalVotesAssigned} / ${provider.settings.totalVoters}'),
                _buildStatItem(context, Icons.pending, "Rimanenti", 
                    '${provider.remainingVotes}'),
              ],
            ),
             const SizedBox(height: 16),
             _buildComparison(context, provider),
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

  Widget _buildComparison(BuildContext context, ScrutinyProvider provider) {
      final validCandidates = provider.candidates
          .where((c) => c.name != AppStrings.blankVotes && c.name != AppStrings.nullVotes)
          .toList();
      
      if (validCandidates.length < 2) {
          return const Text(AppStrings.comparisonNotAvailable, style: TextStyle(color: Colors.grey));
      }

      final first = validCandidates[0];
      final second = validCandidates[1];
      final diff = first.votes - second.votes;

      return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCard),
          ),
          child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                  Text("1° ${first.name}: ${first.votes}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("VS", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  Text("2° ${second.name}: ${second.votes}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text("${AppStrings.advantage}: +$diff", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold))
                  )
              ]
          )
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
                        onPressed: () => _showExportOptions(context),
                        icon: const Icon(Icons.ios_share),
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
    
    void _showExportOptions(BuildContext context) {
        showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        ListTile(
                            leading: const Icon(Icons.table_chart),
                            title: const Text("Copia CSV"),
                            onTap: () {
                                Navigator.pop(context);
                                _exportData(context, isCsv: true);
                            },
                        ),
                        ListTile(
                            leading: const Icon(Icons.code),
                            title: const Text("Copia JSON"),
                            onTap: () {
                                Navigator.pop(context);
                                _exportData(context, isCsv: false);
                            },
                        ),
                        ListTile(
                            leading: const Icon(Icons.picture_as_pdf),
                            title: const Text("Export PDF Report"),
                            onTap: () async {
                                Navigator.pop(context);
                                final provider = context.read<ScrutinyProvider>();
                                try {
                                    await PdfExportService.exportToPdf(
                                        candidates: provider.sortedCandidates,
                                        totalVotesAssigned: provider.totalVotesAssigned,
                                        totalVoters: provider.settings.totalVoters,
                                        remainingVotes: provider.remainingVotes,
                                        historyPoints: provider.historyPoints,
                                        winner: provider.winner,
                                    );
                                } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text("Error: ${e.toString()} - Try restarting the app fully."),
                                            backgroundColor: Colors.red,
                                        )
                                    );
                                }
                            },
                        ),
                    ]
                )
            )
        );
    }

    void _exportData(BuildContext context, {required bool isCsv}) {
        final provider = context.read<ScrutinyProvider>();
        final String data = isCsv ? provider.exportToCsv() : jsonEncode(provider.exportToJson());
        Clipboard.setData(ClipboardData(text: data));
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
                    TextButton(onPressed: () => Navigator.pop(context), 
                        child: Text(AppStrings.cancel, style: Theme.of(context).textTheme.labelLarge)),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, 
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                    showDialog(
                        context: context,
                        builder: (innerContext) => AlertDialog(
                            title: const Text("Conferma Reset"),
                            content: const Text("Sei sicuro di voler cancellare tutti i voti? Questa operazione non può essere annullata."),
                            actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(innerContext),
                                    child: const Text(AppStrings.cancel)
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () {
                                        context.read<ScrutinyProvider>().reset();
                                        Navigator.pop(innerContext); // Pop the inner dialog
                                        Navigator.pop(context); // Pop the outer dialog
                                    },
                                    child: const Text("Reset")
                                )
                            ],
                        )
                    );
                },
                        child: const Text(AppStrings.reset),
                    )
                ]
            )
        );
    }
}
