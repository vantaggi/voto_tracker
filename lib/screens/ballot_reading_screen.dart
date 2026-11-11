import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/keep_screen_on.dart';

/// Modalità "lettura scheda" (FEAT-006): una scheda alla volta, un pulsante
/// grande per candidato, annulla sempre a portata di mano. Pensata per chi
/// legge le schede ad alta voce e registra con una mano sola.
class BallotReadingScreen extends StatefulWidget {
  const BallotReadingScreen({super.key});

  /// Pausa dopo ogni scheda: un doppio tocco involontario non conta due voti.
  static const Duration tapGuard = Duration(milliseconds: 350);

  @override
  State<BallotReadingScreen> createState() => _BallotReadingScreenState();
}

class _BallotReadingScreenState extends State<BallotReadingScreen> {
  Timer? _guard;
  int? _lastIndex;

  @override
  void dispose() {
    _guard?.cancel();
    super.dispose();
  }

  void _record(ScrutinyProvider provider, int index) {
    if (_guard?.isActive ?? false) return;
    if (provider.remainingVotes <= 0) return;
    _guard = Timer(BallotReadingScreen.tapGuard, () {});
    HapticFeedback.mediumImpact();
    provider.vote(index);
    setState(() => _lastIndex = index);
  }

  void _undo(ScrutinyProvider provider) {
    HapticFeedback.heavyImpact();
    provider.undo();
    setState(() {
      _lastIndex = null;
      _guard?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<ScrutinyProvider>();
    final total = provider.settings.totalVoters;
    final counted = provider.totalVotesAssigned;
    final complete = provider.remainingVotes <= 0;
    final last = _lastIndex != null && _lastIndex! < provider.candidates.length
        ? localizedCandidateName(l10n, provider.candidates[_lastIndex!])
        : null;

    return KeepScreenOn(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.ballotReadingTitle)),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    complete
                        ? l10n.countingComplete
                        : l10n.ballotNumber(counted + 1, total),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  last != null ? l10n.ballotLast(last) : l10n.ballotHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                LinearProgressIndicator(
                  value: total > 0 ? counted / total : 0,
                  borderRadius: BorderRadius.circular(AppShapes.extraSmall),
                ),
                const SizedBox(height: AppSpacing.l),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          constraints.maxWidth >=
                              AppDimensions.compactBreakpoint
                          ? 3
                          : 2;
                      return GridView.count(
                        crossAxisCount: columns,
                        mainAxisSpacing: AppSpacing.m,
                        crossAxisSpacing: AppSpacing.m,
                        childAspectRatio: 1.6,
                        children: [
                          for (var i = 0; i < provider.candidates.length; i++)
                            _BallotButton(
                              key: ValueKey('ballot-$i'),
                              label: localizedCandidateName(
                                l10n,
                                provider.candidates[i],
                              ),
                              votes: provider.candidates[i].votes,
                              color: provider.candidates[i].color,
                              enabled: !complete,
                              onPressed: () => _record(provider, i),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                SizedBox(
                  height: AppTouch.minTarget + AppSpacing.l,
                  child: FilledButton.tonalIcon(
                    onPressed: provider.canUndo ? () => _undo(provider) : null,
                    icon: const Icon(Icons.undo),
                    label: Text(l10n.ballotUndo),
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

class _BallotButton extends StatelessWidget {
  const _BallotButton({
    super.key,
    required this.label,
    required this.votes,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final int votes;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onColor = CandidatePalette.onColor(color);
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: onColor,
        padding: const EdgeInsets.all(AppSpacing.m),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.large),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: onColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$votes',
            style: textTheme.titleMedium?.copyWith(color: onColor),
          ),
        ],
      ),
    );
  }
}
