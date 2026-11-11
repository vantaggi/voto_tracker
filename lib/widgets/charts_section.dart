import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/charts/current_results_chart.dart';
import 'package:voto_tracker/widgets/charts/history_chart.dart';
import 'package:voto_tracker/widgets/charts/percentage_chart.dart';

class ChartsSection extends StatelessWidget {
  const ChartsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingAll),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            _buildTabBar(context),
            const SizedBox(height: 16),
            const Expanded(
              child: TabBarView(
                children: [
                  CurrentResultsChart(),
                  HistoryChart(),
                  PercentageChart(),
                ],
              ),
            ),
          ],
        ),
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
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(text: context.l10n.current),
          Tab(text: context.l10n.history),
          Tab(text: context.l10n.percentages),
        ],
      ),
    );
  }
}
