import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';

class HistoryChart extends StatelessWidget {
  const HistoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(
      builder: (context, provider, child) {
        final l10n = context.l10n;
        final historyPoints = provider.historyPoints;
        final candidates = provider.candidates;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        if (historyPoints.isEmpty || historyPoints.length <= 1) {
          return Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 48, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noHistoryAvailable,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final sortedHistory = historyPoints.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        // Calculate dynamic Y-axis range
        double maxY = 0;
        for (var c in candidates) {
          if (c.votes > maxY) maxY = c.votes.toDouble();
        }
        maxY = (maxY * 1.1).ceilToDouble();
        if (maxY < 10) maxY = 10;

        double maxX = sortedHistory.isNotEmpty
            ? sortedHistory.last.key.toDouble()
            : 10;

        return Card(
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
            child: LineChart(
              LineChartData(
                maxY: maxY,
                maxX: maxX,
                lineBarsData: candidates
                    // Removed filter to show all candidates including Blank/Null
                    .map((candidate) {
                      final isTechnical = candidate.isTechnical;

                      return LineChartBarData(
                        spots: sortedHistory.map((entry) {
                          final x = entry.key.toDouble();
                          final y =
                              entry.value[candidate.name]?.toDouble() ?? 0.0;
                          return FlSpot(x, y);
                        }).toList(),
                        isCurved: true,
                        curveSmoothness: 0.2,
                        preventCurveOverShooting: true,
                        color: candidate.color,
                        barWidth: isTechnical
                            ? 2
                            : 3, // Thinner for technical votes
                        isStrokeCapRound: true,
                        dashArray: isTechnical
                            ? [5, 5]
                            : null, // Dashed for technical votes
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: !isTechnical, // Only fill area for real candidates to reduce noise
                          color: candidate.color.withValues(alpha: 0.05),
                        ),
                      );
                    })
                    .toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      l10n.scrutinisedVotes,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxX / 5).ceilToDouble(),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      l10n.votesShort,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (maxY / 5).ceilToDouble(),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  verticalInterval: (maxX / 5).ceilToDouble(),
                  horizontalInterval: (maxY / 5).ceilToDouble(),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colorScheme.inverseSurface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          '${touchedSpot.y.toInt()}',
                          TextStyle(
                            color:
                                touchedSpot.bar.color ??
                                colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
