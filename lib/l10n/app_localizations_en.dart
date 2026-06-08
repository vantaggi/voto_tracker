// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Voto Tracker';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get exportShareTooltip => 'Export / Share';

  @override
  String get projectorMode => 'Projector Mode';

  @override
  String get shareImageTitle => 'Share social image';

  @override
  String get shareImageSubtitle => 'Optimized for Instagram/WhatsApp';

  @override
  String get exportPdfTitle => 'Export PDF report';

  @override
  String get exportPdfSubtitle => 'Official document with charts';

  @override
  String get exportCsvTitle => 'Export CSV';

  @override
  String get exportCsvSubtitle => 'Table for spreadsheets';

  @override
  String get exportJsonTitle => 'Export JSON';

  @override
  String get exportJsonSubtitle => 'Full structured data';

  @override
  String get exportError => 'Export failed';

  @override
  String get scrutinisedVotes => 'Counted votes';

  @override
  String get remaining => 'Remaining';

  @override
  String get votesTotal => 'TOTAL VOTES';

  @override
  String get waitingForData => 'Waiting for data...';

  @override
  String votesToWin(int count) {
    return '$count votes left to win';
  }

  @override
  String get votes => 'votes';

  @override
  String get votesShort => 'Votes';

  @override
  String get winnerElected => 'ELECTED';

  @override
  String get winnerMathematical => 'MATHEMATICAL WIN';

  @override
  String get finalResult => 'FINAL RESULT';

  @override
  String get tie => 'Tie';

  @override
  String get winnerFallback => 'WINNER';

  @override
  String get blankVotes => 'Blank votes';

  @override
  String get spoiledVotes => 'Null votes';

  @override
  String get editName => 'Edit name';

  @override
  String get candidateName => 'Candidate name';

  @override
  String get previousResultLabel => 'Previous result (%)';

  @override
  String get previousResultHint => 'E.g. 25.5';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get current => 'Current';

  @override
  String get history => 'History';

  @override
  String get percentages => 'Percentages';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noHistoryAvailable => 'No history available';

  @override
  String get noVotesRecorded => 'No votes recorded';

  @override
  String get undoTooltip => 'Undo last action';

  @override
  String get redoTooltip => 'Redo action';

  @override
  String get resetButton => 'HOLD TO RESET';

  @override
  String get scrutinyConfiguration => 'Scrutiny configuration';

  @override
  String get totalVotersNumber => 'Total number of voters';

  @override
  String get votersHint => 'E.g. 100';

  @override
  String get participantsCount => 'Number of candidates';

  @override
  String get votingOptions => 'Voting options';

  @override
  String get dataManagement => 'Data management';

  @override
  String get exportLabel => 'Export';

  @override
  String get importLabel => 'Import';

  @override
  String get configLoaded => 'Configuration loaded successfully';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageEnglish => 'English';
}
