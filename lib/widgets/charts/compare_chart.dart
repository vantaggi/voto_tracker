import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/trend_colors.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/charts/trend_chart.dart';

/// "Confronto" (C5): barre orizzontali in ordine di classifica con la
/// percentuale, una tacca sul risultato precedente e la variazione in punti.
/// Bianche e nulle in fondo. Al posto della vecchia ciambella.
class CompareChart extends StatelessWidget {
  const CompareChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final total = provider.totalVotesAssigned;
    if (total == 0) return EmptyChartMessage(text: l10n.chartEmpty);
    final sorted = provider.sortedCandidates;
    final rows = [
      ...sorted.where((c) => !c.isTechnical),
      ...sorted.where((c) => c.isTechnical),
    ];
    final hasPrevious = rows.any(
      (c) => !c.isTechnical && c.previousPercentage != null,
    );
    // Scala: la quota più alta (o il precedente più alto), a decine.
    final top = rows.fold<double>(
      0,
      (m, c) => math.max(
        m,
        math.max(c.getPercentage(total), c.previousPercentage ?? 0),
      ),
    );
    final scale = math.max(10.0, (top / 10).ceil() * 10.0).clamp(10.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasPrevious) ...[
          ExcludeSemantics(
            child: Row(
              children: [
                SizedBox(
                  width: AppSpacing.l,
                  height: AppSpacing.s,
                  child: ColoredBox(color: cs.primary),
                ),
                const SizedBox(width: AppSpacing.s),
                Text(l10n.chartLegendNow, style: tt.labelMedium),
                const SizedBox(width: AppSpacing.l),
                SizedBox(
                  width: AppDimensions.comparePreviousTick,
                  height: AppSpacing.l,
                  child: ColoredBox(color: cs.onSurface),
                ),
                const SizedBox(width: AppSpacing.s),
                Text(l10n.chartLegendPrevious, style: tt.labelMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        for (final (i, c) in rows.indexed) ...[
          if (c.isTechnical && (i == 0 || !rows[i - 1].isTechnical))
            Divider(height: AppSpacing.l, color: cs.outlineVariant),
          _CompareRow(candidate: c, total: total, scale: scale),
          const SizedBox(height: AppSpacing.m),
        ],
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.candidate,
    required this.total,
    required this.scale,
  });

  final Candidate candidate;
  final int total;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final trend = TrendColors.of(context);
    final c = candidate;
    final name = localizedCandidateName(l10n, c);
    final now = c.getPercentage(total);
    final prev = c.isTechnical ? null : c.previousPercentage;
    final change = prev == null ? null : now - prev;
    final rounded = change == null ? null : (change * 10).round() / 10;
    String? changeText;
    if (rounded != null) {
      final sign = rounded > 0 ? '+' : (rounded < 0 ? '−' : '');
      changeText = '$sign${formatOneDecimal(context, rounded.abs())}';
    }
    final percent = formatPercent(context, now);
    return Semantics(
      label: changeText == null
          ? l10n.chartCompareRow(name, percent)
          : l10n.chartCompareRowChange(name, percent, changeText),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyLarge?.copyWith(
                      color: c.isTechnical ? cs.onSurfaceVariant : cs.onSurface,
                    ),
                  ),
                ),
                Text(percent, style: tt.titleSmall),
                if (changeText != null) ...[
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    l10n.chartPoints(changeText),
                    style: tt.labelMedium?.copyWith(
                      color: rounded! > 0
                          ? trend.positive
                          : (rounded < 0
                                ? trend.negative
                                : cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              height: AppSpacing.l,
              child: LayoutBuilder(
                builder: (context, box) {
                  final w = box.maxWidth;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: AppSpacing.xs / 2,
                        height: AppDimensions.compareBarHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              AppShapes.extraSmall,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: AppSpacing.xs / 2,
                        height: AppDimensions.compareBarHeight,
                        width: w * (now / scale).clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: c.color,
                            borderRadius: BorderRadius.circular(
                              AppShapes.extraSmall,
                            ),
                          ),
                        ),
                      ),
                      if (prev != null)
                        Positioned(
                          left:
                              w * (prev / scale).clamp(0.0, 1.0) -
                              AppDimensions.comparePreviousTick / 2,
                          top: 0,
                          bottom: 0,
                          width: AppDimensions.comparePreviousTick,
                          child: ColoredBox(color: cs.onSurface),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
