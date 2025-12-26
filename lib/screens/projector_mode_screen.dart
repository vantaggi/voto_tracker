import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ProjectorModeScreen extends StatelessWidget {
  const ProjectorModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();
    return Scaffold(
      backgroundColor: Colors.black, // Always dark for contrast
      appBar: AppBar(
        title: const Text("Modalità Proiettore"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white54,
        elevation: 0,
      ),
      body: Consumer<ScrutinyProvider>(
        builder: (context, provider, child) {
          final candidates = provider.sortedCandidates.where((c) => c.votes > 0).toList();
          final totalVotes = provider.totalVotesAssigned;
          
          if (candidates.isEmpty) {
              return const Center(child: Text("In attesa di dati...", style: TextStyle(color: Colors.white54, fontSize: 32)));
          }

          final maxVotes = candidates.first.votes; // First is max because sorted

          return Column(
            children: [
                _buildHeader(provider),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
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
                                  // Background Bar
                                  FractionallySizedBox(
                                      widthFactor: progress,
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: candidate.color.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(16)
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
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                      color: index == 0 ? Colors.amber : Colors.grey.shade800,
                                                      shape: BoxShape.circle
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      "${index + 1}", 
                                                      style: TextStyle(
                                                          fontSize: 32, 
                                                          fontWeight: FontWeight.bold,
                                                          color: index == 0 ? Colors.black : Colors.white
                                                      )
                                                  ),
                                              ),
                                              const SizedBox(width: 24),
                                              // Name
                                              Expanded(
                                                  child: Text(
                                                      candidate.name.toUpperCase(),
                                                      style: const TextStyle(
                                                          fontSize: 32,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                          letterSpacing: 1.5
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                  )
                                              ),
                                              // Percentage
                                              Text(
                                                  "${percentage.toStringAsFixed(1)}%",
                                                  style: const TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.white54
                                                  )
                                              ),
                                              const SizedBox(width: 24),
                                              // Votes
                                              Text(
                                                  "${candidate.votes}",
                                                  style: TextStyle(
                                                      fontSize: 56,
                                                      fontWeight: FontWeight.bold,
                                                      color: candidate.color == Colors.black ? Colors.white : candidate.color
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
  
  Widget _buildHeader(ScrutinyProvider provider) {
      final winner = provider.winner;
      if (winner != null) {
          final isFinal = provider.remainingVotes <= 0;
          final label = isFinal ? "ELETTO" : "MAGGIORANZA RAGGIUNTA";
          
          return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              color: Colors.amber,
              alignment: Alignment.center,
              child: Column(
                children: [
                    Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
                    Text(
                        winner.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 48,
                            letterSpacing: 4
                        ),
                    ),
                ],
              )
          );
      }
      return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                   const Icon(Icons.how_to_vote, color: Colors.white54, size: 32), // fallback icon if needed
                   const SizedBox(width: 16),
                   Text(
                       "VOTI TOTALI: ${provider.totalVotesAssigned} / ${provider.settings.totalVoters}",
                       style: const TextStyle(color: Colors.white54, fontSize: 24)
                   )
              ]
          )
      );
  }
}
