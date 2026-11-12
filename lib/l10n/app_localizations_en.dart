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
  String get shareImageTitle => 'Image';

  @override
  String get shareImageSubtitle => 'For WhatsApp and social media';

  @override
  String get exportPdfTitle => 'PDF report';

  @override
  String get exportPdfSubtitle => 'To print or archive';

  @override
  String get exportCsvTitle => 'CSV';

  @override
  String get exportCsvSubtitle => 'For spreadsheets';

  @override
  String get exportJsonTitle => 'JSON';

  @override
  String get exportJsonSubtitle => 'All the data';

  @override
  String get exportError => 'Export failed';

  @override
  String votesToWin(int count) {
    return '$count votes left to win';
  }

  @override
  String get winnerElected => 'ELECTED';

  @override
  String get winnerMathematical => 'MATHEMATICAL WIN';

  @override
  String get finalResult => 'FINAL RESULT';

  @override
  String get tie => 'Tie';

  @override
  String get blankVotes => 'Blank votes';

  @override
  String get spoiledVotes => 'Null votes';

  @override
  String get editName => 'Edit candidate';

  @override
  String get candidateName => 'Name';

  @override
  String get previousResultLabel => 'Previous result';

  @override
  String get previousResultHint => 'E.g. 25.5';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get undoTooltip => 'Undo last action';

  @override
  String get redoTooltip => 'Redo action';

  @override
  String get participantsCount => 'Number of candidates';

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

  @override
  String get appearance => 'Appearance';

  @override
  String get useSystemColors => 'System colors';

  @override
  String get useSystemColorsSubtitle =>
      'Use the colors of your wallpaper (Android 12+)';

  @override
  String addVoteFor(String name) {
    return 'Add a vote to $name';
  }

  @override
  String removeVoteFor(String name) {
    return 'Remove a vote from $name';
  }

  @override
  String get navScrutiny => 'Count';

  @override
  String get navArchive => 'Archive';

  @override
  String get archiveTitle => 'Count archive';

  @override
  String get newScrutiny => 'New count';

  @override
  String defaultScrutinyTitle(String date) {
    return 'Count of $date';
  }

  @override
  String get archiveOpen => 'Open';

  @override
  String get archiveDuplicate => 'Duplicate as template';

  @override
  String get archiveRename => 'Rename';

  @override
  String get archiveDelete => 'Delete';

  @override
  String archiveBallots(int counted, int total) {
    return '$counted of $total ballots';
  }

  @override
  String archiveLeader(String name) {
    return 'Leading: $name';
  }

  @override
  String get archiveDeleteTitle => 'Delete this count?';

  @override
  String archiveDeleteBody(String title) {
    return '“$title” and all its ballots will be deleted. This cannot be undone.';
  }

  @override
  String get archiveRenameHint => 'Leave empty for the default title';

  @override
  String get scrutinyTitleLabel => 'Title';

  @override
  String archiveOpened(String title) {
    return 'Opened “$title”';
  }

  @override
  String archiveActions(String title) {
    return 'Actions for $title';
  }

  @override
  String get outcomeNoMajority => 'Runoff';

  @override
  String get outcomeNoQuorum => 'Quorum not reached';

  @override
  String get victoryRuleTitle => 'Victory rule';

  @override
  String get rulePlurality => 'Plurality';

  @override
  String get ruleAbsoluteMajority => 'Absolute majority';

  @override
  String get ruleAbsoluteMajorityHint =>
      'Wins whoever gets more than half of the ballots, blank and spoiled included';

  @override
  String get quorumTitle => 'Turnout quorum';

  @override
  String get quorumSubtitle => 'Valid only if enough eligible voters take part';

  @override
  String get eligibleVotersLabel => 'Eligible voters';

  @override
  String get quorumPercentLabel => 'Quorum (%)';

  @override
  String get ballotReadingTitle => 'Ballot reading';

  @override
  String ballotNumber(int n, int total) {
    return 'Ballot $n of $total';
  }

  @override
  String get countingComplete => 'Count completed';

  @override
  String get ballotHint => 'Tap the name written on the ballot';

  @override
  String defaultCandidateName(int number) {
    return 'Candidate $number';
  }

  @override
  String get archiveMoreActions => 'More archive actions';

  @override
  String get archiveExport => 'Export archive';

  @override
  String get archiveImport => 'Import from file';

  @override
  String get archiveImportTitle => 'Import counts';

  @override
  String archiveImportBody(int count) {
    return 'The file contains $count counts. They will be added to the archive; the ones already there are left untouched.';
  }

  @override
  String get archiveImportConfirm => 'Add';

  @override
  String archiveImported(int added, int skipped) {
    return 'Counts added: $added. Already present: $skipped.';
  }

  @override
  String get archiveImportInvalid => 'This file is not a Voto Tracker archive';

  @override
  String get archiveImportEmpty => 'The file contains no counts';

  @override
  String projectorRowSemantics(
    int position,
    String name,
    int votes,
    String percent,
  ) {
    return 'Place $position, $name: $votes votes, $percent%';
  }

  @override
  String get useAsDefaults => 'Also use for new counts';

  @override
  String get useAsDefaultsHint =>
      'Starting voters, rule and quorum for every new count';

  @override
  String get saveAsList => 'Save candidates as a list';

  @override
  String get listNameLabel => 'List name';

  @override
  String listSaved(String name) {
    return 'List “$name” saved';
  }

  @override
  String get newEmptyScrutiny => 'Empty count';

  @override
  String listCandidates(int count) {
    return '$count candidates';
  }

  @override
  String deleteList(String name) {
    return 'Delete list $name';
  }

  @override
  String homeSubtitle(int assigned, int total) {
    return '$assigned of $total ballots';
  }

  @override
  String summaryOfTotal(int total) {
    return '/ $total ballots';
  }

  @override
  String summaryRemaining(int count) {
    return '$count remaining';
  }

  @override
  String get summaryCompleted => 'Completed';

  @override
  String summaryLeading(String name) {
    return '$name is leading';
  }

  @override
  String get summaryLeadingTie => 'Tie for the lead';

  @override
  String get summaryEmptyTitle => 'No ballots yet';

  @override
  String summaryEmptyBody(int candidates, int total) {
    return '$candidates candidates, $total ballots expected. Check the names, then start.';
  }

  @override
  String get summarySetup => 'Set up';

  @override
  String get shareResults => 'Share results';

  @override
  String get otherBallots => 'Other ballots';

  @override
  String candidateRowSemantics(String name, int votes, String percent) {
    return '$name: $votes votes, $percent';
  }

  @override
  String get chartsTitle => 'Trend and charts';

  @override
  String get chartsSubtitle => 'Trend and comparison';

  @override
  String undoLastVote(String name) {
    return 'Undo $name';
  }

  @override
  String get moreActions => 'More actions';

  @override
  String get resetScrutiny => 'Reset count';

  @override
  String get resetConfirmTitle => 'Reset the count?';

  @override
  String get resetConfirmBody =>
      'All votes go back to zero. Candidate names and colours stay. This can\'t be undone.';

  @override
  String get resetConfirm => 'Reset';

  @override
  String settingsResetWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'the $count counted ballots',
      one: 'the counted ballot',
    );
    return 'Changing candidates, blank or spoiled ballots resets $_temp0. Names and colours stay.';
  }

  @override
  String get saveAndReset => 'Save and reset';

  @override
  String get settingsTitle => 'Count settings';

  @override
  String get settingsGroupBallots => 'Ballots and candidates';

  @override
  String get settingsGroupRules => 'Rules';

  @override
  String get settingsGroupLists => 'Candidate lists';

  @override
  String get settingsVoters => 'Voters';

  @override
  String get settingsVotersHint => 'Ballots expected in total';

  @override
  String get settingsCandidates => 'Candidates';

  @override
  String settingsCandidatesHint(int min, int max) {
    return 'From $min to $max';
  }

  @override
  String stepperDecrease(String label) {
    return 'Decrease $label';
  }

  @override
  String stepperIncrease(String label) {
    return 'Increase $label';
  }

  @override
  String get listExportFile => 'Export candidates to a file';

  @override
  String get listImportFile => 'Import candidates from a file';

  @override
  String get appSettingsTitle => 'App settings';

  @override
  String get appSettingsSubtitle => 'Language and appearance';

  @override
  String get archiveGroupCurrent => 'Open now';

  @override
  String get archiveGroupOthers => 'Other counts';

  @override
  String get archiveSearch => 'Search by name';

  @override
  String get archiveNoResults => 'No count with this name';

  @override
  String get archiveReopen => 'Reopen';

  @override
  String get archiveGoToCount => 'Go to the count';

  @override
  String get archiveExportOne => 'Export';

  @override
  String get newEmptyScrutinyHint => 'Default candidates and settings';

  @override
  String newFromCopy(String title) {
    return 'Copy “$title”';
  }

  @override
  String get newFromCopyHint => 'Same candidates and rules, no ballots';

  @override
  String get newFromList => 'From a saved list';

  @override
  String get ballotBackToCount => 'Back to the count';

  @override
  String ballotTileSemantics(String name, int votes) {
    String _temp0 = intl.Intl.pluralLogic(
      votes,
      locale: localeName,
      other: '$votes votes',
      one: '1 vote',
    );
    return '$name, $_temp0';
  }

  @override
  String exportSheetTitle(String title) {
    return 'Share “$title”';
  }

  @override
  String get exportDataLabel => 'Data only';

  @override
  String get candidateColor => 'Colour';

  @override
  String candidateColorOption(int n) {
    return 'Colour $n';
  }

  @override
  String get previousResultHelper =>
      'The rows show how much it went up or down';

  @override
  String previousResultHintNumber(String example) {
    return 'E.g. $example';
  }

  @override
  String get exportStatusInProgress => 'In progress';

  @override
  String get exportStatusFinal => 'Final result';

  @override
  String exportVotesPercent(String votes, String percent) {
    return '$votes votes · $percent';
  }

  @override
  String exportMoreCandidates(String count) {
    return '+$count more';
  }

  @override
  String get exportFooterApp => 'Made with Voto Tracker';

  @override
  String exportShareText(String title) {
    return '$title · results';
  }

  @override
  String get pdfTitle => 'RESULTS REPORT';

  @override
  String pdfExpectedVoters(String count) {
    return '$count ballots expected';
  }

  @override
  String pdfProvisional(String counted, String total) {
    return 'Provisional result: $counted of $total ballots counted.';
  }

  @override
  String pdfWinnerDetail(String votes, String counted, String percent) {
    return '$votes votes of $counted ballots ($percent)';
  }

  @override
  String get pdfKeyCounted => 'ballots counted';

  @override
  String get pdfKeyRemaining => 'remaining';

  @override
  String get pdfKeyValid => 'valid votes';

  @override
  String get pdfKeyBlankSpoiled => 'blank · spoiled';

  @override
  String get pdfKeyTurnout => 'turnout';

  @override
  String pdfCountedOf(String counted, String total) {
    return '$counted of $total';
  }

  @override
  String get pdfResults => 'Results';

  @override
  String get pdfColCandidate => 'Candidate';

  @override
  String get pdfColVotes => 'Votes';

  @override
  String get pdfColChange => 'Compared to before';

  @override
  String get pdfTotal => 'Total';

  @override
  String get pdfNote => 'Percentages of the ballots counted.';

  @override
  String get pdfNoteChange =>
      '\"Compared to before\" in percentage points over the previous result.';

  @override
  String get pdfTrend => 'Trend';

  @override
  String get pdfTrendAxes => 'votes · ballots counted';

  @override
  String get pdfSignPresident => 'The chair';

  @override
  String get pdfSignTellers => 'The tellers';

  @override
  String pdfPage(String page, String pages) {
    return 'Page $page of $pages';
  }

  @override
  String get csvPosition => 'Position';

  @override
  String get csvCandidate => 'Candidate';

  @override
  String get csvType => 'Type';

  @override
  String get csvVotes => 'Votes';

  @override
  String get csvPercent => 'Percentage';

  @override
  String get csvPrevious => 'Previous percentage';

  @override
  String get csvChange => 'Change';

  @override
  String get csvTypeCandidate => 'candidate';

  @override
  String get csvTypeBlank => 'blank';

  @override
  String get csvTypeSpoiled => 'spoiled';

  @override
  String get chartTrend => 'Trend';

  @override
  String get chartCompare => 'Comparison';

  @override
  String get chartBallotsAxis => 'Ballots counted';

  @override
  String get chartTechnicalChip => 'Blank and spoiled';

  @override
  String chartAtBallot(String n, String values) {
    return 'At ballot $n: $values';
  }

  @override
  String chartAfter(String n, String values) {
    return 'After $n ballots: $values';
  }

  @override
  String get chartEmpty => 'Charts appear from the first vote';

  @override
  String get chartLegendNow => 'Now';

  @override
  String get chartLegendPrevious => 'Previous result';

  @override
  String chartPoints(String value) {
    return '$value pts';
  }

  @override
  String chartCompareRow(String name, String percent) {
    return '$name: $percent';
  }

  @override
  String chartCompareRowChange(String name, String percent, String change) {
    return '$name: $percent, $change points compared to before';
  }
}
