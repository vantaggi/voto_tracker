import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/export_format.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/services/results_snapshot.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/vote_stacked_bar.dart';

/// Immagine da condividere (C2): 4:5, 540 × 675 dp catturati a 2x
/// (1080 × 1350 px). Titolo e data, esito, barra impilata, una riga con barra
/// per ogni candidato reale (fino a quanti ne entrano), bianche e nulle in
/// fondo. Riceve testi e numeri già pronti: si cattura fuori dall'albero.
class SocialResultsCard extends StatelessWidget {
  const SocialResultsCard({
    super.key,
    required this.snapshot,
    required this.l10n,
    required this.format,
  });

  final ResultsSnapshot snapshot;
  final AppLocalizations l10n;
  final ExportFormat format;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = snapshot;
    final technical = s.technical.toList();
    return Container(
      width: AppDimensions.socialWidth,
      height: AppDimensions.socialHeight,
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  format.shortDateTime(s.at),
                  style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              _StatusChip(complete: s.isComplete, l10n: l10n),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            s.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tt.headlineMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lPlus),
          _Outcome(snapshot: s, l10n: l10n, format: format),
          const SizedBox(height: AppSpacing.lPlus),
          VoteStackedBar(
            height: AppDimensions.socialStackedBar,
            total: math.max(s.totalVoters, s.counted),
            segments: [
              for (final r in s.rows) (color: r.color, votes: r.votes),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            [
              l10n.homeSubtitle(s.counted, s.totalVoters),
              if (s.remaining > 0) l10n.summaryRemaining(s.remaining),
            ].join(' · '),
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lPlus),
          Expanded(
            child: _Rows(snapshot: s, l10n: l10n, format: format),
          ),
          if (technical.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              technical.map((r) => '${r.name} ${r.votes}').join('   ·   '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Divider(color: cs.outlineVariant, height: 1),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Icon(
                Icons.how_to_vote_outlined,
                size: AppDimensions.iconButtonIconSize,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  l10n.exportFooterApp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Flexible(
                child: Text(
                  s.rule == VictoryRule.plurality
                      ? l10n.rulePlurality
                      : l10n.ruleAbsoluteMajority,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.complete, required this.l10n});

  final bool complete;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: complete ? cs.primary : cs.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          complete ? l10n.exportStatusFinal : l10n.exportStatusInProgress,
          style: tt.labelMedium?.copyWith(
            color: complete ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Esito: vincitore su `primaryContainer`, esito senza vincitore su
/// `tertiaryContainer`, altrimenti chi è in testa.
class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.snapshot,
    required this.l10n,
    required this.format,
  });

  final ResultsSnapshot snapshot;
  final AppLocalizations l10n;
  final ExportFormat format;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = snapshot;
    final leader = s.leader;
    final winner = s.winnerName != null && leader != null;
    if (winner || s.status.isInconclusive) {
      final bg = winner ? cs.primaryContainer : cs.tertiaryContainer;
      final fg = winner ? cs.onPrimaryContainer : cs.onTertiaryContainer;
      return Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppShapes.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizedWinnerLabel(l10n, s.status) ?? '',
              style: tt.labelLarge?.copyWith(color: fg, letterSpacing: 1.5),
            ),
            Text(
              winner
                  ? s.winnerName!
                  : localizedOutcomeHeadline(l10n, s.status, null),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.displaySmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (winner)
              Text(
                l10n.exportVotesPercent(
                  '${leader.votes}',
                  format.percent(leader.percent),
                ),
                style: tt.titleMedium?.copyWith(color: fg),
              ),
          ],
        ),
      );
    }
    final strong = tt.titleLarge?.copyWith(
      color: cs.onSurface,
      fontWeight: FontWeight.bold,
    );
    if (leader == null) {
      return Text(l10n.summaryEmptyTitle, style: strong);
    }
    final toWin = s.votesToWin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.leaderTied
              ? l10n.summaryLeadingTie
              : l10n.summaryLeading(leader.name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: strong,
        ),
        if (toWin != null && toWin > 0 && !s.leaderTied)
          Text(
            l10n.votesToWin(toWin),
            style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
      ],
    );
  }
}

/// Righe dei candidati reali: alte fino a 64 dp, più basse se sono tante;
/// quelle che non entrano diventano "+N altri".
class _Rows extends StatelessWidget {
  const _Rows({
    required this.snapshot,
    required this.l10n,
    required this.format,
  });

  final ResultsSnapshot snapshot;
  final AppLocalizations l10n;
  final ExportFormat format;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rows = snapshot.candidates.toList();
    return LayoutBuilder(
      builder: (context, box) {
        var shown = rows.length;
        var available = box.maxHeight;
        if (shown * AppDimensions.socialRowMin > available) {
          available -= AppDimensions.socialRowMin; // riga "+N altri"
          shown = math.max(1, available ~/ AppDimensions.socialRowMin);
        }
        final height = shown == 0
            ? AppDimensions.socialRowMax
            : (available / shown).clamp(
                AppDimensions.socialRowMin,
                AppDimensions.socialRowMax,
              );
        final dense = height < AppDimensions.socialRowMax - AppSpacing.m;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final r in rows.take(shown))
              SizedBox(
                height: height,
                child: _Row(row: r, format: format, dense: dense),
              ),
            if (shown < rows.length)
              Text(
                l10n.exportMoreCandidates('${rows.length - shown}'),
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row, required this.format, required this.dense});

  final ResultRow row;
  final ExportFormat format;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final first = row.rank == 1 && row.votes > 0;
    return Padding(
      padding: EdgeInsets.only(
        bottom: dense ? AppSpacing.xs / 2 : AppSpacing.m,
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.socialRankDot,
            height: AppDimensions.socialRankDot,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: row.color, shape: BoxShape.circle),
            child: Text(
              '${row.rank}',
              style: tt.titleSmall?.copyWith(
                color: CandidatePalette.onColor(row.color),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (dense ? tt.titleSmall : tt.titleMedium)
                            ?.copyWith(
                              color: cs.onSurface,
                              fontWeight: first
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                      ),
                    ),
                    Text(
                      format.percent(row.percent),
                      style: (dense ? tt.bodyMedium : tt.bodyLarge)?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(
                      width: AppDimensions.socialVotesWidth,
                      child: Text(
                        '${row.votes}',
                        textAlign: TextAlign.right,
                        style: (dense ? tt.titleMedium : tt.titleLarge)
                            ?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: dense ? AppSpacing.xs / 2 : AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppShapes.extraSmall),
                  child: SizedBox(
                    height: AppDimensions.socialBar,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: cs.surfaceContainerHigh),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (row.percent / 100).clamp(0.0, 1.0),
                          child: ColoredBox(color: row.color),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
