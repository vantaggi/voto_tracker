import 'package:flutter/material.dart';

class Candidate {
  String name;
  int votes;
  Color color;
  int rank = 0; // Transient property for display, initialized to 0

  Candidate({
    required this.name, 
    required this.votes, 
    required this.color,
    this.rank = 0
  });

  double getPercentage(int totalVotes) {
    return totalVotes > 0 ? (votes / totalVotes) * 100 : 0;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'votes': votes,
    'color': color.toARGB32(),
  };

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'],
      votes: json['votes'],
      color: Color(json['color']),
      rank: json['rank'] ?? 0, // Ensure rank is loaded or defaults to 0
    );
  }
}
