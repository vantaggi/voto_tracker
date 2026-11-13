import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Barra Annulla / Ripeti fissa in fondo al conteggio, con il nome dell'ultimo
/// voto ("Annulla Rossi"). È sempre presente, anche senza nulla da annullare
/// (i comandi sono solo disattivati): non compare e non scompare, quindi non
/// sposta niente e non copre la lista. Annulla sta a sinistra, Ripeti in un
/// punto fisso (non dipende dalla lunghezza del nome) e sotto la colonna dei +
/// non c'è nessun comando (FIX-017). Ha il colore della barra di
/// navigazione, così sul telefono le due sembrano un pezzo unico.
class UndoBar extends StatelessWidget {
  const UndoBar({super.key});

  /// Altezza della barra (area di tocco di Annulla e Ripeti).
  static const double height = 48;

  /// Spazio vuoto a destra, sotto la colonna dei + delle righe (il + da 56 dp
  /// e i margini): Ripeti sta sempre nello stesso punto, prima di esso.
  static const double plusColumnClearance = 56 + 2 * AppSpacing.l;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final last = provider.lastVotedIndex;
    final label = last == null
        ? l10n.cancel
        : l10n.undoLastVote(
            localizedCandidateName(l10n, provider.candidates[last]),
          );

    return Material(
      color: cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1, color: cs.outlineVariant),
            SizedBox(
              height: height,
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Tooltip(
                        message: l10n.undoTooltip,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(height, height),
                          ),
                          onPressed: provider.canUndo
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  provider.undo();
                                }
                              : null,
                          icon: const Icon(Icons.undo),
                          label: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.redoTooltip,
                    onPressed: provider.canRedo
                        ? () {
                            HapticFeedback.mediumImpact();
                            provider.redo();
                          }
                        : null,
                    icon: const Icon(Icons.redo),
                  ),
                  // Sotto la colonna dei + non c'è nessun comando.
                  const SizedBox(width: plusColumnClearance),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
