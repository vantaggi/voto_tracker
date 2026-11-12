import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/app_theme.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/keep_screen_on.dart';
import 'package:voto_tracker/widgets/vote_stacked_bar.dart';

/// Altezza minima e massima di una riga della classifica.
const double _minRowHeight = 56;
const double _maxRowHeight = 160;

/// Spazio tra le righe.
const double _rowGap = AppSpacing.s;

/// Per quanto resta visibile la × dopo un tocco.
const Duration _controlsTimeout = Duration(seconds: 3);

/// Durata del riordino animato delle righe.
const Duration _reorderDuration = Duration(milliseconds: 450);

/// Modalità proiettore (ridisegno S5): schermo intero senza barre di sistema,
/// tema scuro, intestazione con titolo, schede e barra impilata, classifica
/// che riempie l'altezza e si riordina con un'animazione. Bianche e nulle
/// stanno in una riga a parte in fondo (D4). Un tocco mostra la × per uscire.
/// P9: una riga parlata per candidato, esito annunciato appena cambia,
/// testo di sistema limitato a 1,5x e nessun overflow sul telefono.
class ProjectorModeScreen extends StatefulWidget {
  const ProjectorModeScreen({super.key});

  @override
  State<ProjectorModeScreen> createState() => _ProjectorModeScreenState();
}

