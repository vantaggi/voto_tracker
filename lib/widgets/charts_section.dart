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
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
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
            child: Text(AppStrings.noDataAvailable,
                style: Theme.of(context).textTheme.bodyMedium));
      }

      final theme = Theme.of(context);
      final double maxY = candidates.isEmpty
          ? 10
          : (candidates.map((e) => e.votes).reduce((a, b) => a > b ? a : b) + 5)
              .toDouble();

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingAll),
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
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
                        if (value.toInt() < candidates.length &&
                            value.toInt() >= 0) {
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
                          borderRadius: BorderRadius.circular(
                              AppDimensions.chartBarRadius))
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

      if (historyPoints.isEmpty || historyPoints.length <= 1) {
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

      final sortedHistory = historyPoints.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      // Calculate dynamic Y-axis range
      double maxY = 0;
      for (var c in candidates) {
          if (c.votes > maxY) maxY = c.votes.toDouble();
      }
      maxY = (maxY * 1.1).ceilToDouble(); // Add 10% buffering
      if (maxY < 10) maxY = 10;
      
      // Calculate max X (history length matches votes assigned usually)
      double maxX = sortedHistory.isNotEmpty ? sortedHistory.last.key.toDouble() : 10;
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppDimensions.paddingAll,
              AppDimensions.paddingAll, AppDimensions.paddingAll, 8),
          child: LineChart(
            LineChartData(
              maxY: maxY,
              maxX: maxX,
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
                      show: true, color: candidate.color.withValues(alpha: 0.1)),
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
                        interval: (maxX / 5).ceilToDouble(), // Dynamic interval
                        getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: theme.colorScheme.onSurface)))),
                leftTitles: AxisTitles(
                    axisNameWidget: Text(AppStrings.votesShort,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: theme.hintColor)),
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: (maxY / 5).ceilToDouble(), // Dynamic interval
                        getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: theme.colorScheme.onSurface)))),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  verticalInterval: (maxX / 5).ceilToDouble(),
                  horizontalInterval: (maxY / 5).ceilToDouble()),
              borderData: FlBorderData(
                  show: true, border: Border.all(color: theme.dividerColor)),
              clipData: const FlClipData.all(),
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

      if (candidates.isEmpty || totalVotes == 0) {
        return Card(
            child: Center(
                child: Text(AppStrings.noVotesRecorded,
                    style: Theme.of(context).textTheme.bodyMedium)));
      }

      return Card(
          child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingAll),
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
                            radius: 50, // Slightly thinner donut ring
                            titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white));
                      }).toList(),
                      centerSpaceRadius: 60, // Larger center for text
                      sectionsSpace: AppDimensions.chartPieSpace)),
                   Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text(
                         totalVotes.toString(),
                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       Text(
                         "totale",
                         style: Theme.of(context).textTheme.bodySmall,
                       )
                     ],
                   )
                ],
              )));
    });
  }
}
