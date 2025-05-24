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
      home: const VotiPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Theme personalizzato con palette moderna
class AppTheme {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryTeal = Color(0xFF059669);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      background: backgroundLight,
      surface: surfaceWhite,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceWhite,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}

// Modello dati migliorato
class CandidateData {
  String name;
  int votes;
  Color color;
  List<VoteHistory> history;

  CandidateData({
    required this.name,
    required this.votes,
    required this.color,
    List<VoteHistory>? history,
  }) : history = history ?? [];

  void addVote() {
    votes++;
    history.add(VoteHistory(DateTime.now(), votes));
  }

  void removeVote() {
    if (votes > 0) {
      votes--;
      history.add(VoteHistory(DateTime.now(), votes));
    }
  }

  double getPercentage(int totalVotes) {
    return totalVotes > 0 ? (votes / totalVotes) * 100 : 0;
  }
}

class VoteHistory {
  final DateTime timestamp;
  final int totalVotes;

  VoteHistory(this.timestamp, this.totalVotes);
}

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
      _participantsCount = math.max(2, count);

  void updateShowBlankVotes(bool show) => _showBlankVotes = show;

  void updateShowNullVotes(bool show) => _showNullVotes = show;
}

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
  String winner = "";
  int totalVotesAssigned = 0;
  int remainingVotes = 0;
  int winThreshold = 0;

  // Colori predefiniti per i candidati
  static const List<Color> candidateColors = [
    Color(0xFF3B82F6), // Blu
    Color(0xFFEF4444), // Rosso
    Color(0xFF10B981), // Verde
    Color(0xFFF59E0B), // Giallo
    Color(0xFF8B5CF6), // Viola
    Color(0xFFEC4899), // Rosa
    Color(0xFF06B6D4), // Ciano
    Color(0xFFF97316), // Arancione
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeCandidates();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeCandidates() {
    candidates.clear();

    for (int i = 0; i < settings.participantsCount; i++) {
      candidates.add(CandidateData(
        name: "Candidato ${i + 1}",
        votes: 0,
        color: candidateColors[i % candidateColors.length],
      ));
    }

    if (settings.showBlankVotes) {
      candidates.add(CandidateData(
        name: "Schede Bianche",
        votes: 0,
        color: Colors.grey.shade400,
      ));
    }

    if (settings.showNullVotes) {
      candidates.add(CandidateData(
        name: "Schede Nulle",
        votes: 0,
        color: Colors.grey.shade600,
      ));
    }

    _calculateResults();
  }

  void _calculateResults() {
    candidates.sort((a, b) => b.votes.compareTo(a.votes));
    totalVotesAssigned =
        candidates.fold(0, (sum, candidate) => sum + candidate.votes);
    remainingVotes = settings.totalVoters - totalVotesAssigned;

    if (candidates.isNotEmpty && candidates.length > 1) {
      winThreshold = ((settings.totalVoters / 2) + 1).floor();

      if (candidates[0].votes >= winThreshold) {
        winner = candidates[0].name;
      } else {
        winner = "";
      }
    }
  }

  void _updateVote(int index, bool increment) {
    setState(() {
      if (increment) {
        if (totalVotesAssigned < settings.totalVoters) {
          candidates[index].addVote();
        }
      } else {
        candidates[index].removeVote();
      }
      _calculateResults();
    });

    // Aggiungi feedback tattile
    HapticFeedback.lightImpact();
  }

  void _resetVotes() {
    setState(() {
      for (var candidate in candidates) {
        candidate.votes = 0;
        candidate.history.clear();
      }
      _calculateResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.how_to_vote, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Text('Voto Tracker Pro'),
        ],
      ),
      actions: [
        _buildVotersCount(),
        _buildResetButton(),
        _buildSettingsButton(),
      ],
    );
  }

  Widget _buildVotersCount() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.secondaryTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryTeal.withOpacity(0.3)),
      ),
      child: Text(
        'Votanti: ${settings.totalVoters}',
        style: TextStyle(
          color: AppTheme.secondaryTeal,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return IconButton(
      onPressed: _showResetDialog,
      icon: Icon(Icons.refresh_rounded),
      tooltip: 'Reset voti',
    );
  }

  Widget _buildSettingsButton() {
    return IconButton(
      onPressed: _openSettings,
      icon: Icon(Icons.settings_rounded),
      tooltip: 'Impostazioni',
    );
  }

  Widget _buildBody(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) {
      return _buildDesktopLayout();
    } else if (isLandscape && screenWidth > 600) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildChartsSection(),
        ),
        Expanded(
          flex: 1,
          child: _buildControlsSection(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildChartsSection(),
        ),
        SizedBox(
          width: 300,
          child: _buildControlsSection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: _buildChartsSection(),
        ),
        _buildStatusBar(),
        Expanded(
          child: _buildControlsSection(),
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCurrentResultsChart(),
                  _buildHistoryChart(),
                  _buildPercentageChart(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textLight,
        tabs: [
          Tab(text: 'Corrente'),
          Tab(text: 'Storico'),
          Tab(text: 'Percentuali'),
        ],
      ),
    );
  }

  Widget _buildCurrentResultsChart() {
    if (candidates.isEmpty)
      return Center(child: Text('Nessun dato disponibile'));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (candidates.first.votes + 5).toDouble(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${candidates[groupIndex].name}\n${candidates[groupIndex].votes} voti',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < candidates.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          candidates[value.toInt()].name.length > 8
                              ? '${candidates[value.toInt()].name.substring(0, 8)}...'
                              : candidates[value.toInt()].name,
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: candidates.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.votes.toDouble(),
                    color: entry.value.color,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryChart() {
    if (candidates.isEmpty || candidates.every((c) => c.history.isEmpty)) {
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline, size: 48, color: AppTheme.textLight),
              SizedBox(height: 16),
              Text(
                'Nessuno storico disponibile',
                style: TextStyle(color: AppTheme.textLight),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            lineBarsData:
                candidates.where((c) => c.history.isNotEmpty).map((candidate) {
              return LineChartBarData(
                spots: candidate.history.asMap().entries.map((entry) {
                  return FlSpot(
                      entry.key.toDouble(), entry.value.totalVotes.toDouble());
                }).toList(),
                isCurved: true,
                color: candidate.color,
                barWidth: 3,
                dotData: FlDotData(show: false),
              );
            }).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
                ),
                axisNameWidget: Text('Scrutinio progressivo'),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
                axisNameWidget: Text('Voti'),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: true),
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageChart() {
    if (candidates.isEmpty || totalVotesAssigned == 0) {
      return Card(
        child: Center(
          child: Text('Nessun voto registrato'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sections: candidates.where((c) => c.votes > 0).map((candidate) {
              final percentage = candidate.getPercentage(totalVotesAssigned);
              return PieChartSectionData(
                color: candidate.color,
                value: candidate.votes.toDouble(),
                title: '${percentage.toStringAsFixed(1)}%',
                radius: 60,
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (winner.isNotEmpty)
            _buildStatusItem(
              icon: Icons.emoji_events,
              label: 'Vincitore',
              value: winner,
              color: AppTheme.accentOrange,
            )
          else
            _buildStatusItem(
              icon: Icons.flag,
              label: 'Soglia',
              value: '$winThreshold voti',
              color: AppTheme.primaryBlue,
            ),
          _buildStatusItem(
            icon: Icons.how_to_vote,
            label: 'Rimaste',
            value: '$remainingVotes',
            color: AppTheme.secondaryTeal,
          ),
          _buildStatusItem(
            icon: Icons.assessment,
            label: 'Scrutinate',
            value: '$totalVotesAssigned',
            color: AppTheme.textDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Candidati',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: candidates.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildCandidateCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(int index) {
    final candidate = candidates[index];
    final isWinner = winner == candidate.name;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner ? AppTheme.accentOrange : AppTheme.borderLight,
          width: isWinner ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Color indicator e nome
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: candidate.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      candidate.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Pulsante decremento
            _buildVoteButton(
              icon: Icons.remove,
              onPressed: () => _updateVote(index, false),
              color: Colors.red.shade400,
            ),

            SizedBox(width: 16),

            // Contatore voti
            Container(
              constraints: BoxConstraints(minWidth: 40),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: candidate.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${candidate.votes}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: candidate.color,
                  fontSize: 16,
                ),
              ),
            ),

            SizedBox(width: 16),

            // Pulsante incremento
            _buildVoteButton(
              icon: Icons.add,
              onPressed: totalVotesAssigned < settings.totalVoters
                  ? () => _updateVote(index, true)
                  : null,
              color: AppTheme.secondaryTeal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color : Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: CircleBorder(),
          elevation: onPressed != null ? 2 : 0,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conferma Reset'),
          content: Text('Sei sicuro di voler azzerare tutti i voti?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetVotes();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _openSettings() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(settings: settings),
      ),
    )
        .then((_) {
      setState(() {
        _initializeCandidates();
      });
    });
  }
}

// Settings Page rinnovata
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
    _votersController = TextEditingController(
      text: widget.settings.totalVoters.toString(),
    );
  }

  @override
  void dispose() {
    _votersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Impostazioni'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSettingsCard(
            'Configurazione Scrutinio',
            [
              _buildVotersCountSetting(),
              SizedBox(height: 16),
              _buildParticipantsCountSetting(),
            ],
          ),
          SizedBox(height: 16),
          _buildSettingsCard(
            'Opzioni Schede',
            [
              _buildToggleSetting(
                'Schede Bianche',
                widget.settings.showBlankVotes,
                (value) => setState(() {
                  widget.settings.updateShowBlankVotes(value);
                }),
              ),
              _buildToggleSetting(
                'Schede Nulle',
                widget.settings.showNullVotes,
                (value) => setState(() {
                  widget.settings.updateShowNullVotes(value);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildVotersCountSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numero Totale Votanti',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _votersController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.people),
            suffixText: 'votanti',
          ),
          onSubmitted: (value) {
            final count = int.tryParse(value) ?? widget.settings.totalVoters;
            setState(() {
              widget.settings.updateTotalVoters(count);
              _votersController.text = widget.settings.totalVoters.toString();
            });
          },
        ),
      ],
    );
  }

  Widget _buildParticipantsCountSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numero Candidati: ${widget.settings.participantsCount}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 8),
        Slider(
          value: widget.settings.participantsCount.toDouble(),
          min: 2,
          max: 8,
          divisions: 6,
          label: widget.settings.participantsCount.toString(),
          onChanged: (value) {
            setState(() {
              widget.settings.updateParticipantsCount(value.round());
            });
          },
        ),
      ],
    );
  }

  Widget _buildToggleSetting(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textDark,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryBlue,
      ),
    );
  }
}