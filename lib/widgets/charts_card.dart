import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/charts/history_chart.dart';
import 'package:voto_tracker/widgets/charts/percentage_chart.dart';

enum _Chart { history, percentages }

/// "Andamento e grafici" (R5): intestazione che apre e chiude Storico e
/// Percentuali. Chiusa sul telefono, aperta sul tablet. Il grafico "Corrente"
/// non c'è più: ripeteva i numeri delle righe.
class ChartsCard extends StatefulWidget {
  const ChartsCard({super.key, this.initiallyExpanded = false});

  final bool initiallyExpanded;

  @override
  State<ChartsCard> createState() => _ChartsCardState();
}

class _ChartsCardState extends State<ChartsCard> {
  late bool _expanded = widget.initiallyExpanded;
  _Chart _chart = _Chart.history;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Semantics(
            expanded: _expanded,
            button: true,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Row(
                  children: [
                    Icon(Icons.show_chart, color: cs.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.l),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.chartsTitle, style: tt.titleMedium),
                          Text(
                            l10n.chartsSubtitle,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.m),
          Center(
            child: SegmentedButton<_Chart>(
              segments: [
                ButtonSegment(value: _Chart.history, label: Text(l10n.history)),
                ButtonSegment(
                  value: _Chart.percentages,
                  label: Text(l10n.percentages),
                ),
              ],
              selected: {_chart},
              onSelectionChanged: (s) => setState(() => _chart = s.first),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            height: 320,
            child: _chart == _Chart.history
                ? const HistoryChart()
                : const PercentageChart(),
          ),
        ],
      ],
    );
  }
}
