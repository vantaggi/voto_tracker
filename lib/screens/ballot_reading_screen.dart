import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/keep_screen_on.dart';
import 'package:voto_tracker/widgets/undo_pill.dart';
import 'package:voto_tracker/widgets/vote_stacked_bar.dart';

/// Altezza minima e massima di una tessera candidato.
const double _minTileHeight = 88;
const double _maxTileHeight = 300;

/// Da questa altezza il nome sulla tessera usa il carattere più grande.
const double _largeNameFrom = 160;

/// Altezza delle tessere di bianche e nulle.
const double _technicalTileHeight = 72;

/// Durata del lampo sulla tessera toccata.
const Duration _flashDuration = Duration(milliseconds: 180);

/// Modalità "lettura scheda" (FEAT-006, ridisegno S4): una tessera grande per
/// candidato che riempie lo schermo, bianche e nulle più piccole in fondo,
/// pillola Annulla con il nome dell'ultima scheda. Pensata per chi legge le
/// schede ad alta voce e registra con una mano sola.
class BallotReadingScreen extends StatefulWidget {
  const BallotReadingScreen({super.key});

  /// Pausa dopo ogni scheda: un doppio tocco involontario non conta due voti.
  static const Duration tapGuard = Duration(milliseconds: 350);

  @override
  State<BallotReadingScreen> createState() => _BallotReadingScreenState();
}

class _BallotReadingScreenState extends State<BallotReadingScreen> {
  Timer? _guard;

  @override
  void dispose() {
    _guard?.cancel();
    super.dispose();
  }

