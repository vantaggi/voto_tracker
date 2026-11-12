import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Apre "Modifica nome" per il candidato [index] e salva nome e risultato
/// precedente se confermati.
Future<void> showEditCandidateDialog(BuildContext context, int index) async {
  final provider = context.read<ScrutinyProvider>();
  final candidate = provider.candidates[index];
  final result = await showDialog<_CandidateEdit>(
    context: context,
    builder: (_) => _EditCandidateDialog(
      name: candidate.name,
      previousPercentage: candidate.previousPercentage,
    ),
  );
  if (result == null) return;
  provider.renameCandidate(index, result.name);
  provider.setCandidatePreviousPercentage(index, result.previousPercentage);
}

/// Valori confermati nel dialog di modifica.
class _CandidateEdit {
  const _CandidateEdit(this.name, this.previousPercentage);
  final String name;
  final double? previousPercentage;
}

/// Dialog "Modifica nome" (FIX-006): possiede i propri controller e li libera
/// nel suo dispose, cioè solo quando l'animazione di chiusura è finita.
class _EditCandidateDialog extends StatefulWidget {
  const _EditCandidateDialog({required this.name, this.previousPercentage});

  final String name;
  final double? previousPercentage;

  @override
  State<_EditCandidateDialog> createState() => _EditCandidateDialogState();
}

class _EditCandidateDialogState extends State<_EditCandidateDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.name,
  );
  late final TextEditingController _previous = TextEditingController(
    text: widget.previousPercentage?.toString() ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _previous.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.isEmpty) return;
    final previous = _previous.text.isEmpty
        ? null
        : double.tryParse(_previous.text.replaceAll(',', '.'));
    Navigator.pop(context, _CandidateEdit(_name.text, previous));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.candidateName,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.l),
          TextField(
            controller: _previous,
            decoration: InputDecoration(
              labelText: l10n.previousResultLabel,
              suffixText: "%",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.percent),
              hintText: l10n.previousResultHint,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
