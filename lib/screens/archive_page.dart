import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/models/scrutiny.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';

enum _ArchiveAction { open, duplicate, rename, delete }

/// Archivio degli scrutini (FEAT-004): elenco, nuovo, duplica come modello,
/// riapri, rinomina, elimina con conferma. [onOpened] viene chiamato quando
/// si apre o crea uno scrutinio, per tornare alla schermata di conteggio.
class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key, this.onOpened});

  final VoidCallback? onOpened;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<ScrutinyProvider>();
    final items = provider.archive;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.archiveTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await provider.newScrutiny();
          onOpened?.call();
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newScrutiny),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.l,
            AppSpacing.bottomBarClearance,
          ),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
          itemBuilder: (context, i) => _ArchiveTile(
            scrutiny: items[i],
            isCurrent: items[i].id == provider.currentScrutinyId,
            onOpened: onOpened,
          ),
        ),
      ),
    );
  }
}

class _ArchiveTile extends StatelessWidget {
  const _ArchiveTile({
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
    final colorScheme = theme.colorScheme;
    final title = scrutinyDisplayTitle(context, scrutiny);

    final votes = ScrutinyEngine.tally(
      scrutiny.candidates.length,
      scrutiny.voteLog,
    );
    final leader = ScrutinyEngine.ranking(votes)
        .where((i) => scrutiny.candidates[i].type == CandidateType.normal)
        .firstOrNull;
    final subtitle = [
      l10n.archiveBallots(
        scrutiny.ballotsCounted,
        scrutiny.settings.totalVoters,
      ),
      if (leader != null && votes[leader] > 0)
        l10n.archiveLeader(
          localizedCandidateName(l10n, scrutiny.candidates[leader]),
        ),
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isCurrent ? colorScheme.secondaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.xs,
        ),
        leading: Icon(
          isCurrent ? Icons.how_to_vote : Icons.inventory_2_outlined,
          color: isCurrent
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant,
        ),
        title: Text(title),
        subtitle: Text(
          isCurrent ? '${l10n.archiveCurrent} · $subtitle' : subtitle,
        ),
        onTap: () => _open(context),
        trailing: PopupMenuButton<_ArchiveAction>(
          tooltip: l10n.archiveActions(title),
          onSelected: (action) => _onAction(context, action, title),
          itemBuilder: (context) => [
            if (!isCurrent)
              PopupMenuItem(
                value: _ArchiveAction.open,
                child: Text(l10n.archiveOpen),
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
              value: _ArchiveAction.delete,
              child: Text(
                l10n.archiveDelete,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final provider = context.read<ScrutinyProvider>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = context.l10n.archiveOpened(
      scrutinyDisplayTitle(context, scrutiny),
    );
    await provider.openScrutiny(scrutiny.id);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
    onOpened?.call();
  }

  Future<void> _onAction(
    BuildContext context,
    _ArchiveAction action,
    String title,
  ) async {
    final provider = context.read<ScrutinyProvider>();
    switch (action) {
      case _ArchiveAction.open:
        await _open(context);
      case _ArchiveAction.duplicate:
        await provider.duplicateAsTemplate(scrutiny.id);
        onOpened?.call();
      case _ArchiveAction.rename:
        final value = await _askTitle(context, scrutiny.title);
        if (value != null) await provider.renameScrutiny(scrutiny.id, value);
      case _ArchiveAction.delete:
        if (await _confirmDelete(context, title)) {
          await provider.deleteScrutiny(scrutiny.id);
        }
    }
  }

  Future<String?> _askTitle(BuildContext context, String? current) =>
      showDialog<String>(
        context: context,
        builder: (_) => _RenameDialog(initial: current ?? ''),
      );

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
