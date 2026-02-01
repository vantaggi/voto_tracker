import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class ChartsSection extends StatelessWidget {
  const ChartsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingAll),
      child: DefaultTabController(
        length: 3,
        child: Column(children: [
          _buildTabBar(context),
          const SizedBox(height: 16),
          const Expanded(
              child: TabBarView(children: [
            _CurrentResultsChart(),
            _HistoryChart(),
            _PercentageChart()
          ])),
        ]),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.15),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: AppStrings.current),
          Tab(text: AppStrings.history),
          Tab(text: AppStrings.percentages),
        ],
      ),
    );
  }
}

class _CurrentResultsChart extends StatelessWidget {
  const _CurrentResultsChart();

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(builder: (context, provider, child) {
      final candidates = provider.sortedCandidates;
      if (candidates.isEmpty) {
        return Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(AppStrings.noDataAvailable,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ],
        ));
      }

      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      
      final double maxY = candidates.isEmpty
          ? 10
          : (candidates.map((e) => e.votes).reduce((a, b) => a > b ? a : b) + 5)
              .toDouble();

      return Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colorScheme.inverseSurface,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                            '${candidates[groupIndex].name}\n',
                            TextStyle(
                                color: colorScheme.onInverseSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '${candidates[groupIndex].votes} ${AppStrings.votes}',
                                style: TextStyle(
                                  color: colorScheme.onInverseSurface.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal
                                )
                              )
                            ]
                        ))),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80, // Increased space for labels
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < candidates.length &&
                            value.toInt() >= 0) {
                          final name = candidates[value.toInt()].name;
                          return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Transform.rotate(
                                angle: -0.5, // Rotated for better fit
                                child: Text(
                                    name.length > 15
                                        ? '${name.substring(0, 15)}...'
                                        : name,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600)),
                              ));
                        }
                        return const SizedBox.shrink();
                      })),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant)))),
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
                          width: 24, // Thicker bars
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          backDrawRodData: BackgroundBarChartRodData(
                             show: true,
                             toY: maxY,
                             color: colorScheme.surfaceContainerHighest.withOpacity(0.5)
                          )
                      )
                    ]))
                .toList(),
          )),
        ),
      );
    });
  }
}

class _HistoryChart extends StatelessWidget {
  const _HistoryChart();

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(builder: (context, provider, child) {
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
              Text(AppStrings.noHistoryAvailable,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant))
            ])));
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
      
      double maxX = sortedHistory.isNotEmpty ? sortedHistory.last.key.toDouble() : 10;
      
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
                final isTechnical = candidate.name == AppStrings.blankVotes || candidate.name == AppStrings.nullVotes;
                
                return LineChartBarData(
                  spots: sortedHistory.map((entry) {
                    final x = entry.key.toDouble();
                    final y = entry.value[candidate.name]?.toDouble() ?? 0.0;
                    return FlSpot(x, y);
                  }).toList(),
                  isCurved: true,
                  curveSmoothness: 0.2,
                  preventCurveOverShooting: true,
                  color: candidate.color,
                  barWidth: isTechnical ? 2 : 3, // Thinner for technical votes
                  isStrokeCapRound: true,
                  dashArray: isTechnical ? [5, 5] : null, // Dashed for technical votes
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: !isTechnical, // Only fill area for real candidates to reduce noise
                      color: candidate.color.withOpacity(0.05) 
                  ),
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                    axisNameWidget: Text(AppStrings.scrutinisedVotes,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                    sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxX / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall
                                ?.copyWith(
                                    color: colorScheme.onSurfaceVariant)))),
                leftTitles: AxisTitles(
                    axisNameWidget: Text(AppStrings.votesShort,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (maxY / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall
                                ?.copyWith(
                                    color: colorScheme.onSurfaceVariant)))),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                     color: colorScheme.outlineVariant.withOpacity(0.5), strokeWidth: 1, dashArray: [4, 4]
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                     color: colorScheme.outlineVariant.withOpacity(0.5), strokeWidth: 1, dashArray: [4, 4]
                  ),
                  verticalInterval: (maxX / 5).ceilToDouble(),
                  horizontalInterval: (maxY / 5).ceilToDouble()),
              borderData: FlBorderData(
                  show: true, 
                  border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5))
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => colorScheme.inverseSurface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      return LineTooltipItem(
                        '${touchedSpot.y.toInt()}',
                         TextStyle(
                            color: touchedSpot.bar.color ?? colorScheme.onInverseSurface,
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
    });
  }
}

class _PercentageChart extends StatelessWidget {
  const _PercentageChart();

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(builder: (context, provider, child) {
      final candidates = provider.sortedCandidates;
      final totalVotes = provider.totalVotesAssigned;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      if (candidates.isEmpty || totalVotes == 0) {
        return Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pie_chart_outline, size: 48, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(AppStrings.noVotesRecorded,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant
                        )),
                  ],
                )));
      }

      return Card(
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   PieChart(PieChartData(
                      sections:
                          candidates.where((c) => c.votes > 0).map((candidate) {
                        final percentage = candidate.getPercentage(totalVotes);
                        return PieChartSectionData(
                            color: candidate.color,
                            value: candidate.votes.toDouble(),
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 70, // Thicker ring
                            titleStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _getContrastColor(candidate.color),
                            ),
                            badgeWidget: _buildBadge(context, candidate.name, candidate.color),
                            badgePositionPercentageOffset: 1.25,
                            borderSide: BorderSide(color: colorScheme.surfaceContainerLow, width: 2)
                        );
                      }).toList(),
                      centerSpaceRadius: 60,
                      sectionsSpace: 2, // Small gap
                   )),
                   Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text(
                         totalVotes.toString(),
                         style: theme.textTheme.displayMedium?.copyWith(
                           fontWeight: FontWeight.w800,
                           color: colorScheme.onSurface,
                           height: 1.0
                         ),
                       ),
                       Text(
                         "VOTI TOTALI",
                         style: theme.textTheme.labelMedium?.copyWith(
                             color: colorScheme.onSurfaceVariant,
                             letterSpacing: 1.5,
                             fontWeight: FontWeight.bold
                         ),
                       )
                     ],
                   )
                ],
              )));
    });
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
              boxShadow: [
                  BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2)
                  )
              ]
          ),
          child: Text(text, style: TextStyle(
              fontSize: 11, 
              color: colorScheme.onSurfaceVariant, 
              fontWeight: FontWeight.w600
          ))
      );
  }

  Color _getContrastColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
