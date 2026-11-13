import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_actions.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/candidate_row.dart';
import 'package:voto_tracker/widgets/charts_card.dart';
import 'package:voto_tracker/widgets/export_sheet.dart';
import 'package:voto_tracker/widgets/keep_screen_on.dart';
import 'package:voto_tracker/widgets/undo_bar.dart';
import 'package:voto_tracker/widgets/vote_summary_card.dart';

/// Larghezza da cui la Home mette lista e riepilogo affiancati (classe
/// "expanded" di Material 3).
const double _twoPaneBreakpoint = 840;

/// Larghezza massima della colonna unica (telefono in orizzontale, tablet
/// piccolo): oltre, le righe sarebbero troppo larghe da leggere.
const double _singlePaneMaxWidth = 640;

/// Telefono in orizzontale: sotto questa altezza, se c'è almeno la larghezza
/// minima, anche la Home in una colonna va su due colonne. Altrimenti il
/// riepilogo e la barra Annulla lascerebbero spazio per una riga sola.
const double _lowHeight = 500;
const double _lowHeightTwoPaneMinWidth = 600;

/// Home dello scrutinio (ridisegno R6): titolo dello scrutinio in alto,
/// riepilogo, righe dei candidati, altre schede, grafici e barra Annulla.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Schermo acceso finché la Home è nell'albero (non a ogni rebuild).
    return KeepScreenOn(
      child: Scaffold(
        appBar: const _HomeAppBar(),
        // Edge-to-edge: l'AppBar gestisce l'inset in alto; qui restano i
        // lati (notch in orizzontale). In basso pensa la barra di navigazione.
        body: SafeArea(
          top: false,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) =>
                constraints.maxWidth >= _twoPaneBreakpoint ||
                    (constraints.maxHeight < _lowHeight &&
                        constraints.maxWidth >= _lowHeightTwoPaneMinWidth)
                ? const _TwoPane()
                : const _SinglePane(),
          ),
        ),
      ),
    );
  }
}

class _SinglePane extends StatelessWidget {
  const _SinglePane();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _singlePaneMaxWidth),
        child: const _WithUndoBar(
          child: _CountingList(
            header: [
              VoteSummaryCard(),
              SizedBox(height: AppSpacing.l),
            ],
            footer: [
              SizedBox(height: AppSpacing.l),
              ChartsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwoPane extends StatelessWidget {
  const _TwoPane();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 5, child: _WithUndoBar(child: _CountingList())),
        Expanded(
          flex: 4,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              0,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.l,
            ),
            children: const [
              VoteSummaryCard(),
              SizedBox(height: AppSpacing.l),
              ChartsCard(initiallyExpanded: true),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lista che scorre con le righe dei candidati e le altre schede, più quello
/// che il layout mette sopra e sotto.
class _CountingList extends StatelessWidget {
  const _CountingList({this.header = const [], this.footer = const []});

  final List<Widget> header;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        AppSpacing.l,
      ),
      children: [
        ...header,
        const CandidateGroup(),
        const OtherBallotsGroup(),
        ...footer,
      ],
    );
  }
}

/// Il conteggio con la barra Annulla fissa sotto (FIX-017).
class _WithUndoBar extends StatelessWidget {
  const _WithUndoBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        const UndoBar(),
      ],
    );
  }
}

enum _MenuAction { projector, settings, reset }

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<ScrutinyProvider>();
    final scrutiny = provider.currentScrutiny;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      centerTitle: false,
      toolbarHeight: kToolbarHeight + 8,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            scrutiny == null
                ? l10n.appTitle
                : scrutinyDisplayTitle(context, scrutiny),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            l10n.homeSubtitle(
              provider.totalVotesAssigned,
              provider.settings.totalVoters,
            ),
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.ballot_outlined),
          tooltip: l10n.ballotReadingTitle,
          onPressed: () => HomeActions.openBallotReading(context),
        ),
        IconButton(
          icon: const Icon(Icons.ios_share),
          tooltip: l10n.exportShareTooltip,
          onPressed: () => showExportSheet(context),
        ),
        PopupMenuButton<_MenuAction>(
          tooltip: l10n.moreActions,
          onSelected: (action) {
            switch (action) {
              case _MenuAction.projector:
                HomeActions.openProjector(context);
              case _MenuAction.settings:
                HomeActions.openSettings(context);
              case _MenuAction.reset:
                HomeActions.confirmReset(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _MenuAction.projector,
              child: ListTile(
                leading: const Icon(Icons.tv),
                title: Text(l10n.projectorMode),
              ),
            ),
            PopupMenuItem(
              value: _MenuAction.settings,
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l10n.settingsTooltip),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: _MenuAction.reset,
              enabled: provider.canUndo || provider.totalVotesAssigned > 0,
              child: ListTile(
                leading: Icon(Icons.restart_alt, color: cs.error),
                title: Text(
                  l10n.resetScrutiny,
                  style: TextStyle(color: cs.error),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}
