import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(VotoTrackerApp());

class VotoTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voto Tracker Pro',
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
  // ... (invariato)
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
    appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: textDark, fontSize: 20, fontWeight: FontWeight.w600)),
    cardTheme: CardTheme(
        color: surfaceWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12))),
    dialogTheme: DialogTheme(
        backgroundColor: surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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
    appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: textWhite, fontSize: 20, fontWeight: FontWeight.w600)),
    cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12))),
    dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDark)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDark)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue)),
      labelStyle: TextStyle(color: textGrey),
      prefixIconColor: textGrey,
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white)),
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
  // ... (invariato)
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
      _participantsCount = math.max(2, count);
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

    for (int i = 0; i < settings.participantsCount; i++) {
      final defaultName = "Candidato ${i + 1}";
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
          name: "Schede Bianche", votes: 0, color: Colors.grey.shade400));
    }
    if (settings.showNullVotes) {
      candidates.add(CandidateData(
          name: "Schede Nulle", votes: 0, color: Colors.grey.shade600));
    }

    _calculateResults();
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
        .where((c) => c.name != "Schede Bianche" && c.name != "Schede Nulle")
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
        winner = "Pareggio";
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

      // MODIFICATO: Lo storico ora usa una Map per gestire le correzioni
      final currentVotes = {for (var c in candidates) c.name: c.votes};
      historyByScrutinyCount[totalVotesAssigned] = currentVotes;

      // Rimuove la storia "futura" se si torna indietro con i voti
      historyByScrutinyCount
          .removeWhere((key, value) => key > totalVotesAssigned);
    });
    HapticFeedback.lightImpact();
  }

  void _resetVotes() {
    setState(() {
      for (var candidate in candidates) {
        candidate.votes = 0;
      }
      historyByScrutinyCount.clear(); // Pulisce anche lo storico
      _calculateResults();
    });
  }

  void _showEditNameDialog(int index) {
    // ... (invariato)
    final candidate = candidates[index];
    if (candidate.name == "Schede Bianche" || candidate.name == "Schede Nulle")
      return;

    final TextEditingController nameController =
        TextEditingController(text: candidate.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifica Nome'),
          content: TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Nome Candidato')),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Annulla')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    // Aggiorna il nome anche nello storico se necessario
                    final oldName = candidates[index].name;
                    final newName = nameController.text;
                    historyByScrutinyCount.forEach((key, value) {
                      if (value.containsKey(oldName)) {
                        value[newName] = value[oldName]!;
                        value.remove(oldName);
                      }
                    });
                    candidates[index].name = newName;
                    _calculateResults();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (invariato)
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(opacity: _fadeAnimation, child: _buildBody(context)),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // ... (invariato)
    return AppBar(
      title: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.how_to_vote, color: Colors.white, size: 20)),
        SizedBox(width: 12),
        Text('Voto Tracker Pro'),
      ]),
      actions: [
        _buildVotersCount(),
        _buildResetButton(),
        _buildSettingsButton()
      ],
    );
  }

  Widget _buildVotersCount() {
    // ... (invariato)
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Text('Votanti: ${settings.totalVoters}',
          style: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 12)),
    );
  }

  Widget _buildResetButton() => IconButton(
      onPressed: _showResetDialog,
      icon: Icon(Icons.refresh_rounded),
      tooltip: 'Reset voti');

  Widget _buildSettingsButton() => IconButton(
      onPressed: _openSettings,
      icon: Icon(Icons.settings_rounded),
      tooltip: 'Impostazioni');

  Widget _buildBody(BuildContext context) {
    // ... (invariato)
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) return _buildDesktopLayout();
    if (isLandscape && screenWidth > 600) return _buildTabletLayout();
    return _buildMobileLayout();
  }

  //========= LAYOUTS =========
  Widget _buildDesktopLayout() {
    // ... (invariato)
    return Row(children: [
      Expanded(flex: 2, child: _buildChartsSection()),
      Expanded(flex: 1, child: _buildControlsAndStatsSection()),
    ]);
  }

  Widget _buildTabletLayout() {
    // ... (invariato)
    return Row(children: [
      Expanded(child: _buildChartsSection()),
      SizedBox(width: 350, child: _buildControlsAndStatsSection()),
    ]);
  }

  Widget _buildMobileLayout() {
    // ... (invariato)
    return Column(children: [
      SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: _buildChartsSection()),
      Expanded(child: _buildControlsAndStatsSection()),
    ]);
  }

  //========= UI SECTIONS =========
  Widget _buildChartsSection() {
    // ... (invariato)
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
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
    // ... (invariato)
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

    return ListView(padding: EdgeInsets.all(16), children: [
      if (winner.isNotEmpty && winner != "Pareggio")
        Card(
          color: AppTheme.accentOrange.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events,
                    color: AppTheme.accentOrange, size: 24),
                SizedBox(width: 12),
                Column(
                  children: [
                    Text('VINCITORE',
                        style: TextStyle(
                            color: AppTheme.accentOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    Text(winner,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
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
      SizedBox(height: 16),
      ComparisonChart(candidates: candidateMap),
      SizedBox(height: 16),
      Text('Candidati',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface)),
      SizedBox(height: 16),
      ...List.generate(
          candidates.length, (index) => _buildCandidateCard(index)),
      SizedBox(height: 16),
      ExportPanel(candidates: candidateMap, statistics: statsMap)
    ]);
  }

  Widget _buildTabBar() {
    // ... (invariato)
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        indicator: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.white,
        unselectedLabelColor: theme.unselectedWidgetColor,
        tabs: [
          Tab(text: 'Corrente'),
          Tab(text: 'Storico'),
          Tab(text: 'Percentuali')
        ],
      ),
    );
  }

  //========= CHARTS =========
  Widget _buildCurrentResultsChart() {
    // ... (invariato)
    if (candidates.isEmpty)
      return Center(child: Text('Nessun dato disponibile'));
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (candidates.first.votes + 5).toDouble(),
          barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                          '${candidates[groupIndex].name}\n${candidates[groupIndex].votes} voti',
                          TextStyle(
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
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                                name.length > 8
                                    ? '${name.substring(0, 8)}...'
                                    : name,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurface)));
                      }
                      return Text('');
                    })),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface)))),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: candidates
              .asMap()
              .entries
              .map((entry) => BarChartGroupData(x: entry.key, barRods: [
                    BarChartRodData(
                        toY: entry.value.votes.toDouble(),
                        color: entry.value.color,
                        width: 20,
                        borderRadius: BorderRadius.circular(4))
                  ]))
              .toList(),
        )),
      ),
    );
  }

  // GRAFICO STORICO COMPLETAMENTE MODIFICATO
  Widget _buildHistoryChart() {
    final theme = Theme.of(context);
    if (historyByScrutinyCount.isEmpty) {
      return Card(
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            Icon(Icons.timeline, size: 48, color: theme.hintColor),
            SizedBox(height: 16),
            Text('Nessuno storico disponibile',
                style: TextStyle(color: theme.hintColor))
          ])));
    }

    final sortedHistory = historyByScrutinyCount.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: LineChart(
          LineChartData(
            lineBarsData: candidates
                .where((c) =>
                    c.name != "Schede Bianche" && c.name != "Schede Nulle")
                .map((candidate) {
              return LineChartBarData(
                spots: sortedHistory.map((entry) {
                  final x = entry.key.toDouble();
                  final y = entry.value[candidate.name]?.toDouble() ?? 0.0;
                  return FlSpot(x, y);
                }).toList(),
                isCurved: true,
                color: candidate.color,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                    show: true, color: candidate.color.withOpacity(0.1)),
              );
            }).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                  axisNameWidget: Text("Voti Scrutinati",
                      style: TextStyle(color: theme.hintColor, fontSize: 10)),
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface)))),
              leftTitles: AxisTitles(
                  axisNameWidget: Text("Voti",
                      style: TextStyle(color: theme.hintColor, fontSize: 10)),
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface)))),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 10,
                horizontalInterval: 5),
            borderData: FlBorderData(
                show: true, border: Border.all(color: theme.dividerColor)),
            clipData: FlClipData.all(),
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageChart() {
    // ... (invariato)
    if (candidates.isEmpty || totalVotesAssigned == 0)
      return Card(child: Center(child: Text('Nessun voto registrato')));

    return Card(
        child: Padding(
            padding: EdgeInsets.all(16),
            child: PieChart(PieChartData(
                sections: candidates.where((c) => c.votes > 0).map((candidate) {
                  final percentage =
                      candidate.getPercentage(totalVotesAssigned);
                  return PieChartSectionData(
                      color: candidate.color,
                      value: candidate.votes.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white));
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2))));
  }

  Widget _buildCandidateCard(int index) {
    // ... (invariato)
    final candidate = candidates[index];
    final isWinner = winner == candidate.name;
    final theme = Theme.of(context);
    final isEditable =
        candidate.name != "Schede Bianche" && candidate.name != "Schede Nulle";

    return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isWinner ? AppTheme.accentOrange : theme.dividerColor,
              width: isWinner ? 2 : 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: Row(children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: candidate.color, shape: BoxShape.circle)),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(candidate.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis)),
                  ])),
              if (isEditable)
                _buildVoteButton(
                    icon: Icons.edit,
                    onPressed: () => _showEditNameDialog(index),
                    color: theme.hintColor),
              if (isEditable) SizedBox(width: 8),
              _buildVoteButton(
                  icon: Icons.remove,
                  onPressed: () => _updateVote(index, false),
                  color: Colors.red.shade400),
              SizedBox(width: 16),
              Container(
                  constraints: BoxConstraints(minWidth: 40),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: candidate.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${candidate.votes}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: candidate.color,
                          fontSize: 16))),
              SizedBox(width: 16),
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
    // ... (invariato)
    return SizedBox(
        width: 36,
        height: 36,
        child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    onPressed != null ? color : Theme.of(context).disabledColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: CircleBorder(),
                elevation: onPressed != null ? 2 : 0),
            child: Icon(icon, size: 18)));
  }

  void _showResetDialog() {
    // ... (invariato)
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: Text('Conferma Reset'),
                content: Text('Sei sicuro di voler azzerare tutti i voti?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Annulla')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetVotes();
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Reset'))
                ]));
  }

  void _openSettings() {
    // ... (invariato)
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => SettingsPage(settings: settings)))
        .then((_) => setState(() => _initializeCandidates()));
  }
}

