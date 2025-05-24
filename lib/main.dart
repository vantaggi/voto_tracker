import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voto_tracker/utils/app_constants.dart'; // Import constants

void main() => runApp(const VotoTrackerApp());

class VotoTrackerApp extends StatelessWidget {
  const VotoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const VotiPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//========= THEME DEFINITION =========
class AppTheme {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryTeal = Color(0xFF059669);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color backgroundDark = Color(0xFF1E293B);
  static const Color surfaceDark = Color(0xFF334155);
  static const Color textWhite = Color(0xFFF8FAFC);
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF475569);

  static TextTheme _buildLightTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          fontSize: 96, fontWeight: FontWeight.w300, color: textDark),
      displayMedium: base.displayMedium?.copyWith(
          fontSize: 60, fontWeight: FontWeight.w400, color: textDark),
      displaySmall: base.displaySmall?.copyWith(
          fontSize: 48, fontWeight: FontWeight.w400, color: textDark),
      headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 34, fontWeight: FontWeight.w400, color: textDark),
      headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w400, color: textDark),
      titleLarge: base.titleLarge?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
      // Used for titles like "Statistiche Scrutinio"
      titleMedium: base.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w500, color: textDark),
      // Used for smaller titles
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, color: textDark),
      // Default body text
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, color: textDark),
      // Default body text
      labelLarge: base.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, color: primaryBlue),
      // Buttons text
      labelSmall: base.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w400, color: textLight),
    );
  }

  static TextTheme _buildDarkTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          fontSize: 96, fontWeight: FontWeight.w300, color: textWhite),
      displayMedium: base.displayMedium?.copyWith(
          fontSize: 60, fontWeight: FontWeight.w400, color: textWhite),
      displaySmall: base.displaySmall?.copyWith(
          fontSize: 48, fontWeight: FontWeight.w400, color: textWhite),
      headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 34, fontWeight: FontWeight.w400, color: textWhite),
      headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w400, color: textWhite),
      titleLarge: base.titleLarge?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w600, color: textWhite),
      titleMedium: base.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w500, color: textWhite),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, color: textWhite),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, color: textWhite),
      labelLarge: base.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, color: primaryBlue),
      labelSmall: base.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w400, color: textGrey),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      background: backgroundLight,
      surface: surfaceWhite,
      primary: primaryBlue,
      secondary: secondaryTeal,
      onSurface: textDark,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: textDark, fontSize: 20, fontWeight: FontWeight.w600)),
    cardTheme: CardTheme(
        color: surfaceWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusCard))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusButton)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12))),
    dialogTheme: DialogTheme(
        backgroundColor: surfaceWhite,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusCard))),
    textTheme: _buildLightTextTheme(ThemeData.light().textTheme),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      background: backgroundDark,
      surface: surfaceDark,
      primary: primaryBlue,
      secondary: secondaryTeal,
      onSurface: textWhite,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: textWhite, fontSize: 20, fontWeight: FontWeight.w600)),
    cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusCard))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusButton)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12))),
    dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusCard))),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusButton),
          borderSide: const BorderSide(color: borderDark)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusButton),
          borderSide: const BorderSide(color: borderDark)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusButton),
          borderSide: const BorderSide(color: primaryBlue)),
      labelStyle: const TextStyle(color: textGrey),
      prefixIconColor: textGrey,
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white)),
    textTheme: _buildDarkTextTheme(ThemeData.dark().textTheme),
  );
}

//========= DATA MODELS =========
class CandidateData {
  String name;
  int votes;
  Color color;

  CandidateData({required this.name, required this.votes, required this.color});

  double getPercentage(int totalVotes) {
    return totalVotes > 0 ? (votes / totalVotes) * 100 : 0;
  }
}

class Settings {
  int _totalVoters;
  int _participantsCount;
  bool _showBlankVotes;
  bool _showNullVotes;

  Settings(
      {int totalVoters = 100,
      int participantsCount = 4,
      bool showBlankVotes = true,
      bool showNullVotes = true})
      : _totalVoters = totalVoters,
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
}

