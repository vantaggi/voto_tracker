import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/app_theme.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ProjectorModeScreen extends StatelessWidget {
  const ProjectorModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();
    // Enforce Dark Theme for Projector Mode for better contrast in dark rooms,
    // but use our Expressive M3 Dark Theme.
    return Theme(
      data: AppTheme.darkTheme,
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: colorScheme.surface, 
            appBar: AppBar(
              title: const Text("Modalità Proiettore"),
              backgroundColor: Colors.transparent,
              foregroundColor: colorScheme.onSurfaceVariant,
              elevation: 0,
            ),
            body: Consumer<ScrutinyProvider>(
              builder: (context, provider, child) {
                final candidates = provider.sortedCandidates.where((c) => c.votes > 0).toList();
                final totalVotes = provider.totalVotesAssigned;
                
                if (candidates.isEmpty) {
                    return Center(
                        child: Text(
                            "In attesa di dati...", 
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: colorScheme.onSurfaceVariant)
                        )
                    );
                }
      
                final maxVotes = candidates.first.votes; // First is max because sorted
      
                return Column(
                  children: [
                      _buildHeader(context, provider),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            final candidate = candidates[index];
                            final percentage = candidate.getPercentage(totalVotes);
                            final progress = maxVotes > 0 ? candidate.votes / maxVotes : 0.0;
                            
                            return Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                height: 100,
                                child: Stack(
                                    children: [
                                        // Background Bar (Progress)
                                        FractionallySizedBox(
                                            widthFactor: progress,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: candidate.color.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(24) // Expressive shape
                                                ),
                                            ),
                                        ),
                                        // Content
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 24),
                                            child: Row(
                                                children: [
                                                    // Rank
                                                    Container(
                                                        width: 64,
                                                        height: 64,
                                                        decoration: BoxDecoration(
                                                            color: index == 0 ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                                                            borderRadius: BorderRadius.circular(20), // Rounded match
                                                            border: index == 0 ? Border.all(color: colorScheme.primary, width: 2) : null
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                            "${index + 1}", 
                                                            style: TextStyle(
                                                                fontSize: 32, 
                                                                fontWeight: FontWeight.w900,
                                                                color: index == 0 ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant
                                                            )
                                                        ),
                                                    ),
                                                    const SizedBox(width: 24),
                                                    // Name
                                                    Expanded(
                                                        child: Text(
                                                            candidate.name.toUpperCase(),
                                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                                fontWeight: FontWeight.w900,
                                                                letterSpacing: 1.2,
                                                                color: colorScheme.onSurface
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                        )
                                                    ),
                                                    // Percentage
                                                    Text(
                                                        "${percentage.toStringAsFixed(1)}%",
                                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                            color: colorScheme.onSurfaceVariant
                                                        )
                                                    ),
                                                    const SizedBox(width: 32),
                                                    // Votes
                                                    Text(
                                                        "${candidate.votes}",
                                                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                            color: candidate.color == Colors.black ? colorScheme.onSurface : candidate.color
                                                        )
                                                    )
                                                ]
                                            )
                                        )
                                    ]
                                )
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        }
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, ScrutinyProvider provider) {
      final winner = provider.winner;
      final colorScheme = Theme.of(context).colorScheme;

      if (winner != null) {
          final isFinal = provider.remainingVotes <= 0;
          final label = winner == AppStrings.tie ? "RISULTATO FINALE" : (isFinal ? "ELETTO" : "MAGGIORANZA RAGGIUNTA");
          
          return Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: winner == AppStrings.tie ? colorScheme.tertiaryContainer : colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32))
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                    Text(
                        label, 
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: winner == AppStrings.tie ? colorScheme.onTertiaryContainer : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    Text(
                        winner.toUpperCase(),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: winner == AppStrings.tie ? colorScheme.onTertiaryContainer : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2
                        ),
                    ),
                ],
              )
          );
      }
      return Container(
          padding: const EdgeInsets.all(24),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                   Icon(Icons.how_to_vote_outlined, color: colorScheme.onSurfaceVariant, size: 32),
                   const SizedBox(width: 16),
                   Text(
                       "VOTI TOTALI: ${provider.totalVotesAssigned} / ${provider.settings.totalVoters}",
                       style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurfaceVariant)
                   )
              ]
          )
      );
  }
}
