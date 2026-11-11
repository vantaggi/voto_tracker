import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';

class PercentageChart extends StatelessWidget {
  const PercentageChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(
      builder: (context, provider, child) {
        final l10n = context.l10n;
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
                  Icon(
                    Icons.pie_chart_outline,
                    size: 48,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noVotesRecorded,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
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
                PieChart(
                  PieChartData(
                    sections: candidates.where((c) => c.votes > 0).map((
                      candidate,
                    ) {
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
                        badgeWidget: _buildBadge(
                          context,
                          localizedCandidateName(l10n, candidate),
                          candidate.color,
                        ),
                        badgePositionPercentageOffset: 1.25,
                        borderSide: BorderSide(
                          color: colorScheme.surfaceContainerLow,
                          width: 2,
                        ),
                      );
                    }).toList(),
                    centerSpaceRadius: 60,
                    sectionsSpace: 2, // Small gap
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalVotes.toString(),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      l10n.votesTotal,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
