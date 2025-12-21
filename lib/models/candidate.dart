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
    'color': color.toARGB32(),
  };

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'],
      votes: json['votes'],
      color: Color(json['color']),
    );
  }
}