  /// Registra la scheda; false se ignorata (doppio tocco o scrutinio pieno).
  bool _record(ScrutinyProvider provider, int index) {
    if (_guard?.isActive ?? false) return false;
    if (provider.remainingVotes <= 0) return false;
    _guard = Timer(BallotReadingScreen.tapGuard, () {});
    HapticFeedback.mediumImpact();
    provider.vote(index);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final provider = context.watch<ScrutinyProvider>();
    final scrutiny = provider.currentScrutiny;
    final total = provider.settings.totalVoters;
    final counted = provider.totalVotesAssigned;
    final complete = provider.remainingVotes <= 0;
    final candidates = provider.candidates;
    final real = [
      for (var i = 0; i < candidates.length; i++)
        if (!candidates[i].isTechnical) i,
    ];
    final technical = [
      for (var i = 0; i < candidates.length; i++)
        if (candidates[i].isTechnical) i,
    ];

    return KeepScreenOn(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                scrutiny == null
                    ? l10n.ballotReadingTitle
                    : scrutinyDisplayTitle(context, scrutiny),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (scrutiny != null)
                Text(
                  l10n.ballotReadingTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.s,
                    AppSpacing.l,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          complete
                              ? l10n.countingComplete
                              : l10n.ballotNumber(counted + 1, total),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      if (counted == 0)
                        Text(
                          l10n.ballotHint,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.m),
                      VoteStackedBar(
                        total: total,
                        height: AppSpacing.s,
                        segments: [
                          for (final c in candidates)
                            (color: c.color, votes: c.votes),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Expanded(
                        child: complete
                            ? const _DonePanel()
                            : _CandidateGrid(
                                indexes: real,
                                onTap: (i) => _record(provider, i),
                              ),
                      ),
                      if (!complete && technical.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.m),
                        Row(
                          children: [
                            for (final (n, i) in technical.indexed) ...[
                              if (n > 0) const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: _TechnicalTile(
                                  key: ValueKey('ballot-$i'),
                                  candidate: candidates[i],
                                  onPressed: () => _record(provider, i),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: UndoPill.clearance),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: AppSpacing.l,
                right: AppSpacing.l,
                bottom: AppSpacing.l,
                child: Center(child: UndoPill()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tessere dei candidati: riempiono l'altezza disponibile (88–300dp), in due
/// colonne, tre con più di quattro candidati su uno schermo largo.
class _CandidateGrid extends StatelessWidget {
  const _CandidateGrid({required this.indexes, required this.onTap});

  final List<int> indexes;
  final bool Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    final candidates = context.watch<ScrutinyProvider>().candidates;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            indexes.length > 4 &&
                constraints.maxWidth >= AppDimensions.compactBreakpoint
            ? 3
            : 2;
        final rows = (indexes.length / columns).ceil();
        final height =
            ((constraints.maxHeight - AppSpacing.m * (rows - 1)) / rows).clamp(
              _minTileHeight,
              _maxTileHeight,
            );
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.m,
            crossAxisSpacing: AppSpacing.m,
            mainAxisExtent: height,
          ),
          itemCount: indexes.length,
          itemBuilder: (context, n) {
            final i = indexes[n];
            return _CandidateTile(
              key: ValueKey('ballot-$i'),
              candidate: candidates[i],
              large: height >= _largeNameFrom,
              onPressed: () => onTap(i),
            );
          },
        );
      },
    );
  }
}

/// Tessera di un candidato: nome grande, voti piccoli nell'angolo (D5), un
/// lampo del colore del testo quando la scheda è registrata.
class _CandidateTile extends StatefulWidget {
  const _CandidateTile({
    super.key,
    required this.candidate,
    required this.large,
    required this.onPressed,
  });

  final Candidate candidate;
  final bool large;
  final bool Function() onPressed;

  @override
  State<_CandidateTile> createState() => _CandidateTileState();
}

class _CandidateTileState extends State<_CandidateTile> {
  bool _flash = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tap() {
    if (!widget.onPressed()) return;
    setState(() => _flash = true);
    _timer?.cancel();
    _timer = Timer(_flashDuration, () {
      if (mounted) setState(() => _flash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final c = widget.candidate;
    final onColor = CandidatePalette.onColor(c.color);
    final name = localizedCandidateName(l10n, c);
    return Semantics(
      button: true,
      label: l10n.ballotTileSemantics(name, c.votes),
      excludeSemantics: true,
      child: Material(
        color: c.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.large),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _tap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Center(
                  child: Text(
                    name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: (widget.large ? tt.headlineMedium : tt.headlineSmall)
                        ?.copyWith(color: onColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.s,
                right: AppSpacing.s,
                child: _CountChip(votes: c.votes, color: onColor),
              ),
              IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _flash ? 0.35 : 0,
                  duration: _flashDuration,
                  child: ColoredBox(color: onColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Numero di voti nell'angolo della tessera.
class _CountChip extends StatelessWidget {
  const _CountChip({required this.votes, required this.color});

  final int votes;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppShapes.small),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          '$votes',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Bianche e nulle: tessere basse con bordo, in fondo.
class _TechnicalTile extends StatelessWidget {
  const _TechnicalTile({
    super.key,
    required this.candidate,
    required this.onPressed,
  });

  final Candidate candidate;
  final bool Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final name = localizedCandidateName(l10n, candidate);
    return SizedBox(
      height: _technicalTileHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShapes.large),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppSpacing.s / 2 + AppSpacing.xs,
              backgroundColor: candidate.color,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.titleMedium?.copyWith(color: cs.onSurface),
              ),
            ),
            Text(
              '${candidate.votes}',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A scrutinio completo: esito e ritorno al conteggio.
class _DonePanel extends StatelessWidget {
  const _DonePanel();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<ScrutinyProvider>();
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final label = localizedWinnerLabel(l10n, provider.winnerStatus);
    return Center(
      child: Card.filled(
        color: cs.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.task_alt, size: AppSpacing.xxxl, color: cs.primary),
              const SizedBox(height: AppSpacing.m),
              if (label != null)
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(
                    color: cs.onPrimaryContainer,
                    letterSpacing: 1.2,
                  ),
                ),
              if (label != null)
                Text(
                  localizedOutcomeHeadline(
                    l10n,
                    provider.winnerStatus,
                    provider.winnerName,
                  ),
                  textAlign: TextAlign.center,
                  style: tt.headlineSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: AppSpacing.l),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.ballotBackToCount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
