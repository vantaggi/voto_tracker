import 'package:flutter/material.dart';

class Candidate {
  String name;
  int votes;
  Color color;

  Candidate({required this.name, required this.votes, required this.color});

  double getPercentage(int totalVotes) {
    return totalVotes > 0 ? (votes / totalVotes) * 100 : 0;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'votes': votes,
    'color': color.value, // Ignoring deprecation for clean int serialization compatibility as toARGB32 might be version specific or behave differently.
    // 'color': color.toARGB32(), // Recommended replacement if available
  };

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'],
      votes: json['votes'],
      color: Color(json['color']),
    );
  }
}
