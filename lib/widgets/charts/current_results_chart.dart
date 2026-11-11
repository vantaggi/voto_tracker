import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';

class CurrentResultsChart extends StatelessWidget {
  const CurrentResultsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(
      builder: (context, provider, child) {
        final l10n = context.l10n;
        final candidates = provider.sortedCandidates;
        if (candidates.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  l10n.noDataAvailable,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        final int maxVotes = candidates.isEmpty
            ? 0
            : candidates.map((e) => e.votes).reduce((a, b) => a > b ? a : b);
        // Headroom proporzionato, mai meno di 5
        final double maxY =
            (maxVotes + (maxVotes <= 5 ? 1 : (maxVotes * 0.15).ceil()))
                .toDouble()
                .clamp(5, double.infinity);
        // Passo dell'asse Y: pochi tick leggibili (interi distinti)
        final double yInterval = maxY <= 6 ? 1 : (maxY / 5).ceilToDouble();
        final double labelWidth = candidates.length > 5 ? 44 : 72;

        return Card(
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShapes.extraLargeCard),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.l,
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colorScheme.inverseSurface,
                    tooltipPadding: const EdgeInsets.all(AppSpacing.s),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                          '${localizedCandidateName(l10n, candidates[groupIndex])}\n',
                          Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${candidates[groupIndex].votes} ${l10n.votes}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onInverseSurface
                                        .withValues(alpha: 0.8),
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ],
                        ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= candidates.length) {
                          return const SizedBox.shrink();
                        }
                        final name = localizedCandidateName(
                          l10n,
                          candidates[i],
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.s),
                          child: SizedBox(
                            width: labelWidth,
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        // Solo i tick allineati al passo, niente duplicati
                        if ((value % yInterval).abs() > 0.01) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: candidates
                    .asMap()
                    .entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.votes.toDouble(),
                            color: entry.value.color,
                            width: 24, // Thicker bars
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY,
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