//========= MAIN PAGE =========
class VotiPage extends StatefulWidget {
  const VotiPage({super.key});

  @override
  State<VotiPage> createState() => _VotiPageState();
}

class _VotiPageState extends State<VotiPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Settings settings = Settings();
  List<CandidateData> candidates = [];

  // MODIFICATO: Storico basato su Map per gestire le correzioni
  Map<int, Map<String, int>> historyByScrutinyCount = {};
  List<int> _historySnapshots = []; // Stores totalVotesAssigned for undo
  int _currentHistoryIndex = -1; // Points to the current state in history

  String winner = "";
  int totalVotesAssigned = 0;
  int remainingVotes = 0;
  int winThreshold = 0;

  static const List<Color> candidateColors = [
    Color(0xFF3B82F6),
    Color(0xFFEF4444),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _initializeCandidates();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeCandidates() {
    final oldNames = {for (var c in candidates) c.name: c};
    candidates.clear();
    historyByScrutinyCount.clear();
    _historySnapshots.clear();
    _currentHistoryIndex = -1;

    for (int i = 0; i < settings.participantsCount; i++) {
      final defaultName = "${AppStrings.candidatePrefix} ${i + 1}";
      candidates.add(CandidateData(
        name: oldNames.containsKey(defaultName)
            ? oldNames[defaultName]!.name
            : defaultName,
        votes: 0,
        color: candidateColors[i % candidateColors.length],
      ));
    }

    if (settings.showBlankVotes) {
      candidates.add(CandidateData(
          name: AppStrings.blankVotes, votes: 0, color: Colors.grey.shade400));
    }
    if (settings.showNullVotes) {
      candidates.add(CandidateData(
          name: AppStrings.nullVotes, votes: 0, color: Colors.grey.shade600));
    }

    _calculateResults();
    _saveCurrentStateToHistory(); // Save initial state
  }

  void _saveCurrentStateToHistory() {
    final currentVotesMap = {for (var c in candidates) c.name: c.votes};

    // If we undo and then make a change, clear any "future" history
    if (_currentHistoryIndex < _historySnapshots.length - 1) {
      _historySnapshots =
          _historySnapshots.sublist(0, _currentHistoryIndex + 1);
      historyByScrutinyCount.removeWhere((key, value) {
        return !_historySnapshots.contains(key);
      });
    }

    // Add current state
    historyByScrutinyCount[totalVotesAssigned] = currentVotesMap;
    _historySnapshots.add(totalVotesAssigned);
    _currentHistoryIndex = _historySnapshots.length - 1;
  }

  void _undoLastVote() {
    setState(() {
      if (_currentHistoryIndex > 0) {
        _currentHistoryIndex--;
        final previousTotalVotes = _historySnapshots[_currentHistoryIndex];
        final previousState = historyByScrutinyCount[previousTotalVotes];

        if (previousState != null) {
          for (var candidate in candidates) {
            candidate.votes = previousState[candidate.name] ?? 0;
          }
        }
        _calculateResults();
      }
    });
  }

  void _redoLastVote() {
    setState(() {
      if (_currentHistoryIndex < _historySnapshots.length - 1) {
        _currentHistoryIndex++;
        final nextTotalVotes = _historySnapshots[_currentHistoryIndex];
        final nextState = historyByScrutinyCount[nextTotalVotes];

        if (nextState != null) {
          for (var candidate in candidates) {
            candidate.votes = nextState[candidate.name] ?? 0;
          }
        }
        _calculateResults();
      }
    });
  }

  // LOGICA DI CALCOLO COMPLETAMENTE RIVISTA
  void _calculateResults() {
    candidates.sort((a, b) => b.votes.compareTo(a.votes));
    totalVotesAssigned =
        candidates.fold(0, (sum, candidate) => sum + candidate.votes);
    remainingVotes = settings.totalVoters - totalVotesAssigned;
    winThreshold = ((settings.totalVoters / 2) + 1).floor();
    winner = ""; // Resetta il vincitore ad ogni calcolo

    final validCandidates = candidates
        .where((c) =>
            c.name != AppStrings.blankVotes && c.name != AppStrings.nullVotes)
        .toList();

    if (validCandidates.isEmpty) return;

    // NUOVA LOGICA: VINCITORE MATEMATICO
    // Controlla se esiste un vantaggio incolmabile prima della fine dello scrutinio.
    if (validCandidates.length >= 2) {
      final firstPlace = validCandidates[0];
      final secondPlace = validCandidates[1];
      final voteGap = firstPlace.votes - secondPlace.votes;

      if (voteGap > remainingVotes) {
        winner = firstPlace.name;
        return; // Termina la funzione se c'è un vincitore matematico.
      }
    }

    // Logica di vittoria a fine scrutinio (fallback)
    if (remainingVotes == 0 && totalVotesAssigned > 0) {
      if (validCandidates.length >= 2 &&
          validCandidates[0].votes == validCandidates[1].votes &&
          validCandidates[0].votes > 0) {
        winner = AppStrings.tie;
      } else {
        winner = validCandidates.first.name;
      }
    }
  }

  // LOGICA DI AGGIORNAMENTO VOTO RIVISTA
  void _updateVote(int index, bool increment) {
    setState(() {
      if (increment) {
        if (totalVotesAssigned < settings.totalVoters) {
          candidates[index].votes++;
        }
      } else {
        if (candidates[index].votes > 0) {
          candidates[index].votes--;
        }
      }
      _calculateResults();
      _saveCurrentStateToHistory(); // Save state after each vote update
    });
    HapticFeedback.lightImpact();
  }

  void _resetVotes() {
    setState(() {
      for (var candidate in candidates) {
        candidate.votes = 0;
      }
      historyByScrutinyCount.clear(); // Pulisce anche lo storico
      _historySnapshots.clear();
      _currentHistoryIndex = -1;
      _calculateResults();
      _saveCurrentStateToHistory(); // Save the reset state
    });
  }

  void _showEditNameDialog(int index) {
    final candidate = candidates[index];
    if (candidate.name == AppStrings.blankVotes ||
        candidate.name == AppStrings.nullVotes) {
      return;
    }

    final TextEditingController nameController =
        TextEditingController(text: candidate.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.editName),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration:
                const InputDecoration(labelText: AppStrings.candidateName),
            onSubmitted: (_) {
              // Added onSubmitted
              if (nameController.text.isNotEmpty) {
                _applyNameChange(index, nameController.text);
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.cancel)),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _applyNameChange(index, nameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );
  }

  void _applyNameChange(int index, String newName) {
    setState(() {
      final oldName = candidates[index].name;
      // Update name in history (iterate over a copy to avoid concurrent modification)
      final tempHistory =
          Map<int, Map<String, int>>.from(historyByScrutinyCount);
      tempHistory.forEach((key, value) {
        if (value.containsKey(oldName)) {
          value[newName] = value[oldName]!;
          value.remove(oldName);
        }
      });
      historyByScrutinyCount = tempHistory; // Assign updated history
      candidates[index].name = newName;
      _calculateResults();
      _saveCurrentStateToHistory(); // Save the state after name change
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(opacity: _fadeAnimation, child: _buildBody(context)),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              padding: const EdgeInsets.all(AppDimensions.paddingAppBarIcon),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusCircular)),
              child: const Icon(Icons.how_to_vote,
                  color: Colors.white, size: AppDimensions.iconSizeAppBar)),
          const SizedBox(width: AppDimensions.paddingIconText),
          Expanded(
            child: Text(
              AppStrings.appTitlePro,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        _buildVotersCount(),
        IconButton(
          // Undo Button
          onPressed: _currentHistoryIndex > 0 ? _undoLastVote : null,
          icon: const Icon(Icons.undo_rounded),
          tooltip: 'Annulla ultima azione',
        ),
        IconButton(
          // Redo Button
          onPressed: _currentHistoryIndex < _historySnapshots.length - 1
              ? _redoLastVote
              : null,
          icon: const Icon(Icons.redo_rounded),
          tooltip: 'Ripeti ultima azione',
        ),
        _buildResetButton(),
        _buildSettingsButton()
      ],
    );
  }

  Widget _buildVotersCount() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingAppBarIcon, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusToggle),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Text('${AppStrings.totalVoters}: ${settings.totalVoters}',
          style: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 12)),
    );
  }

  Widget _buildResetButton() => IconButton(
      onPressed: _showResetDialog,
      icon: const Icon(Icons.refresh_rounded),
      tooltip: AppStrings.resetButtonTooltip);

  Widget _buildSettingsButton() => IconButton(
      onPressed: _openSettings,
      icon: const Icon(Icons.settings_rounded),
      tooltip: AppStrings.settingsButtonTooltip);

  Widget _buildBody(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) return _buildDesktopLayout();
    if (isLandscape && screenWidth > 600) return _buildTabletLayout();
    return _buildMobileLayout();
  }

  //========= LAYOUTS =========
  Widget _buildDesktopLayout() {
    return Row(children: [
      Expanded(flex: 2, child: _buildChartsSection()),
      Expanded(flex: 1, child: _buildControlsAndStatsSection()),
    ]);
  }

  Widget _buildTabletLayout() {
    return Row(children: [
      Expanded(child: _buildChartsSection()),
      const SizedBox(width: 350, child: Text('')),
      // Placeholder for now, original was SizedBox(width: 350, child: _buildControlsAndStatsSection()),
      // this will be handled by the next section below
      SizedBox(width: 350, child: _buildControlsAndStatsSection()),
    ]);
  }

  Widget _buildMobileLayout() {
    return Column(children: [
      SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: _buildChartsSection()),
      Expanded(child: _buildControlsAndStatsSection()),
    ]);
  }

  //========= UI SECTIONS =========
  Widget _buildChartsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.paddingAll,
          AppDimensions.paddingAll, AppDimensions.paddingAll, 0),
      child: DefaultTabController(
        length: 3,
        child: Column(children: [
          _buildTabBar(),
          Expanded(
              child: TabBarView(children: [
            _buildCurrentResultsChart(),
            _buildHistoryChart(),
            _buildPercentageChart()
          ])),
        ]),
      ),
    );
  }

  Widget _buildControlsAndStatsSection() {
    final leadingCandidate = candidates.isNotEmpty ? candidates[0] : null;
    final turnout = settings.totalVoters > 0
        ? (totalVotesAssigned / settings.totalVoters) * 100
        : 0.0;
    List<Map<String, dynamic>> candidateMap = candidates
        .map((c) => {'name': c.name, 'votes': c.votes, 'color': c.color})
        .toList();
    Map<String, dynamic> statsMap = {
      'totalVotes': totalVotesAssigned,
      'totalVoters': settings.totalVoters,
      'turnout': turnout
    };

    return ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingAll),
        children: [
          if (winner.isNotEmpty && winner != AppStrings.tie)
            Card(
          color: AppTheme.accentOrange.withOpacity(0.1),
          child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingAll),
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                    const Icon(Icons.emoji_events,
                        color: AppTheme.accentOrange,
                        size: AppDimensions.statIconSize),
                    const SizedBox(width: AppDimensions.paddingIconText),
                    Column(
                  children: [
                        Text(AppStrings.winner,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: AppTheme.accentOrange,
                            fontWeight: FontWeight.bold)),
                    Text(winner,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      StatisticsPanel(
          totalVotes: totalVotesAssigned,
          totalVoters: settings.totalVoters,
          leadingCandidate: leadingCandidate?.name ?? "N/A",
          leadingVotes: leadingCandidate?.votes ?? 0,
          turnoutPercentage: turnout),
          const SizedBox(height: AppDimensions.paddingAll),
          ComparisonChart(candidates: candidateMap),
          const SizedBox(height: AppDimensions.paddingAll),
          Text(AppStrings.candidatePrefix,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.paddingAll),
          ...List.generate(
          candidates.length, (index) => _buildCandidateCard(index)),
          const SizedBox(height: AppDimensions.paddingAll),
          ExportPanel(candidates: candidateMap, statistics: statsMap)
    ]);
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingAll),
      decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.8),
          borderRadius:
              BorderRadius.circular(AppDimensions.borderRadiusButton)),
      child: TabBar(
        indicator: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusButton)),
        labelColor: Colors.white,
        unselectedLabelColor: theme.unselectedWidgetColor,
        tabs: const [
          Tab(text: AppStrings.current),
          Tab(text: AppStrings.history),
          Tab(text: AppStrings.percentages)
        ],
      ),
    );
  }

  //========= CHARTS =========
  Widget _buildCurrentResultsChart() {
    if (candidates.isEmpty) {
      return Center(
          child: Text(AppStrings.noDataAvailable,
              style: Theme.of(context).textTheme.bodyMedium));
    }
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingAll),
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (candidates.first.votes + 5).toDouble(),
          barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                          '${candidates[groupIndex].name}\n${candidates[groupIndex].votes} ${AppStrings.votes}',
                          const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)))),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < candidates.length) {
                        final name = candidates[value.toInt()].name;
                        return Padding(
                            padding: const EdgeInsets.only(
                                top: AppDimensions.paddingAppBarIcon),
                            child: Text(
                                name.length > 8
                                    ? '${name.substring(0, 8)}...'
                                    : name,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: theme.colorScheme.onSurface)));
                      }
                      return const Text('');
                    })),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: theme.colorScheme.onSurface)))),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: candidates
              .asMap()
              .entries
              .map((entry) => BarChartGroupData(x: entry.key, barRods: [
                    BarChartRodData(
                        toY: entry.value.votes.toDouble(),
                        color: entry.value.color,
                        width: AppDimensions.chartBarWidth,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.chartBarRadius))
                  ]))
              .toList(),
        )),
      ),
    );
  }

  // GRAFICO STORICO COMPLETAMENTE MODIFICATO
  Widget _buildHistoryChart() {
    final theme = Theme.of(context);
    if (historyByScrutinyCount.isEmpty || _historySnapshots.length <= 1) {
      // Only show history if there's actual change
      return Card(
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            Icon(Icons.timeline, size: 48, color: theme.hintColor),
            const SizedBox(height: AppDimensions.paddingAll),
            Text(AppStrings.noHistoryAvailable,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: theme.hintColor))
          ])));
    }

    final sortedHistory = historyByScrutinyCount.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppDimensions.paddingAll,
            AppDimensions.paddingAll, AppDimensions.paddingAll, 8),
        child: LineChart(
          LineChartData(
            lineBarsData: candidates
                .where((c) =>
                    c.name != AppStrings.blankVotes &&
                    c.name != AppStrings.nullVotes)
                .map((candidate) {
              return LineChartBarData(
                spots: sortedHistory.map((entry) {
                  final x = entry.key.toDouble();
                  final y = entry.value[candidate.name]?.toDouble() ?? 0.0;
                  return FlSpot(x, y);
                }).toList(),
                isCurved: true,
                color: candidate.color,
                barWidth: AppDimensions.chartLineBarWidth,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                    show: true, color: candidate.color.withOpacity(0.1)),
              );
            }).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                  axisNameWidget: Text(AppStrings.scrutinisedVotes,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: theme.hintColor)),
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: theme.colorScheme.onSurface)))),
              leftTitles: AxisTitles(
                  axisNameWidget: Text(AppStrings.votesShort,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: theme.hintColor)),
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: theme.colorScheme.onSurface)))),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 10,
                horizontalInterval: 5),
            borderData: FlBorderData(
                show: true, border: Border.all(color: theme.dividerColor)),
            clipData: const FlClipData.all(),
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageChart() {
    if (candidates.isEmpty || totalVotesAssigned == 0) {
      return Card(
          child: Center(
              child: Text(AppStrings.noVotesRecorded,
                  style: Theme.of(context).textTheme.bodyMedium)));
    }

    return Card(
        child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingAll),
            child: PieChart(PieChartData(
                sections: candidates.where((c) => c.votes > 0).map((candidate) {
                  final percentage =
                      candidate.getPercentage(totalVotesAssigned);
                  return PieChartSectionData(
                      color: candidate.color,
                      value: candidate.votes.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: AppDimensions.chartPieRadius,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white));
                }).toList(),
                centerSpaceRadius: AppDimensions.chartPieCenterSpaceRadius,
                sectionsSpace: AppDimensions.chartPieSpace))));
  }

  Widget _buildCandidateCard(int index) {
    final candidate = candidates[index];
    final isWinner = winner == candidate.name;
    final theme = Theme.of(context);
    final isEditable = candidate.name != AppStrings.blankVotes &&
        candidate.name != AppStrings.nullVotes;

    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCard),
          border: Border.all(
              color: isWinner ? AppTheme.accentOrange : theme.dividerColor,
              width: isWinner ? 2 : 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingAll),
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: Row(children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: candidate.color, shape: BoxShape.circle)),
                    const SizedBox(width: AppDimensions.paddingIconText),
                    Expanded(
                        child: Text(candidate.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis)),
                  ])),
              if (isEditable)
                _buildVoteButton(
                    icon: Icons.edit,
                    onPressed: () => _showEditNameDialog(index),
                    color: theme.hintColor),
              if (isEditable)
                const SizedBox(width: AppDimensions.paddingAppBarIcon),
              _buildVoteButton(
                  icon: Icons.remove,
                  onPressed: () => _updateVote(index, false),
                  color: Colors.red.shade400),
              const SizedBox(width: AppDimensions.paddingAll),
              Container(
                  constraints: const BoxConstraints(minWidth: 40),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: AppDimensions.paddingAppBarIcon),
                  decoration: BoxDecoration(
                      color: candidate.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusToggle)),
                  child: Text('${candidate.votes}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: candidate.color,
                          fontSize: 16))),
              const SizedBox(width: AppDimensions.paddingAll),
              _buildVoteButton(
                  icon: Icons.add,
                  onPressed: totalVotesAssigned < settings.totalVoters
                      ? () => _updateVote(index, true)
                      : null,
                  color: AppTheme.secondaryTeal)
            ])));
  }

  Widget _buildVoteButton(
      {required IconData icon,
      required VoidCallback? onPressed,
      required Color color}) {
    return SizedBox(
        width: AppDimensions.iconButtonSize,
        height: AppDimensions.iconButtonSize,
        child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    onPressed != null ? color : Theme.of(context).disabledColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                elevation: onPressed != null ? 2 : 0),
            child: Icon(icon, size: AppDimensions.iconButtonIconSize)));
  }

  void _showResetDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: const Text(AppStrings.confirmReset),
                content: const Text(AppStrings.resetConfirmation),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(AppStrings.cancel)),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetVotes();
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text(AppStrings.reset))
                ]));
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => SettingsPage(settings: settings)))
        .then((_) => setState(() => _initializeCandidates()));
  }
}

