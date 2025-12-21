import 'dart:math' as math;
import 'package:voto_tracker/utils/app_constants.dart';

class Settings {
  int _totalVoters;
  int _participantsCount;
  bool _showBlankVotes;
  bool _showNullVotes;

  Settings({
    int totalVoters = 100,
    int participantsCount = 4,
    bool showBlankVotes = true,
    bool showNullVotes = true,
  })  : _totalVoters = totalVoters,
        _participantsCount = participantsCount,
        _showBlankVotes = showBlankVotes,
        _showNullVotes = showNullVotes;

  int get totalVoters => _totalVoters;
  int get participantsCount => _participantsCount;
  bool get showBlankVotes => _showBlankVotes;
  bool get showNullVotes => _showNullVotes;

  void updateTotalVoters(int count) => _totalVoters = math.max(1, count);

  void updateParticipantsCount(int count) =>
      _participantsCount = math.max(AppStrings.minParticipants, count);
  void updateShowBlankVotes(bool show) => _showBlankVotes = show;
  void updateShowNullVotes(bool show) => _showNullVotes = show;

  Map<String, dynamic> toJson() => {
    'totalVoters': _totalVoters,
    'participantsCount': _participantsCount,
    'showBlankVotes': _showBlankVotes,
    'showNullVotes': _showNullVotes,
  };

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      totalVoters: json['totalVoters'] ?? 100,
      participantsCount: json['participantsCount'] ?? 4,
      showBlankVotes: json['showBlankVotes'] ?? true,
      showNullVotes: json['showNullVotes'] ?? true,
    );
  }
}
