import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/services/results_snapshot.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// "Andamento" (C5): una linea a gradini per candidato (il voto arriva a
/// scatti, niente curve), chip con nome e voti che fanno da legenda e
/// accendono o spengono le linee, asse "Schede contate" con tacche intere.
/// Toccando o trascinando in orizzontale si leggono i voti a una scheda.
class TrendChart extends StatefulWidget {
  const TrendChart({super.key});

  /// Linee accese all'inizio al massimo (le altre si accendono dai chip).
  static const int maxInitialLines = 8;

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  /// Indici dei candidati con la linea spenta; `null` = scelta iniziale.
  Set<int>? _hidden;
  bool _showTechnical = false;

  /// Scheda letta toccando il grafico.
  int? _scrub;

  Set<int> _initialHidden(List<Candidate> candidates, List<int> ranked) {
    final real = ranked.where((i) => !candidates[i].isTechnical).toList();
    return real.skip(TrendChart.maxInitialLines).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final candidates = provider.candidates;
    final history = provider.history;
    final counted = history.length - 1;
    if (counted == 0) {
      return EmptyChartMessage(text: l10n.chartEmpty);
    }
    final ranked = [
      for (final c in provider.sortedCandidates) candidates.indexOf(c),
    ];
    final hidden = _hidden ??= _initialHidden(candidates, ranked);
    bool visible(int i) =>
        candidates[i].isTechnical ? _showTechnical : !hidden.contains(i);
    final shown = [
      for (final i in ranked)
        if (visible(i)) i,
    ];
    final top = shown.fold<int>(0, (m, i) => math.max(m, candidates[i].votes));
    final yStep = niceAxisStep(math.max(1, top), maxTicks: 4);
    final maxY = ((top ~/ yStep) + 1) * yStep.toDouble();
    final xStep = niceAxisStep(counted, maxTicks: 5).toDouble();
    final scrub = _scrub?.clamp(0, counted);
    final at = scrub ?? counted;
    final values = [
      for (final i in shown)
        '${localizedCandidateName(l10n, candidates[i])} ${history[at][i]}',
    ].join(' · ');
    final caption = scrub == null
        ? l10n.chartAfter('$counted', values)
        : l10n.chartAtBallot('$scrub', values);
    final axisStyle = tt.labelSmall?.copyWith(color: cs.onSurfaceVariant);
    final hasTechnical = candidates.any((c) => c.isTechnical);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final i in ranked)
              if (!candidates[i].isTechnical)
                FilterChip(
                  selected: !hidden.contains(i),
                  showCheckmark: false,
                  avatar: CircleAvatar(
                    backgroundColor: candidates[i].color,
                    radius: AppDimensions.chartLegendDot,
                  ),
                  label: Text(
                    '${localizedCandidateName(l10n, candidates[i])} '
                    '${candidates[i].votes}',
                  ),
                  onSelected: (on) => setState(() {
                    on ? hidden.remove(i) : hidden.add(i);
                  }),
                ),
            if (hasTechnical)
              FilterChip(
                selected: _showTechnical,
                showCheckmark: false,
                label: Text(l10n.chartTechnicalChip),
                onSelected: (on) => setState(() => _showTechnical = on),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        Semantics(
          label: '${l10n.chartTrend}. $caption',
          child: SizedBox(
            height: AppDimensions.trendChartHeight,
            child: LayoutBuilder(
              builder: (context, box) {
                void read(Offset p) {
                  final plot = box.maxWidth - AppDimensions.chartAxisReserved;
                  final x =
                      ((p.dx - AppDimensions.chartAxisReserved) / plot) *
                      counted;
                  setState(() => _scrub = x.round().clamp(0, counted));
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => read(d.localPosition),
                  onHorizontalDragStart: (d) => read(d.localPosition),
                  onHorizontalDragUpdate: (d) => read(d.localPosition),
                  child: LineChart(
                    duration: Duration.zero,
                    LineChartData(
                      minX: 0,
                      maxX: counted.toDouble(),
                      minY: 0,
                      maxY: maxY,
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        for (final i in shown)
                          LineChartBarData(
                            spots: [
                              for (var k = 0; k < history.length; k++)
                                FlSpot(k.toDouble(), history[k][i].toDouble()),
                            ],
                            isStepLineChart: true,
                            color: candidates[i].color,
                            barWidth: AppDimensions.chartLineBarWidth,
                            dotData: const FlDotData(show: false),
                          ),
                      ],
                      extraLinesData: ExtraLinesData(
                        verticalLines: [
                          if (scrub != null)
                            VerticalLine(
                              x: scrub.toDouble(),
                              color: cs.outline,
                              strokeWidth: 1,
                              dashArray: const [4, 4],
                            ),
                        ],
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: yStep.toDouble(),
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: cs.outlineVariant, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: yStep.toDouble(),
                            reservedSize: AppDimensions.chartAxisReserved,
                            getTitlesWidget: (v, meta) =>
                                Text('${v.toInt()}', style: axisStyle),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: Text(
                            l10n.chartBallotsAxis,
                            style: tt.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: xStep,
                            reservedSize: AppDimensions.chartBottomReserved,
                            getTitlesWidget: (v, meta) => v % xStep == 0
                                ? Text('${v.toInt()}', style: axisStyle)
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        ExcludeSemantics(
          child: Text(
            caption,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Messaggio dei grafici prima del primo voto (Andamento e Confronto).
class EmptyChartMessage extends StatelessWidget {
  const EmptyChartMessage({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(Icons.show_chart, size: AppSpacing.xxxl, color: cs.outline),
          const SizedBox(height: AppSpacing.m),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
