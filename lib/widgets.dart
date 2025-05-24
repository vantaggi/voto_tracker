// widgets.dart - File di widgets personalizzati e utilità

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Widget per animazioni di caricamento
class LoadingAnimation extends StatefulWidget {
  final String message;

  const LoadingAnimation({
    Key? key,
    this.message = 'Caricamento...',
  }) : super(key: key);

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 2.0 * 3.14159,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF059669),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.how_to_vote,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          Text(
            widget.message,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget per statistiche avanzate
class StatisticsPanel extends StatelessWidget {
  final int totalVotes;
  final int totalVoters;
  final String leadingCandidate;
  final int leadingVotes;
  final double turnoutPercentage;

  const StatisticsPanel({
    Key? key,
    required this.totalVotes,
    required this.totalVoters,
    required this.leadingCandidate,
    required this.leadingVotes,
    required this.turnoutPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiche Scrutinio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Affluenza',
                    '${turnoutPercentage.toStringAsFixed(1)}%',
                    Icons.people,
                    Color(0xFF059669),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Voti Scrutinati',
                    '$totalVotes/$totalVoters',
                    Icons.how_to_vote,
                    Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (leadingCandidate.isNotEmpty) _buildLeadingCandidateCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingCandidateCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF59E0B).withOpacity(0.1),
            Color(0xFFF59E0B).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFF59E0B).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In Testa',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  leadingCandidate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$leadingVotes voti',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget per il grafico di confronto
class ComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;

  const ComparisonChart({
    Key? key,
    required this.candidates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty || candidates.length < 2) {
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Color(0xFF64748B),
              ),
              SizedBox(height: 16),
              Text(
                'Confronto non disponibile',
                style: TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Prendi i primi due candidati per il confronto
    final first = candidates[0];
    final second = candidates[1];
    final gap = first['votes'] - second['votes'];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confronto Diretto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 16),
            _buildCandidateComparison(first, second, gap),
            SizedBox(height: 16),
            _buildGapIndicator(gap),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateComparison(
    Map<String, dynamic> first,
    Map<String, dynamic> second,
    int gap,
  ) {
    final maxVotes = math.max(first['votes'], 1);

    return Column(
      children: [
        _buildCandidateBar(
          first['name'],
          first['votes'],
          first['color'],
          1.0,
          true,
        ),
        SizedBox(height: 12),
        _buildCandidateBar(
          second['name'],
          second['votes'],
          second['color'],
          second['votes'] / maxVotes,
          false,
        ),
      ],
    );
  }

  Widget _buildCandidateBar(
    String name,
    int votes,
    Color color,
    double width,
    bool isLeading,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            name,
            style: TextStyle(
              fontWeight: isLeading ? FontWeight.bold : FontWeight.normal,
              color: isLeading ? color : Color(0xFF64748B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
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
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$votes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGapIndicator(int gap) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gap > 5
            ? Color(0xFF059669).withOpacity(0.1)
            : Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            gap > 5 ? Icons.trending_up : Icons.balance,
            color: gap > 5 ? Color(0xFF059669) : Color(0xFFF59E0B),
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            gap > 0
                ? 'Vantaggio: $gap voti'
                : gap < 0
                    ? 'Svantaggio: ${gap.abs()} voti'
                    : 'Pareggio perfetto',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: gap > 5 ? Color(0xFF059669) : Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget per export dei dati
class ExportPanel extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;
  final Map<String, dynamic> statistics;

  const ExportPanel({
    Key? key,
    required this.candidates,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esportazione Dati',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildExportButton(
                    'CSV',
                    Icons.table_chart,
                    () => _exportToCsv(context),
                    Color(0xFF059669),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildExportButton(
                    'JSON',
                    Icons.code,
                    () => _exportToJson(context),
                    Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildExportButton(
              'Condividi Risultati',
              Icons.share,
              () => _shareResults(context),
              Color(0xFFF59E0B),
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color color, {
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  void _exportToCsv(BuildContext context) {
    // Implementazione export CSV
    final csvData = _generateCsvData();
    _showExportDialog(context, 'CSV', csvData);
  }

  void _exportToJson(BuildContext context) {
    // Implementazione export JSON
    final jsonData = _generateJsonData();
    _showExportDialog(context, 'JSON', jsonData);
  }

  void _shareResults(BuildContext context) {
    // Implementazione condivisione
    final shareText = _generateShareText();
    _showShareDialog(context, shareText);
  }

  String _generateCsvData() {
    final buffer = StringBuffer();
    buffer.writeln('Candidato,Voti,Percentuale');

    final totalVotes = statistics['totalVotes'] ?? 0;
    for (final candidate in candidates) {
      final percentage = totalVotes > 0
          ? (candidate['votes'] / totalVotes * 100).toStringAsFixed(2)
          : '0.00';
      buffer.writeln('${candidate['name']},${candidate['votes']},$percentage%');
    }

    return buffer.toString();
  }

  String _generateJsonData() {
    return '''
{
  "timestamp": "${DateTime.now().toIso8601String()}",
  "statistics": $statistics,
  "results": $candidates
}''';
  }

  String _generateShareText() {
    final buffer = StringBuffer();
    buffer.writeln('🗳️ Risultati Scrutinio');
    buffer.writeln(
        '📊 Voti scrutinati: ${statistics['totalVotes']}/${statistics['totalVoters']}');
    buffer.writeln('');

    for (int i = 0; i < candidates.length && i < 5; i++) {
      final candidate = candidates[i];
      final medal = i == 0
          ? '🥇'
          : i == 1
              ? '🥈'
              : i == 2
                  ? '🥉'
                  : '  ';
      buffer.writeln('$medal ${candidate['name']}: ${candidate['votes']} voti');
    }

    return buffer.toString();
  }

  void _showExportDialog(BuildContext context, String format, String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Esporta in $format'),
        content: SingleChildScrollView(
          child: SelectableText(
            data,
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Chiudi'),
          ),
          ElevatedButton(
            onPressed: () {
              // Copia negli appunti
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dati copiati negli appunti!')),
              );
            },
            child: Text('Copia'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Condividi Risultati'),
        content: SelectableText(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Chiudi'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementa condivisione nativa
              Navigator.pop(context);
            },
            child: Text('Condividi'),
          ),
        ],
      ),
    );
  }
}

// Utilità per animazioni personalizzate
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;

  const SlideInAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.begin = const Offset(0, 1),
  }) : super(key: key);

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
