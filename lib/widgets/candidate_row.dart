import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';
import 'package:voto_tracker/theme/trend_colors.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/edit_candidate_dialog.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Candidati reali in una sola card, una riga ciascuno (R3). L'ordine resta
/// quello di inserimento: il + non si sposta sotto il dito dopo un voto, la
/// posizione in classifica è nel pallino.
class CandidateGroup extends StatelessWidget {
  const CandidateGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final candidates = context.watch<ScrutinyProvider>().candidates;
    return _RowsCard(
      indexes: [
        for (var i = 0; i < candidates.length; i++)
          if (!candidates[i].isTechnical) i,
      ],
    );
  }
}

/// Schede bianche e nulle (R3): stessa funzione dei candidati, righe più basse
/// e + tonale, sotto il titolo "Altre schede".
class OtherBallotsGroup extends StatelessWidget {
  const OtherBallotsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final candidates = context.watch<ScrutinyProvider>().candidates;
    final indexes = [
      for (var i = 0; i < candidates.length; i++)
        if (candidates[i].isTechnical) i,
    ];
    if (indexes.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: Semantics(
            header: true,
            child: Text(
              context.l10n.otherBallots,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ),
        _RowsCard(indexes: indexes, compact: true),
      ],
    );
  }
}

class _RowsCard extends StatelessWidget {
  const _RowsCard({required this.indexes, this.compact = false});

  final List<int> indexes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var k = 0; k < indexes.length; k++) ...[
            if (k > 0) Divider(indent: compact ? 64 : 72),
            CandidateRow(index: indexes[k], compact: compact),
          ],
        ],
      ),
    );
  }
}

/// Una riga di conteggio: pallino (colore e posizione), nome, percentuale con
/// tendenza e barretta della quota; a destra −, voti e + pieno da 56 dp.
/// Toccare il nome apre "Modifica nome".
class CandidateRow extends StatelessWidget {
  const CandidateRow({super.key, required this.index, this.compact = false});

  final int index;

  /// Schede bianche e nulle: riga più bassa, + tonale da 48 dp.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final c = provider.candidates[index];
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final name = localizedCandidateName(l10n, c);
    final total = provider.totalVotesAssigned;
    final pct = c.getPercentage(total);
    final percent = formatPercent(context, pct);
    final canAdd = provider.remainingVotes > 0;

    void vote(bool increment) {
      HapticFeedback.selectionClick();
      context.read<ScrutinyProvider>().vote(index, increment: increment);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: compact ? 64 : 84),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.s,
        ),
        child: Row(
          children: [
            _RankDot(candidate: c, compact: compact),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Tooltip(
                message: l10n.editName,
                triggerMode: TooltipTriggerMode.manual,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppShapes.small),
                  onTap: () => showEditCandidateDialog(context, index),
                  child: Semantics(
                    label: l10n.candidateRowSemantics(name, c.votes, percent),
                    excludeSemantics: true,
                    child: _NameAndShare(
                      candidate: c,
                      name: name,
                      percent: percent,
                      share: pct / 100,
                      showTrend: total > 0,
                      compact: compact,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: c.votes > 0 ? () => vote(false) : null,
              icon: Icon(Icons.remove, semanticLabel: l10n.removeVoteFor(name)),
            ),
            SizedBox(
              width: 48,
              child: ExcludeSemantics(
                child: Text(
                  '${c.votes}',
                  textAlign: TextAlign.center,
                  style: (compact ? tt.titleLarge : tt.headlineSmall)?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: _tabular,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            compact
                ? IconButton.filledTonal(
                    onPressed: canAdd ? () => vote(true) : null,
                    style: IconButton.styleFrom(
                      minimumSize: const Size.square(AppTouch.minTarget),
                    ),
                    icon: Icon(Icons.add, semanticLabel: l10n.addVoteFor(name)),
                  )
                : IconButton.filled(
                    onPressed: canAdd ? () => vote(true) : null,
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      minimumSize: const Size.square(56),
                    ),
                    icon: Icon(Icons.add, semanticLabel: l10n.addVoteFor(name)),
                  ),
          ],
        ),
      ),
    );
  }
}

class _RankDot extends StatelessWidget {
  const _RankDot({required this.candidate, required this.compact});

  final Candidate candidate;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final showRank = !compact && candidate.rank > 0 && candidate.votes > 0;
    return ExcludeSemantics(
      child: CircleAvatar(
        radius: compact ? 16 : 20,
        backgroundColor: candidate.color,
        child: showRank
            ? Text(
                '${candidate.rank}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: CandidatePalette.onColor(candidate.color),
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}

class _NameAndShare extends StatelessWidget {
  const _NameAndShare({
    required this.candidate,
    required this.name,
    required this.percent,
    required this.share,
    required this.showTrend,
    required this.compact,
  });

  final Candidate candidate;
  final String name;
  final String percent;
  final double share;
  final bool showTrend;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final previous = candidate.previousPercentage;
    final delta = showTrend && previous != null
        ? candidate.getPercentage(
                context.read<ScrutinyProvider>().totalVotesAssigned,
              ) -
              previous
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: compact ? tt.titleSmall : tt.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.s,
            children: [
              Text(
                percent,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontFeatures: _tabular,
                ),
              ),
              if (delta != null) _Trend(delta: delta),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppShapes.extraSmall),
              child: SizedBox(
                height: 4,
                child: ColoredBox(
                  color: cs.surfaceContainerHighest,
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: share.clamp(0.0, 1.0),
                    child: ColoredBox(color: candidate.color),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Freccia e punti percentuali rispetto al risultato precedente.
class _Trend extends StatelessWidget {
  const _Trend({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    final trend = TrendColors.of(context);
    final color = delta >= 0 ? trend.positive : trend.negative;
    final points = formatPercent(context, delta.abs());
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          delta >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
          size: 14,
          color: color,
        ),
        Text(
          points.substring(0, points.length - 1),
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
