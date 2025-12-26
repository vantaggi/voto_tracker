import 'package:flutter/material.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class SocialResultsCard extends StatelessWidget {
  final List<Candidate> candidates;
  final int totalVotes;
  final String? winner;
  final String? winnerLabel;

  const SocialResultsCard({
    super.key,
    required this.candidates,
    required this.totalVotes,
    this.winner,
    this.winnerLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Top 5 candidates only
    final topCandidates = candidates.take(5).toList();

    return Container(
      width: 1080 / 2, // Scaled down for display, will be captured at higher pixel ratio
      height: 1350 / 2, // 4:5 Aspect Ratio (Instagram Portrait)
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade900,
            Colors.purple.shade900,
            Colors.black,
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
                    Text("AGGIORNAMENTO", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, letterSpacing: 2)),
                    const Text("SCRUTINIO LIVE", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                 ]
               ),
               Icon(Icons.how_to_vote, color: Colors.white.withOpacity(0.2), size: 48)
            ],
          ),
          const SizedBox(height: 32),
          
          // Winner Badge
          if (winner != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20)]
            ),
            child: Column(
                children: [
                    Text(winnerLabel ?? "VINCITORE", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(winner!.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 28), textAlign: TextAlign.center),
                ]
            )
          ),

          // List
          if (winner == null)
            const Text("CLASSIFICA PARZIALE", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: Column(
              children: topCandidates.asMap().entries.map((entry) {
                final index = entry.key;
                final c = entry.value;
                final p = c.getPercentage(totalVotes);
                return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                        children: [
                            Text("${index + 1}.", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
                            Text("${p.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(width: 12),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(4)),
                                child: Text("${c.votes}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            )
                        ]
                    )
                );
              }).toList(),
            ),
          ),
          
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Center(
              child: Text("Generato con Voto Tracker", style: TextStyle(color: Colors.white.withOpacity(0.5), fontStyle: FontStyle.italic))
          )
        ],
      ),
    );
  }
}
