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
    Locale('it')
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
  /// **'Share social image'**
  String get shareImageTitle;

  /// No description provided for @shareImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optimized for Instagram/WhatsApp'**
  String get shareImageSubtitle;

  /// No description provided for @exportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Export PDF report'**
  String get exportPdfTitle;

  /// No description provided for @exportPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Official document with charts'**
  String get exportPdfSubtitle;

  /// No description provided for @exportCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvTitle;

  /// No description provided for @exportCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Table for spreadsheets'**
  String get exportCsvSubtitle;

  /// No description provided for @exportJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJsonTitle;

  /// No description provided for @exportJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full structured data'**
  String get exportJsonSubtitle;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportError;

  /// No description provided for @scrutinisedVotes.
  ///
  /// In en, this message translates to:
  /// **'Counted votes'**
  String get scrutinisedVotes;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @votesTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL VOTES'**
  String get votesTotal;

  /// No description provided for @waitingForData.
  ///
  /// In en, this message translates to:
  /// **'Waiting for data...'**
  String get waitingForData;

  /// No description provided for @votesToWin.
  ///
  /// In en, this message translates to:
  /// **'{count} votes left to win'**
  String votesToWin(int count);

  /// No description provided for @votes.
  ///
  /// In en, this message translates to:
  /// **'votes'**
  String get votes;

  /// No description provided for @votesShort.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get votesShort;

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

  /// No description provided for @winnerFallback.
  ///
  /// In en, this message translates to:
  /// **'WINNER'**
  String get winnerFallback;

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
  /// **'Edit name'**
  String get editName;

  /// No description provided for @candidateName.
  ///
  /// In en, this message translates to:
  /// **'Candidate name'**
  String get candidateName;

  /// No description provided for @previousResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous result (%)'**
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

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @percentages.
  ///
  /// In en, this message translates to:
  /// **'Percentages'**
  String get percentages;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @noHistoryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get noHistoryAvailable;

  /// No description provided for @noVotesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No votes recorded'**
  String get noVotesRecorded;

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

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'HOLD TO RESET'**
  String get resetButton;

  /// No description provided for @scrutinyConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Scrutiny configuration'**
  String get scrutinyConfiguration;

  /// No description provided for @totalVotersNumber.
  ///
  /// In en, this message translates to:
  /// **'Total number of voters'**
  String get totalVotersNumber;

  /// No description provided for @votersHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. 100'**
  String get votersHint;

  /// No description provided for @participantsCount.
  ///
  /// In en, this message translates to:
  /// **'Number of candidates'**
  String get participantsCount;

  /// No description provided for @votingOptions.
  ///
  /// In en, this message translates to:
  /// **'Voting options'**
  String get votingOptions;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get dataManagement;

  /// No description provided for @exportLabel.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportLabel;

  /// No description provided for @importLabel.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importLabel;

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

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL SCRUTINY REPORT'**
  String get reportSubtitle;

  /// No description provided for @completion.
  ///
  /// In en, this message translates to:
  /// **'COMPLETION'**
  String get completion;

  /// No description provided for @completionShort.
  ///
  /// In en, this message translates to:
  /// **'COMPL.'**
  String get completionShort;

  /// No description provided for @rankingTitle.
  ///
  /// In en, this message translates to:
  /// **'RANKING'**
  String get rankingTitle;

  /// No description provided for @trendTitle.
  ///
  /// In en, this message translates to:
  /// **'VOTE TREND'**
  String get trendTitle;

  /// No description provided for @insufficientData.
  ///
  /// In en, this message translates to:
  /// **'Insufficient data'**
  String get insufficientData;

  /// No description provided for @colPosition.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get colPosition;

  /// No description provided for @colCandidate.
  ///
  /// In en, this message translates to:
  /// **'CANDIDATE'**
  String get colCandidate;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get colStatus;

  /// No description provided for @leader.
  ///
  /// In en, this message translates to:
  /// **'LEADER'**
  String get leader;

  /// No description provided for @generatedWithPro.
  ///
  /// In en, this message translates to:
  /// **'Generated with Voto Tracker Pro'**
  String get generatedWithPro;

  /// No description provided for @pageFooter.
  ///
  /// In en, this message translates to:
  /// **'Page 1 of 1'**
  String get pageFooter;

  /// No description provided for @updateLabel.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get updateLabel;

  /// No description provided for @liveScrutiny.
  ///
  /// In en, this message translates to:
  /// **'LIVE SCRUTINY'**
  String get liveScrutiny;

  /// No description provided for @partialRanking.
  ///
  /// In en, this message translates to:
  /// **'PARTIAL RANKING'**
  String get partialRanking;

  /// No description provided for @generatedWith.
  ///
  /// In en, this message translates to:
  /// **'Generated with Voto Tracker'**
  String get generatedWith;

  /// No description provided for @countedShort.
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get countedShort;
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
      'that was used.');
}
