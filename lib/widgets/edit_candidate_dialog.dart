import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Diametro di un colore nella scelta.
const double _swatchSize = 36;

/// Apre "Modifica candidato" per il candidato [index] e salva nome, colore e
/// risultato precedente se confermati.
Future<void> showEditCandidateDialog(BuildContext context, int index) async {
  final provider = context.read<ScrutinyProvider>();
  final candidate = provider.candidates[index];
  final result = await showDialog<_CandidateEdit>(
    context: context,
    builder: (_) => _EditCandidateDialog(
      name: candidate.name,
      color: candidate.color,
      pickColor: !candidate.isTechnical,
      previousPercentage: candidate.previousPercentage,
    ),
  );
  if (result == null) return;
  provider.renameCandidate(index, result.name);
  if (result.color != candidate.color) {
    provider.setCandidateColor(index, result.color);
  }
  provider.setCandidatePreviousPercentage(index, result.previousPercentage);
}

/// Valori confermati nel dialog di modifica.
class _CandidateEdit {
  const _CandidateEdit(this.name, this.color, this.previousPercentage);
  final String name;
  final Color color;
  final double? previousPercentage;
}

/// Dialog "Modifica candidato" (FIX-006, ridisegno S6): nome, colore dalla
/// tavolozza e risultato precedente. Possiede i propri controller e li
/// libera nel suo dispose, cioè solo quando l'animazione di chiusura è finita.
class _EditCandidateDialog extends StatefulWidget {
  const _EditCandidateDialog({
    required this.name,
    required this.color,
    required this.pickColor,
    this.previousPercentage,
  });

  final String name;
  final Color color;

  /// Bianche e nulle tengono il loro grigio.
  final bool pickColor;
  final double? previousPercentage;

  @override
  State<_EditCandidateDialog> createState() => _EditCandidateDialogState();
}

class _EditCandidateDialogState extends State<_EditCandidateDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.name,
  );
  TextEditingController? _previous;
  late Color _color = widget.color;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Il valore iniziale si scrive con la virgola in italiano.
    _previous ??= TextEditingController(
      text: widget.previousPercentage == null
          ? ''
          : formatOneDecimal(context, widget.previousPercentage!),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _previous?.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) return;
    final text = _previous!.text.trim();
    final previous = text.isEmpty
        ? null
        : double.tryParse(text.replaceAll(',', '.'));
    Navigator.pop(context, _CandidateEdit(_name.text.trim(), _color, previous));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.editName),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.candidateName),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _save(),
          ),
          if (widget.pickColor) ...[
            const SizedBox(height: AppSpacing.l),
            Text(
              l10n.candidateColor,
              style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              children: [
                for (final (i, color) in CandidatePalette.candidates.indexed)
                  _Swatch(
                    color: color,
                    selected: color.toARGB32() == _color.toARGB32(),
                    label: l10n.candidateColorOption(i + 1),
                    onTap: () => setState(() => _color = color),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          TextField(
            controller: _previous,
            decoration: InputDecoration(
              labelText: l10n.previousResultLabel,
              suffixText: '%',
              hintText: l10n.previousResultHintNumber(
                formatOneDecimal(context, 25.5),
              ),
              helperText: l10n.previousResultHelper,
              helperMaxLines: 2,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// Un colore della tavolozza, con la spunta se scelto. Area di tocco 48dp.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: AppTouch.minTarget / 2,
        child: SizedBox.square(
          dimension: AppTouch.minTarget,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _swatchSize,
              height: _swatchSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: cs.onSurface, width: 3)
                    : null,
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      size: AppSpacing.l + AppSpacing.xs,
                      color: CandidatePalette.onColor(color),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