//========= SETTINGS PAGE =========
class SettingsPage extends StatefulWidget {
  final Settings settings;
  const SettingsPage({super.key, required this.settings});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _votersController;

  @override
  void initState() {
    super.initState();
    _votersController =
        TextEditingController(text: widget.settings.totalVoters.toString());
  }

  @override
  void dispose() {
    _votersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.settingsButtonTooltip)),
        body: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingAll),
            children: [
              _buildSettingsCard(AppStrings.scrutinyConfiguration, [
                _buildVotersCountSetting(),
                const SizedBox(height: AppDimensions.paddingAll),
                _buildParticipantsCountSetting()
          ]),
              const SizedBox(height: AppDimensions.paddingAll),
              _buildSettingsCard(AppStrings.cardOptions, [
                _buildToggleSetting(
                    AppStrings.blankVotes,
                    widget.settings.showBlankVotes,
                    (value) => setState(
                        () => widget.settings.updateShowBlankVotes(value))),
                _buildToggleSetting(
                    AppStrings.nullVotes,
                    widget.settings.showNullVotes,
                    (value) => setState(() => widget.settings.updateShowNullVotes(value)))
          ])
        ]));
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingAll),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimensions.paddingAll),
              ...children
            ])));
  }

  Widget _buildVotersCountSetting() {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppStrings.totalVotersNumber,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
      const SizedBox(height: AppDimensions.paddingAppBarIcon),
      TextField(
          controller: _votersController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          // Only allow digits
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.people),
              suffixText: AppStrings.totalVoters),
          onSubmitted: (value) {
            final count = int.tryParse(value) ?? widget.settings.totalVoters;
            setState(() {
              widget.settings.updateTotalVoters(count);
              _votersController.text = widget.settings.totalVoters.toString();
            });
          })
    ]);
  }

  Widget _buildParticipantsCountSetting() {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          '${AppStrings.participantsCount}: ${widget.settings.participantsCount}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
      const SizedBox(height: AppDimensions.paddingAppBarIcon),
      Slider(
          value: widget.settings.participantsCount.toDouble(),
          min: AppStrings.minParticipants.toDouble(),
          max: AppStrings.maxParticipants.toDouble(),
          divisions: AppStrings.maxParticipants - AppStrings.minParticipants,
          label: widget.settings.participantsCount.toString(),
          onChanged: (value) => setState(
              () => widget.settings.updateParticipantsCount(value.round())))
    ]);
  }

  Widget _buildToggleSetting(
      String title, bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface)),
        trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary));
  }
}

