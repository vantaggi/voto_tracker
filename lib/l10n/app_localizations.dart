import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Voto Tracker'**
  String get appTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @exportShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export / Share'**
  String get exportShareTooltip;

  /// No description provided for @projectorMode.
  ///
  /// In en, this message translates to:
  /// **'Projector Mode'**
  String get projectorMode;

  /// No description provided for @shareImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get shareImageTitle;

  /// No description provided for @shareImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For WhatsApp and social media'**
  String get shareImageSubtitle;

  /// No description provided for @exportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF report'**
  String get exportPdfTitle;

  /// No description provided for @exportPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'To print or archive'**
  String get exportPdfSubtitle;

  /// No description provided for @exportCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get exportCsvTitle;

  /// No description provided for @exportCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For spreadsheets'**
  String get exportCsvSubtitle;

  /// No description provided for @exportJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get exportJsonTitle;

  /// No description provided for @exportJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All the data'**
  String get exportJsonSubtitle;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportError;

  /// No description provided for @votesToWin.
  ///
  /// In en, this message translates to:
  /// **'{count} votes left to win'**
  String votesToWin(int count);

  /// No description provided for @winnerElected.
  ///
  /// In en, this message translates to:
  /// **'ELECTED'**
  String get winnerElected;

  /// No description provided for @winnerMathematical.
  ///
  /// In en, this message translates to:
  /// **'MATHEMATICAL WIN'**
  String get winnerMathematical;

  /// No description provided for @finalResult.
  ///
  /// In en, this message translates to:
  /// **'FINAL RESULT'**
  String get finalResult;

  /// No description provided for @tie.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get tie;

  /// No description provided for @blankVotes.
  ///
  /// In en, this message translates to:
  /// **'Blank votes'**
  String get blankVotes;

  /// No description provided for @spoiledVotes.
  ///
  /// In en, this message translates to:
  /// **'Null votes'**
  String get spoiledVotes;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit candidate'**
  String get editName;

  /// No description provided for @candidateName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get candidateName;

  /// No description provided for @previousResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous result'**
  String get previousResultLabel;

  /// No description provided for @previousResultHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. 25.5'**
  String get previousResultHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @undoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Undo last action'**
  String get undoTooltip;

  /// No description provided for @redoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Redo action'**
  String get redoTooltip;

  /// No description provided for @participantsCount.
  ///
  /// In en, this message translates to:
  /// **'Number of candidates'**
  String get participantsCount;

  /// No description provided for @configLoaded.
  ///
  /// In en, this message translates to:
  /// **'Configuration loaded successfully'**
  String get configLoaded;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @useSystemColors.
  ///
  /// In en, this message translates to:
  /// **'System colors'**
  String get useSystemColors;

  /// No description provided for @useSystemColorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the colors of your wallpaper (Android 12+)'**
  String get useSystemColorsSubtitle;

  /// No description provided for @addVoteFor.
  ///
  /// In en, this message translates to:
  /// **'Add a vote to {name}'**
  String addVoteFor(String name);

  /// No description provided for @removeVoteFor.
  ///
  /// In en, this message translates to:
  /// **'Remove a vote from {name}'**
  String removeVoteFor(String name);

  /// No description provided for @navScrutiny.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get navScrutiny;

  /// No description provided for @navArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get navArchive;

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Count archive'**
  String get archiveTitle;

  /// No description provided for @newScrutiny.
  ///
  /// In en, this message translates to:
  /// **'New count'**
  String get newScrutiny;

  /// No description provided for @defaultScrutinyTitle.
  ///
  /// In en, this message translates to:
  /// **'Count of {date}'**
  String defaultScrutinyTitle(String date);

  /// No description provided for @archiveOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get archiveOpen;

  /// No description provided for @archiveDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate as template'**
  String get archiveDuplicate;

  /// No description provided for @archiveRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get archiveRename;

  /// No description provided for @archiveDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get archiveDelete;

  /// No description provided for @archiveBallots.
  ///
  /// In en, this message translates to:
  /// **'{counted} of {total} ballots'**
  String archiveBallots(int counted, int total);

  /// No description provided for @archiveLeader.
  ///
  /// In en, this message translates to:
  /// **'Leading: {name}'**
  String archiveLeader(String name);

  /// No description provided for @archiveDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this count?'**
  String get archiveDeleteTitle;

  /// No description provided for @archiveDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” and all its ballots will be deleted. This cannot be undone.'**
  String archiveDeleteBody(String title);

  /// No description provided for @archiveRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for the default title'**
  String get archiveRenameHint;

  /// No description provided for @scrutinyTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get scrutinyTitleLabel;

  /// No description provided for @archiveOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened “{title}”'**
  String archiveOpened(String title);

  /// No description provided for @archiveActions.
  ///
  /// In en, this message translates to:
  /// **'Actions for {title}'**
  String archiveActions(String title);

  /// No description provided for @outcomeNoMajority.
  ///
  /// In en, this message translates to:
  /// **'Runoff'**
  String get outcomeNoMajority;

  /// No description provided for @outcomeNoQuorum.
  ///
  /// In en, this message translates to:
  /// **'Quorum not reached'**
  String get outcomeNoQuorum;

  /// No description provided for @victoryRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Victory rule'**
  String get victoryRuleTitle;

  /// No description provided for @rulePlurality.
  ///
  /// In en, this message translates to:
  /// **'Plurality'**
  String get rulePlurality;

  /// No description provided for @ruleAbsoluteMajority.
  ///
  /// In en, this message translates to:
  /// **'Absolute majority'**
  String get ruleAbsoluteMajority;

  /// No description provided for @ruleAbsoluteMajorityHint.
  ///
  /// In en, this message translates to:
  /// **'Wins whoever gets more than half of the ballots, blank and spoiled included'**
  String get ruleAbsoluteMajorityHint;

  /// No description provided for @quorumTitle.
  ///
  /// In en, this message translates to:
  /// **'Turnout quorum'**
  String get quorumTitle;

  /// No description provided for @quorumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Valid only if enough eligible voters take part'**
  String get quorumSubtitle;

  /// No description provided for @eligibleVotersLabel.
  ///
  /// In en, this message translates to:
  /// **'Eligible voters'**
  String get eligibleVotersLabel;

  /// No description provided for @quorumPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Quorum (%)'**
  String get quorumPercentLabel;

  /// No description provided for @ballotReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ballot reading'**
  String get ballotReadingTitle;

  /// No description provided for @ballotNumber.
  ///
  /// In en, this message translates to:
  /// **'Ballot {n} of {total}'**
  String ballotNumber(int n, int total);

  /// No description provided for @countingComplete.
  ///
  /// In en, this message translates to:
  /// **'Count completed'**
  String get countingComplete;

  /// No description provided for @ballotHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the name written on the ballot'**
  String get ballotHint;

  /// No description provided for @defaultCandidateName.
  ///
  /// In en, this message translates to:
  /// **'Candidate {number}'**
  String defaultCandidateName(int number);

  /// No description provided for @archiveMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More archive actions'**
  String get archiveMoreActions;

  /// No description provided for @archiveExport.
  ///
  /// In en, this message translates to:
  /// **'Export archive'**
  String get archiveExport;

  /// No description provided for @archiveImport.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get archiveImport;

  /// No description provided for @archiveImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import counts'**
  String get archiveImportTitle;

  /// No description provided for @archiveImportBody.
  ///
  /// In en, this message translates to:
  /// **'The file contains {count} counts. They will be added to the archive; the ones already there are left untouched.'**
  String archiveImportBody(int count);

  /// No description provided for @archiveImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get archiveImportConfirm;

  /// No description provided for @archiveImported.
  ///
  /// In en, this message translates to:
  /// **'Counts added: {added}. Already present: {skipped}.'**
  String archiveImported(int added, int skipped);

  /// No description provided for @archiveImportInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not a Voto Tracker archive'**
  String get archiveImportInvalid;

  /// No description provided for @archiveImportEmpty.
  ///
  /// In en, this message translates to:
  /// **'The file contains no counts'**
  String get archiveImportEmpty;

  /// No description provided for @projectorRowSemantics.
  ///
  /// In en, this message translates to:
  /// **'Place {position}, {name}: {votes} votes, {percent}%'**
  String projectorRowSemantics(
    int position,
    String name,
    int votes,
    String percent,
  );

  /// No description provided for @useAsDefaults.
  ///
  /// In en, this message translates to:
  /// **'Also use for new counts'**
  String get useAsDefaults;

  /// No description provided for @useAsDefaultsHint.
  ///
  /// In en, this message translates to:
  /// **'Starting voters, rule and quorum for every new count'**
  String get useAsDefaultsHint;

  /// No description provided for @saveAsList.
  ///
  /// In en, this message translates to:
  /// **'Save candidates as a list'**
  String get saveAsList;

  /// No description provided for @listNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listNameLabel;

  /// No description provided for @listSaved.
  ///
  /// In en, this message translates to:
  /// **'List “{name}” saved'**
  String listSaved(String name);

  /// No description provided for @newEmptyScrutiny.
  ///
  /// In en, this message translates to:
  /// **'Empty count'**
  String get newEmptyScrutiny;

  /// No description provided for @listCandidates.
  ///
  /// In en, this message translates to:
  /// **'{count} candidates'**
  String listCandidates(int count);

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete list {name}'**
  String deleteList(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{assigned} of {total} ballots'**
  String homeSubtitle(int assigned, int total);

  /// No description provided for @summaryOfTotal.
  ///
  /// In en, this message translates to:
  /// **'/ {total} ballots'**
  String summaryOfTotal(int total);

  /// No description provided for @summaryRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String summaryRemaining(int count);

  /// No description provided for @summaryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get summaryCompleted;

  /// No description provided for @summaryLeading.
  ///
  /// In en, this message translates to:
  /// **'{name} is leading'**
  String summaryLeading(String name);

  /// No description provided for @summaryLeadingTie.
  ///
  /// In en, this message translates to:
  /// **'Tie for the lead'**
  String get summaryLeadingTie;

  /// No description provided for @summaryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No ballots yet'**
  String get summaryEmptyTitle;

  /// No description provided for @summaryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'{candidates} candidates, {total} ballots expected. Check the names, then start.'**
  String summaryEmptyBody(int candidates, int total);

  /// No description provided for @summarySetup.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get summarySetup;

  /// No description provided for @shareResults.
  ///
  /// In en, this message translates to:
  /// **'Share results'**
  String get shareResults;

  /// No description provided for @otherBallots.
  ///
  /// In en, this message translates to:
  /// **'Other ballots'**
  String get otherBallots;

  /// No description provided for @candidateRowSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}: {votes} votes, {percent}'**
  String candidateRowSemantics(String name, int votes, String percent);

  /// No description provided for @chartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trend and charts'**
  String get chartsTitle;

  /// No description provided for @chartsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trend and comparison'**
  String get chartsSubtitle;

  /// No description provided for @undoLastVote.
  ///
  /// In en, this message translates to:
  /// **'Undo {name}'**
  String undoLastVote(String name);

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @resetScrutiny.
  ///
  /// In en, this message translates to:
  /// **'Reset count'**
  String get resetScrutiny;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset the count?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All votes go back to zero. Candidate names and colours stay. This can\'t be undone.'**
  String get resetConfirmBody;

  /// No description provided for @resetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetConfirm;

  /// No description provided for @settingsResetWarning.
  ///
  /// In en, this message translates to:
  /// **'Changing candidates, blank or spoiled ballots resets {count, plural, =1{the counted ballot} other{the {count} counted ballots}}. Names and colours stay.'**
  String settingsResetWarning(int count);

  /// No description provided for @saveAndReset.
  ///
  /// In en, this message translates to:
  /// **'Save and reset'**
  String get saveAndReset;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Count settings'**
  String get settingsTitle;

  /// No description provided for @settingsGroupBallots.
  ///
  /// In en, this message translates to:
  /// **'Ballots and candidates'**
  String get settingsGroupBallots;

  /// No description provided for @settingsGroupRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get settingsGroupRules;

  /// No description provided for @settingsGroupLists.
  ///
  /// In en, this message translates to:
  /// **'Candidate lists'**
  String get settingsGroupLists;

  /// No description provided for @settingsVoters.
  ///
  /// In en, this message translates to:
  /// **'Voters'**
  String get settingsVoters;

  /// No description provided for @settingsVotersHint.
  ///
  /// In en, this message translates to:
  /// **'Ballots expected in total'**
  String get settingsVotersHint;

  /// No description provided for @settingsCandidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get settingsCandidates;

  /// No description provided for @settingsCandidatesHint.
  ///
  /// In en, this message translates to:
  /// **'From {min} to {max}'**
  String settingsCandidatesHint(int min, int max);

  /// No description provided for @stepperDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease {label}'**
  String stepperDecrease(String label);

  /// No description provided for @stepperIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase {label}'**
  String stepperIncrease(String label);

  /// No description provided for @listExportFile.
  ///
  /// In en, this message translates to:
  /// **'Export candidates to a file'**
  String get listExportFile;

  /// No description provided for @listImportFile.
  ///
  /// In en, this message translates to:
  /// **'Import candidates from a file'**
  String get listImportFile;

  /// No description provided for @appSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettingsTitle;

  /// No description provided for @appSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language and appearance'**
  String get appSettingsSubtitle;

  /// No description provided for @archiveGroupCurrent.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get archiveGroupCurrent;

  /// No description provided for @archiveGroupOthers.
  ///
  /// In en, this message translates to:
  /// **'Other counts'**
  String get archiveGroupOthers;

  /// No description provided for @archiveSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get archiveSearch;

  /// No description provided for @archiveNoResults.
  ///
  /// In en, this message translates to:
  /// **'No count with this name'**
  String get archiveNoResults;

  /// No description provided for @archiveReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get archiveReopen;

  /// No description provided for @archiveGoToCount.
  ///
  /// In en, this message translates to:
  /// **'Go to the count'**
  String get archiveGoToCount;

  /// No description provided for @archiveExportOne.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get archiveExportOne;

  /// No description provided for @newEmptyScrutinyHint.
  ///
  /// In en, this message translates to:
  /// **'Default candidates and settings'**
  String get newEmptyScrutinyHint;

  /// No description provided for @newFromCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy “{title}”'**
  String newFromCopy(String title);

  /// No description provided for @newFromCopyHint.
  ///
  /// In en, this message translates to:
  /// **'Same candidates and rules, no ballots'**
  String get newFromCopyHint;

  /// No description provided for @newFromList.
  ///
  /// In en, this message translates to:
  /// **'From a saved list'**
  String get newFromList;

  /// No description provided for @ballotBackToCount.
  ///
  /// In en, this message translates to:
  /// **'Back to the count'**
  String get ballotBackToCount;

  /// No description provided for @ballotTileSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {votes, plural, =1{1 vote} other{{votes} votes}}'**
  String ballotTileSemantics(String name, int votes);

  /// No description provided for @exportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Share “{title}”'**
  String exportSheetTitle(String title);

  /// No description provided for @exportDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Data only'**
  String get exportDataLabel;

  /// No description provided for @candidateColor.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get candidateColor;

  /// No description provided for @candidateColorOption.
  ///
  /// In en, this message translates to:
  /// **'Colour {n}'**
  String candidateColorOption(int n);

  /// No description provided for @previousResultHelper.
  ///
  /// In en, this message translates to:
  /// **'The rows show how much it went up or down'**
  String get previousResultHelper;

  /// No description provided for @previousResultHintNumber.
  ///
  /// In en, this message translates to:
  /// **'E.g. {example}'**
  String previousResultHintNumber(String example);

  /// No description provided for @exportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get exportStatusInProgress;

  /// No description provided for @exportStatusFinal.
  ///
  /// In en, this message translates to:
  /// **'Final result'**
  String get exportStatusFinal;

  /// No description provided for @exportVotesPercent.
  ///
  /// In en, this message translates to:
  /// **'{votes} votes · {percent}'**
  String exportVotesPercent(String votes, String percent);

  /// No description provided for @exportMoreCandidates.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String exportMoreCandidates(String count);

  /// No description provided for @exportFooterApp.
  ///
  /// In en, this message translates to:
  /// **'Made with Voto Tracker'**
  String get exportFooterApp;

  /// No description provided for @exportShareText.
  ///
  /// In en, this message translates to:
  /// **'{title} · results'**
  String exportShareText(String title);

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'RESULTS REPORT'**
  String get pdfTitle;

  /// No description provided for @pdfExpectedVoters.
  ///
  /// In en, this message translates to:
  /// **'{count} ballots expected'**
  String pdfExpectedVoters(String count);

  /// No description provided for @pdfProvisional.
  ///
  /// In en, this message translates to:
  /// **'Provisional result: {counted} of {total} ballots counted.'**
  String pdfProvisional(String counted, String total);

  /// No description provided for @pdfWinnerDetail.
  ///
  /// In en, this message translates to:
  /// **'{votes} votes of {counted} ballots ({percent})'**
  String pdfWinnerDetail(String votes, String counted, String percent);

  /// No description provided for @pdfKeyCounted.
  ///
  /// In en, this message translates to:
  /// **'ballots counted'**
  String get pdfKeyCounted;

  /// No description provided for @pdfKeyRemaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get pdfKeyRemaining;

  /// No description provided for @pdfKeyValid.
  ///
  /// In en, this message translates to:
  /// **'valid votes'**
  String get pdfKeyValid;

  /// No description provided for @pdfKeyBlankSpoiled.
  ///
  /// In en, this message translates to:
  /// **'blank · spoiled'**
  String get pdfKeyBlankSpoiled;

  /// No description provided for @pdfKeyTurnout.
  ///
  /// In en, this message translates to:
  /// **'turnout'**
  String get pdfKeyTurnout;

  /// No description provided for @pdfCountedOf.
  ///
  /// In en, this message translates to:
  /// **'{counted} of {total}'**
  String pdfCountedOf(String counted, String total);

  /// No description provided for @pdfResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get pdfResults;

  /// No description provided for @pdfColCandidate.
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get pdfColCandidate;

  /// No description provided for @pdfColVotes.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get pdfColVotes;

  /// No description provided for @pdfColChange.
  ///
  /// In en, this message translates to:
  /// **'Compared to before'**
  String get pdfColChange;

  /// No description provided for @pdfTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get pdfTotal;

  /// No description provided for @pdfNote.
  ///
  /// In en, this message translates to:
  /// **'Percentages of the ballots counted.'**
  String get pdfNote;

  /// No description provided for @pdfNoteChange.
  ///
  /// In en, this message translates to:
  /// **'\"Compared to before\" in percentage points over the previous result.'**
  String get pdfNoteChange;

  /// No description provided for @pdfTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get pdfTrend;

  /// No description provided for @pdfTrendAxes.
  ///
  /// In en, this message translates to:
  /// **'votes · ballots counted'**
  String get pdfTrendAxes;

  /// No description provided for @pdfSignPresident.
  ///
  /// In en, this message translates to:
  /// **'The chair'**
  String get pdfSignPresident;

  /// No description provided for @pdfSignTellers.
  ///
  /// In en, this message translates to:
  /// **'The tellers'**
  String get pdfSignTellers;

  /// No description provided for @pdfPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {pages}'**
  String pdfPage(String page, String pages);

  /// No description provided for @csvPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get csvPosition;

  /// No description provided for @csvCandidate.
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get csvCandidate;

  /// No description provided for @csvType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get csvType;

  /// No description provided for @csvVotes.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get csvVotes;

  /// No description provided for @csvPercent.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get csvPercent;

  /// No description provided for @csvPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous percentage'**
  String get csvPrevious;

  /// No description provided for @csvChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get csvChange;

  /// No description provided for @csvTypeCandidate.
  ///
  /// In en, this message translates to:
  /// **'candidate'**
  String get csvTypeCandidate;

  /// No description provided for @csvTypeBlank.
  ///
  /// In en, this message translates to:
  /// **'blank'**
  String get csvTypeBlank;

  /// No description provided for @csvTypeSpoiled.
  ///
  /// In en, this message translates to:
  /// **'spoiled'**
  String get csvTypeSpoiled;

  /// No description provided for @chartTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get chartTrend;

  /// No description provided for @chartCompare.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get chartCompare;

  /// No description provided for @chartBallotsAxis.
  ///
  /// In en, this message translates to:
  /// **'Ballots counted'**
  String get chartBallotsAxis;

  /// No description provided for @chartTechnicalChip.
  ///
  /// In en, this message translates to:
  /// **'Blank and spoiled'**
  String get chartTechnicalChip;

  /// No description provided for @chartAtBallot.
  ///
  /// In en, this message translates to:
  /// **'At ballot {n}: {values}'**
  String chartAtBallot(String n, String values);

  /// No description provided for @chartAfter.
  ///
  /// In en, this message translates to:
  /// **'After {n} ballots: {values}'**
  String chartAfter(String n, String values);

  /// No description provided for @chartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Charts appear from the first vote'**
  String get chartEmpty;

  /// No description provided for @chartLegendNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get chartLegendNow;

  /// No description provided for @chartLegendPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous result'**
  String get chartLegendPrevious;

  /// No description provided for @chartPoints.
  ///
  /// In en, this message translates to:
  /// **'{value} pts'**
  String chartPoints(String value);

  /// No description provided for @chartCompareRow.
  ///
  /// In en, this message translates to:
  /// **'{name}: {percent}'**
  String chartCompareRow(String name, String percent);

  /// No description provided for @chartCompareRowChange.
  ///
  /// In en, this message translates to:
  /// **'{name}: {percent}, {change} points compared to before'**
  String chartCompareRowChange(String name, String percent, String change);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
