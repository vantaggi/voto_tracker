import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Annulla e Ripeti in una pillola fluttuante in fondo alla Home (R4), con il
/// nome dell'ultimo voto ("Annulla Rossi"). Compare solo quando c'è qualcosa
/// da annullare o ripristinare.
class UndoPill extends StatelessWidget {
  const UndoPill({super.key});

  /// Spazio da lasciare in fondo alle liste perché la pillola non copra
  /// l'ultima riga.
  static const double clearance = 56 + 2 * AppSpacing.l;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final visible = provider.canUndo || provider.canRedo;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: visible ? _Pill(provider: provider) : const SizedBox.shrink(),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.provider});

  final ScrutinyProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final last = provider.lastVotedIndex;
    final label = last == null
        ? l10n.cancel
        : l10n.undoLastVote(
            localizedCandidateName(l10n, provider.candidates[last]),
          );
    final fg = cs.onInverseSurface;
    final disabled = fg.withValues(alpha: 0.38);

    return Material(
      color: cs.inverseSurface,
      elevation: 3,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Tooltip(
                message: l10n.undoTooltip,
                child: InkWell(
                  onTap: provider.canUndo
                      ? () {
                          HapticFeedback.mediumImpact();
                          provider.undo();
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lPlus,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.undo,
                          color: provider.canUndo ? fg : disabled,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: provider.canUndo ? fg : disabled,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 24,
              child: VerticalDivider(width: 1, color: disabled),
            ),
            IconButton(
              tooltip: l10n.redoTooltip,
              color: fg,
              disabledColor: disabled,
              onPressed: provider.canRedo
                  ? () {
                      HapticFeedback.mediumImpact();
                      provider.redo();
                    }
                  : null,
              icon: const Icon(Icons.redo),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}