class StatisticsPanel extends StatelessWidget {
  final int totalVotes;
  final int totalVoters;
  final String leadingCandidate;
  final int leadingVotes;
  final double turnoutPercentage;

  const StatisticsPanel({super.key,
    required this.totalVotes,
    required this.totalVoters,
    required this.leadingCandidate,
    required this.leadingVotes,
    required this.turnoutPercentage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
        margin: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingAppBarIcon),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Statistiche Scrutinio',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimensions.paddingAll),
              Row(children: [
                Expanded(
                    child: _buildStatItem(
                        context,
                        'Affluenza',
                        '${turnoutPercentage.toStringAsFixed(1)}%',
                        Icons.people,
                        AppTheme.secondaryTeal)),
                const SizedBox(width: AppDimensions.paddingIconText),
                Expanded(
                    child: _buildStatItem(
                        context,
                        AppStrings.scrutinisedVotes,
                        '$totalVotes/$totalVoters',
                        Icons.how_to_vote,
                        AppTheme.primaryBlue))
              ]),
              const SizedBox(height: AppDimensions.paddingIconText),
              if (leadingCandidate.isNotEmpty &&
                  leadingCandidate != AppStrings.blankVotes &&
                  leadingCandidate != AppStrings.nullVotes)
                _buildLeadingCandidateCard(context)
            ])));
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
        padding: const EdgeInsets.all(AppDimensions.statItemPadding),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusButton)),
        child: Column(children: [
          Icon(icon, color: color, size: AppDimensions.statIconSize),
          const SizedBox(height: AppDimensions.statItemSpacing),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Theme.of(context).hintColor))
        ]));
  }

  Widget _buildLeadingCandidateCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingAll),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.accentOrange.withOpacity(0.1),
              AppTheme.accentOrange.withOpacity(0.05)
            ]),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusButton),
            border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3))),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(AppDimensions.paddingAppBarIcon),
              decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusCircular)),
              child: const Icon(Icons.emoji_events,
                  color: Colors.white, size: AppDimensions.iconSizeAppBar)),
          const SizedBox(width: AppDimensions.paddingIconText),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(AppStrings.lead,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: theme.hintColor)),
                Text(leadingCandidate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface))
              ])),
          Text('$leadingVotes ${AppStrings.votes}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentOrange))
        ]));
  }
}

class ComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;

  const ComparisonChart({super.key, required this.candidates});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validCandidates = candidates
        .where((c) =>
            c['name'] != AppStrings.blankVotes &&
            c['name'] != AppStrings.nullVotes)
        .toList();

    if (validCandidates.length < AppStrings.minParticipants) {
      return Card(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingAll),
                  child: Text(AppStrings.comparisonNotAvailable,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: theme.hintColor)))));
    }
    final first = validCandidates[0];
    final second = validCandidates[1];
    final gap = first['votes'] - second['votes'];

    return Card(
        margin: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingAppBarIcon),
        child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingAll),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Confronto Diretto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface)),
              const SizedBox(height: AppDimensions.paddingAll),
              _buildCandidateBar(context, first['name'] as String,
                  first['votes'] as int, first['color'] as Color, 1.0, true),
              const SizedBox(height: AppDimensions.paddingIconText),
              _buildCandidateBar(
                  context,
                  second['name'] as String,
                  second['votes'] as int,
                  second['color'] as Color,
                  (first['votes'] > 0
                      ? (second['votes'] as int) / (first['votes'] as int)
                      : 0.0),
                  false),
              const SizedBox(height: AppDimensions.paddingAll),
              _buildGapIndicator(gap)
            ])));
  }

  Widget _buildCandidateBar(BuildContext context, String name, int votes,
      Color color, double width, bool isLeading) {
    return Row(children: [
      SizedBox(
          width: AppDimensions.comparisonNameWidth,
          child: Text(name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isLeading ? FontWeight.bold : FontWeight.normal,
                  color: isLeading ? color : Theme.of(context).hintColor),
              overflow: TextOverflow.ellipsis)),
      const SizedBox(width: AppDimensions.paddingIconText),
      Expanded(
          child: Container(
              height: AppDimensions.comparisonBarHeight,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusButton)),
              child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: width,
                  child: Container(
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusButton),
                          boxShadow: isLeading
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2))
                                ]
                              : null),
                      child: Center(
                          child: Text('$votes',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)))))))
    ]);
  }

  Widget _buildGapIndicator(int gap) {
    final isAdvantage = gap > 0;
    final color = isAdvantage ? AppTheme.secondaryTeal : AppTheme.accentOrange;
    return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingIconText),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusCircular)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isAdvantage ? Icons.trending_up : Icons.balance,
              color: color, size: 16),
          const SizedBox(width: AppDimensions.paddingAppBarIcon),
          Text(
              gap != 0
                  ? '${AppStrings.advantage}: $gap ${AppStrings.votes}'
                  : AppStrings.tie,
              style: TextStyle(fontWeight: FontWeight.w600, color: color))
        ]));
  }
}