//========= SETTINGS PAGE =========
// (Questa parte è rimasta invariata)
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
        appBar: AppBar(title: Text('Impostazioni')),
        body: ListView(padding: EdgeInsets.all(16), children: [
          _buildSettingsCard('Configurazione Scrutinio', [
            _buildVotersCountSetting(),
            SizedBox(height: 16),
            _buildParticipantsCountSetting()
          ]),
          SizedBox(height: 16),
          _buildSettingsCard('Opzioni Schede', [
            _buildToggleSetting(
                'Schede Bianche',
                widget.settings.showBlankVotes,
                (value) => setState(
                    () => widget.settings.updateShowBlankVotes(value))),
            _buildToggleSetting(
                'Schede Nulle',
                widget.settings.showNullVotes,
                (value) =>
                    setState(() => widget.settings.updateShowNullVotes(value)))
          ])
        ]));
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Card(
        child: Padding(
            padding: EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface)),
              SizedBox(height: 16),
              ...children
            ])));
  }

  Widget _buildVotersCountSetting() {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Numero Totale Votanti',
          style: TextStyle(
              fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
      SizedBox(height: 8),
      TextField(
          controller: _votersController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.people), suffixText: 'votanti'),
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
      Text('Numero Candidati: ${widget.settings.participantsCount}',
          style: TextStyle(
              fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
      SizedBox(height: 8),
      Slider(
          value: widget.settings.participantsCount.toDouble(),
          min: 2,
          max: 8,
          divisions: 6,
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
            style: TextStyle(
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

  const StatisticsPanel(
      {Key? key,
      required this.totalVotes,
      required this.totalVoters,
      required this.leadingCandidate,
      required this.leadingVotes,
      required this.turnoutPercentage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
            padding: EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Statistiche Scrutinio',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface)),
              SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _buildStatItem(
                        context,
                        'Affluenza',
                        '${turnoutPercentage.toStringAsFixed(1)}%',
                        Icons.people,
                        AppTheme.secondaryTeal)),
                SizedBox(width: 12),
                Expanded(
                    child: _buildStatItem(
                        context,
                        'Voti Scrutinati',
                        '$totalVotes/$totalVoters',
                        Icons.how_to_vote,
                        AppTheme.primaryBlue))
              ]),
              SizedBox(height: 12),
              if (leadingCandidate.isNotEmpty &&
                  leadingCandidate != "Schede Bianche" &&
                  leadingCandidate != "Schede Nulle")
                _buildLeadingCandidateCard(context)
            ])));
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style:
                  TextStyle(fontSize: 12, color: Theme.of(context).hintColor))
        ]));
  }

  Widget _buildLeadingCandidateCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.accentOrange.withOpacity(0.1),
              AppTheme.accentOrange.withOpacity(0.05)
            ]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3))),
        child: Row(children: [
          Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.emoji_events, color: Colors.white, size: 20)),
          SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('In Testa',
                    style: TextStyle(fontSize: 12, color: theme.hintColor)),
                Text(leadingCandidate,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface))
              ])),
          Text('$leadingVotes voti',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentOrange))
        ]));
  }
}

class ComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;

  const ComparisonChart({Key? key, required this.candidates}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validCandidates = candidates
        .where(
            (c) => c['name'] != "Schede Bianche" && c['name'] != "Schede Nulle")
        .toList();

    if (validCandidates.length < 2) {
      return Card(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Confronto non disponibile (meno di 2 candidati)',
                      style: TextStyle(color: theme.hintColor)))));
    }
    final first = validCandidates[0];
    final second = validCandidates[1];
    final gap = first['votes'] - second['votes'];

    return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
            padding: EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Confronto Diretto',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface)),
              SizedBox(height: 16),
              _buildCandidateBar(context, first['name'], first['votes'],
                  first['color'], 1.0, true),
              SizedBox(height: 12),
              _buildCandidateBar(
                  context,
                  second['name'],
                  second['votes'],
                  second['color'],
                  (first['votes'] > 0 ? second['votes'] / first['votes'] : 0.0),
                  false),
              SizedBox(height: 16),
              _buildGapIndicator(gap)
            ])));
  }

  Widget _buildCandidateBar(BuildContext context, String name, int votes,
      Color color, double width, bool isLeading) {
    return Row(children: [
      SizedBox(
          width: 80,
          child: Text(name,
              style: TextStyle(
                  fontWeight: isLeading ? FontWeight.bold : FontWeight.normal,
                  color: isLeading ? color : Theme.of(context).hintColor),
              overflow: TextOverflow.ellipsis)),
      SizedBox(width: 12),
      Expanded(
          child: Container(
              height: 24,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12)),
              child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: width,
                  child: Container(
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isLeading
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: Offset(0, 2))
                                ]
                              : null),
                      child: Center(
                          child: Text('$votes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)))))))
    ]);
  }

  Widget _buildGapIndicator(int gap) {
    final isAdvantage = gap > 0;
    final color = isAdvantage ? AppTheme.secondaryTeal : AppTheme.accentOrange;
    return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isAdvantage ? Icons.trending_up : Icons.balance,
              color: color, size: 16),
          SizedBox(width: 8),
          Text(gap != 0 ? 'Vantaggio: $gap voti' : 'Pareggio',
              style: TextStyle(fontWeight: FontWeight.w600, color: color))
        ]));
  }
}

class ExportPanel extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;
  final Map<String, dynamic> statistics;

  const ExportPanel(
      {Key? key, required this.candidates, required this.statistics})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
            padding: EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Esportazione Dati',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _buildExportButton('CSV', Icons.table_chart,
                        () => _exportToCsv(context), AppTheme.secondaryTeal)),
                SizedBox(width: 12),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16)));
  }

  void _exportToCsv(BuildContext context) {
    final buffer = StringBuffer()..writeln('Candidato,Voti,Percentuale');
    final totalVotes = statistics['totalVotes'] ?? 0;
    for (final candidate in candidates) {
      final percentage = totalVotes > 0
          ? (candidate['votes'] / totalVotes * 100).toStringAsFixed(2)
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
                title: Text('Esporta in $format'),
                content: SingleChildScrollView(
                    child: SelectableText(data,
                        style: TextStyle(fontFamily: 'monospace'))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Chiudi')),
                  ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: data)).then((_) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Dati copiati negli appunti!')));
                        });
                      },
                      child: Text('Copia'))
                ]));
  }
}