class _ProjectorModeScreenState extends State<ProjectorModeScreen> {
  bool _controls = true;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _scheduleHide();
  }

  @override
  void dispose() {
    _hide?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _scheduleHide() {
    _hide?.cancel();
    _hide = Timer(_controlsTimeout, () {
      if (mounted) setState(() => _controls = false);
    });
  }

  void _showControls() {
    setState(() => _controls = true);
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    // Tema scuro sempre: più contrasto nelle stanze buie.
    return KeepScreenOn(
      child: Theme(
        data: context.read<AppThemes>().dark,
        child: Builder(
          builder: (context) {
            final cs = Theme.of(context).colorScheme;
            // I testi sono già enormi: oltre 1,5x uscirebbero dallo schermo.
            return MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.5,
              child: Scaffold(
                backgroundColor: cs.surface,
                body: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _showControls,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: SafeArea(child: _ProjectorBody()),
                      ),
                      Positioned(
                        top: AppSpacing.l,
                        right: AppSpacing.l,
                        child: SafeArea(
                          child: AnimatedOpacity(
                            opacity: _controls ? 1 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: IgnorePointer(
                              ignoring: !_controls,
                              child: IconButton.filledTonal(
                                tooltip: MaterialLocalizations.of(context)
                                    .closeButtonTooltip,
                                onPressed: () => Navigator.maybePop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProjectorBody extends StatelessWidget {
  const _ProjectorBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AppDimensions.compactBreakpoint;
        final side = compact ? AppSpacing.l : AppSpacing.xxl;
        return Padding(
          padding: EdgeInsets.fromLTRB(side, AppSpacing.l, side, AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(provider: provider, compact: compact),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: _Ranking(provider: provider, compact: compact),
              ),
              _TechnicalFooter(provider: provider),
            ],
          ),
        );
      },
    );
  }
}

/// Titolo, schede contate, barra impilata ed esito.
class _Header extends StatelessWidget {
  const _Header({required this.provider, required this.compact});

  final ScrutinyProvider provider;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final scrutiny = provider.currentScrutiny;
    final label = provider.hasWinner
        ? localizedWinnerLabel(l10n, provider.winnerStatus)
        : null;
    final outcomeColor = provider.isInconclusive ? cs.tertiary : cs.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // Lascia posto alla ×.
          padding: const EdgeInsets.only(right: AppTouch.minTarget),
          child: Text(
            scrutiny == null
                ? l10n.projectorMode
                : scrutinyDisplayTitle(context, scrutiny),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (compact ? tt.titleLarge : tt.headlineSmall)?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          [
            l10n.homeSubtitle(
              provider.totalVotesAssigned,
              provider.settings.totalVoters,
            ),
            if (provider.remainingVotes > 0)
              l10n.summaryRemaining(provider.remainingVotes)
            else
              l10n.summaryCompleted,
          ].join(' · '),
          style: (compact ? tt.titleMedium : tt.headlineSmall)?.copyWith(
            color: cs.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        VoteStackedBar(
          total: provider.settings.totalVoters,
          height: AppSpacing.m,
          segments: [
            for (final c in [
              ...provider.sortedCandidates.where((c) => !c.isTechnical),
              ...provider.candidates.where((c) => c.isTechnical),
            ])
              (color: c.color, votes: c.votes),
          ],
        ),
        if (label != null) ...[
          const SizedBox(height: AppSpacing.l),
          // P9: l'esito viene annunciato appena cambia.
          Semantics(
            liveRegion: true,
            container: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label  ',
                    style: tt.titleLarge?.copyWith(
                      color: outcomeColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: localizedOutcomeHeadline(
                      l10n,
                      provider.winnerStatus,
                      provider.winnerName,
                    ),
                    style: (compact ? tt.headlineMedium : tt.displaySmall)
                        ?.copyWith(
                          color: outcomeColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Classifica dei candidati: le righe si dividono l'altezza (56–160dp) e si
/// spostano con un'animazione quando cambia l'ordine.
class _Ranking extends StatelessWidget {
  const _Ranking({required this.provider, required this.compact});

  final ScrutinyProvider provider;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final all = provider.candidates;
    final ranked = provider.sortedCandidates
        .where((c) => !c.isTechnical)
        .toList();
    final counted = provider.totalVotesAssigned;
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = ranked.length;
        final rowHeight = ((constraints.maxHeight - _rowGap * (n - 1)) / n)
            .clamp(_minRowHeight, _maxRowHeight);
        final height = n * rowHeight + (n - 1) * _rowGap;
        return SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // Ordine fisso dei figli (per indice), posizione dalla
                // classifica: così ogni riga scivola al suo posto.
                for (final c in all.where((c) => !c.isTechnical))
                  AnimatedPositioned(
                    key: ValueKey(all.indexOf(c)),
                    duration: _reorderDuration,
                    curve: Curves.easeInOutCubic,
                    left: 0,
                    right: 0,
                    top: ranked.indexOf(c) * (rowHeight + _rowGap),
                    height: rowHeight,
                    child: _ProjectorRow(
                      position: ranked.indexOf(c) + 1,
                      candidate: c,
                      totalVotes: counted,
                      height: rowHeight,
                      compact: compact,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Una riga: posizione, nome, barra della quota sulle schede contate,
/// percentuale e voti.
class _ProjectorRow extends StatelessWidget {
  const _ProjectorRow({
    required this.position,
    required this.candidate,
    required this.totalVotes,
    required this.height,
    required this.compact,
  });

  final int position;
  final Candidate candidate;
  final int totalVotes;
  final double height;

  /// Telefono in verticale: margini più stretti.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final percentage = candidate.getPercentage(totalVotes);
    final share = totalVotes > 0 ? candidate.votes / totalVotes : 0.0;
    final isFirst = position == 1 && candidate.votes > 0;
    final name = localizedCandidateName(l10n, candidate);
    final gap = compact ? AppSpacing.m : AppSpacing.xl;
    final big = height >= 96;
    final badge = (height - AppSpacing.l * 2).clamp(
      AppSpacing.xxl,
      AppSpacing.xxxl + AppSpacing.l,
    );

    // TalkBack legge una riga sola; il disegno sotto è escluso.
    return Semantics(
      container: true,
      label: l10n.projectorRowSemantics(
        position,
        name,
        candidate.votes,
        formatOneDecimal(context, percentage),
      ),
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppShapes.large),
          child: ColoredBox(
            color: cs.surfaceContainer,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: share,
                  child: ColoredBox(
                    color: candidate.color.withValues(alpha: 0.45),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: gap),
                  child: Row(
                    children: [
                      Container(
                        width: badge,
                        height: badge,
                        decoration: BoxDecoration(
                          color: isFirst ? cs.primary : candidate.color,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$position',
                            style: (big ? tt.headlineMedium : tt.titleMedium)
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isFirst
                                      ? cs.onPrimary
                                      : CandidatePalette.onColor(
                                          candidate.color,
                                        ),
                                ),
                          ),
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: Text(
                          name,
                          style: (big ? tt.headlineLarge : tt.titleLarge)
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: gap),
                      // Percentuale e voti si rimpiccioliscono invece di
                      // uscire dallo schermo.
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  formatPercent(context, percentage),
                                  style:
                                      (big ? tt.headlineSmall : tt.titleMedium)
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                ),
                                SizedBox(width: gap),
                                Text(
                                  '${candidate.votes}',
                                  style:
                                      (big
                                              ? tt.displayMedium
                                              : tt.headlineMedium)
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: cs.onSurface,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bianche e nulle fuori dalla classifica (D4), in una riga in fondo.
class _TechnicalFooter extends StatelessWidget {
  const _TechnicalFooter({required this.provider});

  final ScrutinyProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final technical = provider.candidates.where((c) => c.isTechnical).toList();
    if (technical.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.s,
        children: [
          for (final c in technical)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: AppSpacing.s, backgroundColor: c.color),
                const SizedBox(width: AppSpacing.s),
                Flexible(
                  child: Text(
                    '${localizedCandidateName(l10n, c)}  ${c.votes}',
                    style: tt.titleLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
