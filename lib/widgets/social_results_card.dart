import 'package:flutter/material.dart';
import 'package:voto_tracker/models/candidate.dart';

class SocialResultsCard extends StatelessWidget {
  final List<Candidate> candidates;
  final int totalVotes;
  final int totalVoters;
  final int remainingVotes;
  final String? winner;
  final String? winnerLabel;

  const SocialResultsCard({
    super.key,
    required this.candidates,
    required this.totalVotes,
    required this.totalVoters,
    required this.remainingVotes,
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
      width: 1080 / 2, // Scaled down for display, will be captured at higher pixel ratio
      height: 1350 / 2, // 4:5 Aspect Ratio (Instagram Portrait)
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        // Subtle gradient overlay for extra polish
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainer,
          ],
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
                    Text("AGGIORNAMENTO ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}", 
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant, letterSpacing: 2
                        )),
                    const SizedBox(height: 4),
                    Text("SCRUTINIO LIVE", 
                        style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: colorScheme.onSurface
                        )
                    ),
                     const SizedBox(height: 8),
                     Text(
                        "Scrutinate: $totalVotes / $totalVoters (${(totalVotes / (totalVoters == 0 ? 1 : totalVoters) * 100).toStringAsFixed(1)}%)\nRimanenti: $remainingVotes",
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)
                     ),
                 ]
               ),
               Icon(Icons.how_to_vote_outlined, color: colorScheme.primary.withOpacity(0.5), size: 64)
            ],
          ),
          const SizedBox(height: 32),
          
          // Winner Badge (if present)
          if (winner != null)
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24), // M3 Medium/Large shape
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.2), 
                    blurRadius: 16,
                    offset: const Offset(0, 4)
                  )
                ]
            ),
            child: Column(
                children: [
                    Text(winnerLabel ?? "VINCITORE", 
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5
                        )
                    ),
                    const SizedBox(height: 4),
                    Text(winner!.toUpperCase(), 
                        style: theme.textTheme.displaySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer, 
                            fontWeight: FontWeight.w900
                        ), 
                        textAlign: TextAlign.center
                    ),
                ]
            )
          ),

          // List Header
          if (winner == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text("CLASSIFICA PARZIALE", 
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary, 
                      fontWeight: FontWeight.bold
                  )
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
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                        color: isFirst 
                             ? colorScheme.surfaceContainerHighest 
                             : colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: isFirst 
                             ? Border.all(color: colorScheme.primary.withOpacity(0.5)) 
                             : null
                    ),
                    child: Row(
                        children: [
                            Container(
                                width: 28, 
                                alignment: Alignment.center,
                                child: Text("${index + 1}.", 
                                    style: theme.textTheme.titleMedium?.copyWith(
                                        color: isFirst ? colorScheme.primary : colorScheme.onSurfaceVariant, 
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(c.name, 
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: isFirst ? FontWeight.bold : FontWeight.w500
                                )
                            )),
                            Text("${p.toStringAsFixed(1)}%", 
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                )
                            ),
                            const SizedBox(width: 16),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: c.color.withOpacity(0.2), 
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: c.color.withOpacity(0.5))
                                ),
                                child: Text("${c.votes}", 
                                    style: theme.textTheme.titleMedium?.copyWith(
                                        color: c.color == Colors.black ? colorScheme.onSurface : c.color, 
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            )
                        ]
                    )
                );
              }).toList(),
            ),
          ),
          
          const Divider(),
          const SizedBox(height: 16),
          Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text("Generato con Voto Tracker", 
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant, 
                          fontStyle: FontStyle.italic
                      )
                  ),
                ],
              )
          )
        ],
      ),
    );
  }
}
