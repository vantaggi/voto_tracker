import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/scrutiny.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/app_settings_page.dart';
import 'package:voto_tracker/services/archive_transfer_service.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/vote_stacked_bar.dart';

enum _ArchiveAction { open, duplicate, rename, export, delete }

enum _ArchiveMenu { export, import, appSettings }

/// Scrutini oltre i quali compare la ricerca.
const int _searchThreshold = 8;

/// Altezza della barra impilata nelle righe dell'archivio.
const double _rowBarHeight = 6;

/// Archivio degli scrutini (FEAT-004, ridisegno S3): "Aperto ora" in cima,
/// poi gli altri; ogni riga ha data, barra dei voti ed esito. Il tocco apre
/// il dettaglio (pagina sul telefono, pannello a destra sul tablet) con
/// Riapri, Duplica ed Esporta. [onOpened] viene chiamato quando si apre o
/// crea uno scrutinio, per tornare alla schermata di conteggio.
class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key, this.onOpened});

  final VoidCallback? onOpened;

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String? _selectedId;
  String _query = '';

  VoidCallback? get onOpened => widget.onOpened;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<ScrutinyProvider>();
    final items = provider.archive;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.archiveTitle),
        actions: [
          PopupMenuButton<_ArchiveMenu>(
            tooltip: l10n.archiveMoreActions,
            onSelected: (choice) => switch (choice) {
              _ArchiveMenu.export => _export(context),
              _ArchiveMenu.import => _import(context),
              _ArchiveMenu.appSettings => AppSettingsPage.open(context),
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _ArchiveMenu.export,
                child: ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: Text(l10n.archiveExport),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _ArchiveMenu.import,
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.archiveImport),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _ArchiveMenu.appSettings,
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(l10n.appSettingsTitle),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final started = await showModalBottomSheet<bool>(
            context: context,
            showDragHandle: true,
            builder: (_) => const _NewScrutinySheet(),
          );
          if (started == true) onOpened?.call();
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newScrutiny),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < AppDimensions.archiveTwoPaneBreakpoint) {
              return _list(context, items, provider, twoPane: false);
            }
            final selected =
                items.where((s) => s.id == _selectedId).firstOrNull ??
                items
                    .where((s) => s.id == provider.currentScrutinyId)
                    .firstOrNull;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: AppDimensions.archiveListPaneWidth,
                  child: _list(
                    context,
                    items,
                    provider,
                    twoPane: true,
                    selected: selected,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selected == null
                      ? const SizedBox.shrink()
                      : _ArchiveDetail(
                          key: ValueKey(selected.id),
                          scrutiny: selected,
                          isCurrent: selected.id == provider.currentScrutinyId,
                          onOpened: onOpened,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    List<Scrutiny> items,
    ScrutinyProvider provider, {
    required bool twoPane,
    Scrutiny? selected,
  }) {
    final l10n = context.l10n;
    final query = _query.trim().toLowerCase();
    bool matches(Scrutiny s) =>
        query.isEmpty ||
        scrutinyDisplayTitle(context, s).toLowerCase().contains(query);
    final current = items
        .where((s) => s.id == provider.currentScrutinyId && matches(s))
        .toList();
    final others = items
        .where((s) => s.id != provider.currentScrutinyId && matches(s))
        .toList();

    Widget tile(Scrutiny s) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: _ArchiveTile(
        scrutiny: s,
        isCurrent: s.id == provider.currentScrutinyId,
        isSelected: twoPane && s.id == selected?.id,
        onOpened: onOpened,
        onSelect: twoPane
            ? () => setState(() => _selectedId = s.id)
            : () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      _ArchiveDetailPage(scrutinyId: s.id, onOpened: onOpened),
                ),
              ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        AppSpacing.bottomBarClearance,
      ),
      children: [
        if (items.length > _searchThreshold)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: SearchBar(
              hintText: l10n.archiveSearch,
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        if (current.isNotEmpty) ...[
          _SectionLabel(l10n.archiveGroupCurrent),
          for (final s in current) tile(s),
        ],
        if (others.isNotEmpty) ...[
          _SectionLabel(l10n.archiveGroupOthers),
          for (final s in others) tile(s),
        ],
        if (current.isEmpty && others.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              l10n.archiveNoResults,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xs,
      AppSpacing.m,
      AppSpacing.xs,
      AppSpacing.s,
    ),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}

/// Conteggio di uno scrutinio salvato, letto dal registro delle schede con lo
/// stesso motore della Home.
class _Tally {
  _Tally(this.scrutiny)
    : votes = ScrutinyEngine.tally(
        scrutiny.candidates.length,
        scrutiny.voteLog,
      ) {
    final settings = scrutiny.settings;
    outcome = ScrutinyEngine.evaluate(
      types: [for (final c in scrutiny.candidates) c.type],
      votes: votes,
      totalVoters: settings.totalVoters,
      rule: settings.victoryRule,
      quorumReached: settings.quorumReached,
    );
    ranking = ScrutinyEngine.ranking(votes);
  }

  final Scrutiny scrutiny;
  final List<int> votes;
  late final ScrutinyOutcome outcome;
  late final List<int> ranking;

  List<Candidate> get candidates => scrutiny.candidates;

  /// Candidati in classifica, poi bianche e nulle.
  List<int> get barOrder => [
    for (final i in ranking)
      if (!candidates[i].isTechnical) i,
    for (final i in ranking)
      if (candidates[i].isTechnical) i,
  ];

  List<BarSegment> get segments => [
    for (final i in barOrder) (color: candidates[i].color, votes: votes[i]),
  ];

  int? get leader {
    final i = ranking.where((i) => !candidates[i].isTechnical).firstOrNull;
    return i != null && votes[i] > 0 ? i : null;
  }

  /// "Eletto Rossi", "In testa: Rossi" o niente.
  String? statusLine(BuildContext context) {
    final l10n = context.l10n;
    final label = localizedWinnerLabel(l10n, outcome.status);
    if (label != null) {
      final winner = outcome.winnerIndex == null
          ? null
          : localizedCandidateName(l10n, candidates[outcome.winnerIndex!]);
      return localizedOutcomeHeadline(l10n, outcome.status, winner);
    }
    final i = leader;
    if (i == null) return null;
    return l10n.archiveLeader(localizedCandidateName(l10n, candidates[i]));
  }
}

class _ArchiveTile extends StatelessWidget {
  const _ArchiveTile({
    required this.scrutiny,
    required this.isCurrent,
    required this.onSelect,
    this.isSelected = false,
    this.onOpened,
  });

  final Scrutiny scrutiny;
  final bool isCurrent;

  /// Mostrato nel pannello di dettaglio (solo a due colonne).
  final bool isSelected;
  final VoidCallback? onOpened;

  /// Apre il dettaglio (pagina sul telefono, pannello sul tablet).
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final title = scrutinyDisplayTitle(context, scrutiny);
    final tally = _Tally(scrutiny);
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(scrutiny.updatedAt);
    final status = [
      l10n.archiveBallots(
        scrutiny.ballotsCounted,
        scrutiny.settings.totalVoters,
      ),
      ?tally.statusLine(context),
    ].join(' · ');

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      color: isSelected
          ? cs.secondaryContainer
          : isCurrent
          ? cs.surfaceContainerHigh
          : cs.surfaceContainerLow,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.m,
            AppSpacing.xs,
            AppSpacing.l,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      date,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    Text(
                      status,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    VoteStackedBar(
                      segments: tally.segments,
                      total: scrutiny.settings.totalVoters,
                      height: _rowBarHeight,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_ArchiveAction>(
                tooltip: l10n.archiveActions(title),
                onSelected: (action) => _onAction(context, action, title),
                itemBuilder: (context) => [
                  if (!isCurrent)
                    PopupMenuItem(
                      value: _ArchiveAction.open,
                      child: Text(l10n.archiveReopen),
                    ),
                  PopupMenuItem(
                    value: _ArchiveAction.duplicate,
                    child: Text(l10n.archiveDuplicate),
                  ),
                  PopupMenuItem(
                    value: _ArchiveAction.rename,
                    child: Text(l10n.archiveRename),
                  ),
                  PopupMenuItem(
                    value: _ArchiveAction.export,
                    child: Text(l10n.archiveExportOne),
                  ),
                  PopupMenuItem(
                    value: _ArchiveAction.delete,
                    child: Text(
                      l10n.archiveDelete,
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    _ArchiveAction action,
    String title,
  ) async {
    final provider = context.read<ScrutinyProvider>();
    switch (action) {
      case _ArchiveAction.open:
        await _openScrutiny(context, scrutiny, onOpened);
      case _ArchiveAction.duplicate:
        await provider.duplicateAsTemplate(scrutiny.id);
        onOpened?.call();
      case _ArchiveAction.rename:
        final value = await showDialog<String>(
          context: context,
          builder: (_) => _RenameDialog(initial: scrutiny.title ?? ''),
        );
        if (value != null) await provider.renameScrutiny(scrutiny.id, value);
      case _ArchiveAction.export:
        await _exportOne(context, scrutiny);
      case _ArchiveAction.delete:
        if (await _confirmDelete(context, title)) {
          await provider.deleteScrutiny(scrutiny.id);
        }
    }
  }
}

Future<bool> _confirmDelete(BuildContext context, String title) async {
  final l10n = context.l10n;
  final colorScheme = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.delete_forever),
      title: Text(l10n.archiveDeleteTitle),
      content: Text(l10n.archiveDeleteBody(title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.archiveDelete),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Esporta un solo scrutinio nel file dell'archivio (si reimporta uguale).
Future<void> _exportOne(BuildContext context, Scrutiny scrutiny) async {
  final provider = context.read<ScrutinyProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final error = context.l10n.exportError;
  await provider.flushPendingSave();
  final fresh =
      provider.archive.where((s) => s.id == scrutiny.id).firstOrNull ??
      scrutiny;
  final ok = await ArchiveTransferService.share([fresh]);
  if (!ok) messenger.showSnackBar(SnackBar(content: Text(error)));
}

/// Esporta tutto l'archivio in un file JSON e apre il menu Condividi (P7).
Future<void> _export(BuildContext context) async {
  final provider = context.read<ScrutinyProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final error = context.l10n.exportError;
  await provider.flushPendingSave();
  final ok = await ArchiveTransferService.share(provider.archive);
  if (!ok) messenger.showSnackBar(SnackBar(content: Text(error)));
}

/// Sceglie un file, chiede conferma e aggiunge gli scrutini (P7).
Future<void> _import(
  BuildContext context, {
  Future<List<Scrutiny>?> Function() pick = ArchiveTransferService.pick,
}) async {
  final l10n = context.l10n;
  final provider = context.read<ScrutinyProvider>();
  final messenger = ScaffoldMessenger.of(context);
  void say(String text) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  final List<Scrutiny>? items;
  try {
    items = await pick();
  } on ArchiveFormatException {
    say(l10n.archiveImportInvalid);
    return;
  } catch (_) {
    say(l10n.archiveImportInvalid);
    return;
  }
  if (items == null) return; // annullato
  if (items.isEmpty) {
    say(l10n.archiveImportEmpty);
    return;
  }
  if (!context.mounted) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.download),
      title: Text(l10n.archiveImportTitle),
      content: Text(l10n.archiveImportBody(items!.length)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.archiveImportConfirm),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final (added, skipped) = await provider.importScrutinies(items);
  say(l10n.archiveImported(added, skipped));
}

/// Solo per i test: import con un file finto al posto del selettore.
@visibleForTesting
Future<void> importArchiveForTest(
  BuildContext context,
  Future<List<Scrutiny>?> Function() pick,
) => _import(context, pick: pick);

/// Riapre [scrutiny] per il conteggio e torna alla schermata Scrutinio.
Future<void> _openScrutiny(
  BuildContext context,
  Scrutiny scrutiny,
  VoidCallback? onOpened,
) async {
  final provider = context.read<ScrutinyProvider>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final message = context.l10n.archiveOpened(
    scrutinyDisplayTitle(context, scrutiny),
  );
  await provider.openScrutiny(scrutiny.id);
  messenger?.showSnackBar(SnackBar(content: Text(message)));
  onOpened?.call();
}

/// Dettaglio a pagina intera sul telefono. Segue lo scrutinio per id, così
/// una rinomina o un'eliminazione si vedono subito.
class _ArchiveDetailPage extends StatelessWidget {
  const _ArchiveDetailPage({required this.scrutinyId, this.onOpened});

  final String scrutinyId;
  final VoidCallback? onOpened;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final scrutiny = provider.archive
        .where((s) => s.id == scrutinyId)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(),
      body: scrutiny == null
          ? const SizedBox.shrink()
          : SafeArea(
              top: false,
              child: _ArchiveDetail(
                scrutiny: scrutiny,
                isCurrent: scrutiny.id == provider.currentScrutinyId,
                onOpened: () {
                  Navigator.pop(context);
                  onOpened?.call();
                },
              ),
            ),
    );
  }
}

/// Dettaglio di uno scrutinio (S3): riepilogo come in Home, classifica in
/// sola lettura e azioni.
class _ArchiveDetail extends StatelessWidget {
  const _ArchiveDetail({
    super.key,
    required this.scrutiny,
    required this.isCurrent,
    this.onOpened,
  });

  final Scrutiny scrutiny;
  final bool isCurrent;
  final VoidCallback? onOpened;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final tally = _Tally(scrutiny);
    final settings = scrutiny.settings;
    final outcome = tally.outcome;
    final label = localizedWinnerLabel(l10n, outcome.status);
    final total = outcome.totalAssigned;
    final inconclusive = outcome.status.isInconclusive;
    final background = label == null
        ? cs.surfaceContainerHigh
        : inconclusive
        ? cs.tertiaryContainer
        : cs.primaryContainer;
    final onBackground = label == null
        ? cs.onSurface
        : inconclusive
        ? cs.onTertiaryContainer
        : cs.onPrimaryContainer;
    final status = tally.statusLine(context);
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(scrutiny.updatedAt);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        AppSpacing.xxl,
      ),
      children: [
        Text(scrutinyDisplayTitle(context, scrutiny), style: tt.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          [if (isCurrent) l10n.archiveGroupCurrent, date].join(' · '),
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.l),
        Card.filled(
          color: background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: tt.labelLarge?.copyWith(
                      color: onBackground,
                      letterSpacing: 1.2,
                    ),
                  ),
                if (status != null)
                  Text(
                    status,
                    style: (label != null ? tt.headlineSmall : tt.titleMedium)
                        ?.copyWith(
                          color: onBackground,
                          fontWeight: label != null ? FontWeight.bold : null,
                        ),
                  ),
                const SizedBox(height: AppSpacing.m),
                VoteStackedBar(
                  segments: tally.segments,
                  total: settings.totalVoters,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  l10n.archiveBallots(
                    scrutiny.ballotsCounted,
                    settings.totalVoters,
                  ),
                  style: tt.bodyLarge?.copyWith(color: onBackground),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            if (isCurrent)
              FilledButton.icon(
                onPressed: onOpened,
                icon: const Icon(Icons.how_to_vote_outlined),
                label: Text(l10n.archiveGoToCount),
              )
            else
              FilledButton.icon(
                onPressed: () => _openScrutiny(context, scrutiny, onOpened),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.archiveReopen),
              ),
            OutlinedButton.icon(
              onPressed: () async {
                await context.read<ScrutinyProvider>().duplicateAsTemplate(
                  scrutiny.id,
                );
                onOpened?.call();
              },
              icon: const Icon(Icons.copy),
              label: Text(l10n.archiveDuplicate),
            ),
            OutlinedButton.icon(
              onPressed: () => _exportOne(context, scrutiny),
              icon: const Icon(Icons.ios_share),
              label: Text(l10n.archiveExportOne),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final i in tally.barOrder)
                _ReadOnlyRow(
                  candidate: scrutiny.candidates[i],
                  votes: tally.votes[i],
                  share: total > 0 ? tally.votes[i] / total : 0,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Riga della classifica in sola lettura: colore, nome, voti e quota.
class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({
    required this.candidate,
    required this.votes,
    required this.share,
  });

  final Candidate candidate;
  final int votes;
  final double share;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          CircleAvatar(radius: AppSpacing.s, backgroundColor: candidate.color),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Text(
              localizedCandidateName(l10n, candidate),
              style: tt.bodyLarge,
            ),
          ),
          Text(
            '$votes · ${formatPercent(context, share * 100)}',
            style: tt.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Punto di partenza di un nuovo scrutinio (S3): vuoto, copia dei candidati
/// dello scrutinio aperto, o da una lista salvata (che si può eliminare).
class _NewScrutinySheet extends StatelessWidget {
  const _NewScrutinySheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<ScrutinyProvider>();
    final lists = provider.candidateLists;
    final current = provider.currentScrutiny;
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.s,
            ),
            child: Text(l10n.newScrutiny, style: tt.titleLarge),
          ),
          ListTile(
            leading: const Icon(Icons.note_add_outlined),
            title: Text(l10n.newEmptyScrutiny),
            subtitle: Text(l10n.newEmptyScrutinyHint),
            onTap: () async {
              final navigator = Navigator.of(context);
              await provider.newScrutiny();
              navigator.pop(true);
            },
          ),
          if (current != null)
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(
                l10n.newFromCopy(scrutinyDisplayTitle(context, current)),
              ),
              subtitle: Text(l10n.newFromCopyHint),
              onTap: () async {
                final navigator = Navigator.of(context);
                await provider.duplicateAsTemplate(current.id);
                navigator.pop(true);
              },
            ),
          if (lists.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.s,
                AppSpacing.l,
                AppSpacing.xs,
              ),
              child: Text(l10n.newFromList, style: tt.titleSmall),
            ),
            for (final list in lists)
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: Text(list.name),
                subtitle: Text(l10n.listCandidates(list.candidates.length)),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  await provider.newScrutinyFromList(list.id);
                  navigator.pop(true);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.deleteList(list.name),
                  onPressed: () => provider.deleteCandidateList(list.id),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.l),
        ],
      ),
    );
  }
}

/// Dialog di rinomina: possiede il proprio controller, così viene liberato
/// solo a fine animazione di chiusura.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.archiveRename),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.scrutinyTitleLabel,
          helperText: l10n.archiveRenameHint,
        ),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
