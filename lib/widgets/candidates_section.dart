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
                            Text(
                                (provider.winner == AppStrings.tie 
                                    ? "RISULTATO FINALE" 
                                    : (provider.remainingVotes <= 0 ? "ELETTO" : "MAGGIORANZA RAGGIUNTA")), 
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)
                            ),
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
                         icon: const Icon(Icons.refresh),
                         color: Colors.red,
                         tooltip: AppStrings.reset,
                         onPressed: () => _confirmReset(context),
                    )
                ]
            )
        );
    }
    
    void _confirmReset(BuildContext context) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text(AppStrings.confirmReset),
                content: const Text("Tutti i dati verranno cancellati in modo permanente.\n\nPer confermare, tieni premuto il pulsante rosso."),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: const Text(AppStrings.cancel)
                    ),
                    _HoldToResetButton(
                        onReset: () {
                            context.read<ScrutinyProvider>().reset();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text(AppStrings.resetDone))
                            );
                        }
                    ),
                ]
            )
        );
    }
}

class _HoldToResetButton extends StatefulWidget {
    final VoidCallback onReset;
    const _HoldToResetButton({required this.onReset});

    @override
    State<_HoldToResetButton> createState() => _HoldToResetButtonState();
}

class _HoldToResetButtonState extends State<_HoldToResetButton> with SingleTickerProviderStateMixin {
    late AnimationController _controller;

    @override
    void initState() {
        super.initState();
        _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
        _controller.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
                HapticFeedback.heavyImpact();
                widget.onReset();
            }
        });
    }

    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
                if (_controller.status != AnimationStatus.completed) {
                    _controller.reverse();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Tieni premuto fino al completamento per resettare"),
                            duration: Duration(milliseconds: 1000),
                        )
                    );
                }
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                    return Container(
                        height: 48,
                        width: 200, // Fixed width for dialog
                        decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.hardEdge,
                        alignment: Alignment.centerLeft,
                        child: Stack(
                            children: [
                                Container(
                                    width: 200 * _controller.value,
                                    height: 48,
                                    color: Colors.red,
                                ),
                                Center(
                                    child: Text(
                                        "TIENI PREMUTO",
                                        style: TextStyle(
                                            color: _controller.value > 0.5 ? Colors.white : Colors.red,
                                            fontWeight: FontWeight.bold
                                        ),
                                    )
                                )
                            ],
                        )
                    );
                }
            ),
        );
    }

}