class ExportPanel extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;
  final Map<String, dynamic> statistics;

  const ExportPanel(
      {super.key, required this.candidates, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingAppBarIcon),
        child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingAll),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppStrings.exportData,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: AppDimensions.paddingAll),
              Row(children: [
                Expanded(
                    child: _buildExportButton('CSV', Icons.table_chart,
                        () => _exportToCsv(context), AppTheme.secondaryTeal)),
                const SizedBox(width: AppDimensions.paddingIconText),
                Expanded(
                    child: _buildExportButton('JSON', Icons.code,
                        () => _exportToJson(context), AppTheme.primaryBlue))
              ])
            ])));
  }

  Widget _buildExportButton(
      String label, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusCircular)),
            padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: AppDimensions.paddingAll)));
  }

  void _exportToCsv(BuildContext context) {
    final buffer = StringBuffer()..writeln('Candidato,Voti,Percentuale');
    final totalVotes = statistics['totalVotes'] as int? ?? 0;
    for (final candidate in candidates) {
      final percentage = totalVotes > 0
          ? ((candidate['votes'] as int) / totalVotes * 100).toStringAsFixed(2)
          : '0.00';
      buffer.writeln('${candidate['name']},${candidate['votes']},$percentage%');
    }
    _showExportDialog(context, 'CSV', buffer.toString());
  }

  void _exportToJson(BuildContext context) {
    final jsonData =
        '{\n  "timestamp": "${DateTime.now().toIso8601String()}",\n  "statistics": $statistics,\n  "results": $candidates\n}';
    _showExportDialog(context, 'JSON', jsonData);
  }

  void _showExportDialog(BuildContext context, String format, String data) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('${AppStrings.exportTo} $format'),
                content: SingleChildScrollView(
                    child: SelectableText(data,
                        style: const TextStyle(fontFamily: 'monospace'))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppStrings.close)),
                  ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: data)).then((_) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(AppStrings.dataCopied)));
                        });
                      },
                      child: const Text(AppStrings.copy))
                ]));
  }
}