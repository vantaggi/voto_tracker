import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/services/export_controller.dart';
import 'package:voto_tracker/services/pdf_palette.dart';
import 'package:voto_tracker/theme/app_theme.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/vote_stacked_bar.dart';

/// Altezza dell'anteprima nelle due schede grandi.
const double _previewHeight = 88;

/// Foglio "Condividi" (ridisegno S6): Immagine e PDF come schede grandi,
/// CSV e JSON piccoli sotto "Solo i dati".
Future<void> showExportSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _ExportSheet(),
  );
}

class _ExportSheet extends StatelessWidget {
  const _ExportSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<ScrutinyProvider>();
    final scrutiny = provider.currentScrutiny;

    /// Chiude il foglio e lancia l'export; se fallisce mostra una SnackBar.
    void run(Future<Object?> Function(ExportController c) action) {
      final controller = ExportController(
        context.read<ScrutinyProvider>(),
        l10n,
        palette: PdfPalette.fromScheme(
          context.read<AppThemes>().light.colorScheme,
        ),
      );
      final messenger = ScaffoldMessenger.of(context);
      final errorMsg = l10n.exportError;
      Navigator.pop(context);
      action(controller).then((result) {
        if (result == false) {
          messenger.showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      });
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              scrutiny == null
                  ? l10n.exportShareTooltip
                  : l10n.exportSheetTitle(
                      scrutinyDisplayTitle(context, scrutiny),
                    ),
              style: tt.titleLarge,
            ),
            Text(
              l10n.homeSubtitle(
                provider.totalVotesAssigned,
                provider.settings.totalVoters,
              ),
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.l),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _BigOption(
                      preview: _ImagePreview(provider: provider),
                      icon: Icons.image,
                      title: l10n.shareImageTitle,
                      subtitle: l10n.shareImageSubtitle,
                      onTap: () => run((c) => c.shareImage()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: _BigOption(
                      preview: const _PdfPreview(),
                      icon: Icons.picture_as_pdf,
                      title: l10n.exportPdfTitle,
                      subtitle: l10n.exportPdfSubtitle,
                      onTap: () => run((c) => c.exportPdf()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.exportDataLabel,
              style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                Tooltip(
                  message: l10n.exportCsvSubtitle,
                  child: OutlinedButton.icon(
                    onPressed: () => run((c) => c.shareCsv()),
                    icon: const Icon(Icons.table_chart_outlined),
                    label: Text(l10n.exportCsvTitle),
                  ),
                ),
                Tooltip(
                  message: l10n.exportJsonSubtitle,
                  child: OutlinedButton.icon(
                    onPressed: () => run((c) => c.shareJson()),
                    icon: const Icon(Icons.data_object),
                    label: Text(l10n.exportJsonTitle),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BigOption extends StatelessWidget {
  const _BigOption({
    required this.preview,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget preview;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _previewHeight,
                width: double.infinity,
                child: preview,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Icon(icon, size: AppSpacing.l + AppSpacing.xs),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(child: Text(title, style: tt.titleMedium)),
                ],
              ),
              Text(
                subtitle,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Anteprima dell'immagine: fondo scuro, chi è in testa e la barra.
class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.provider});

  final ScrutinyProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dark = context.read<AppThemes>().dark.colorScheme;
    final leader = provider.sortedCandidates
        .where((c) => !c.isTechnical && c.votes > 0)
        .firstOrNull;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark.surface,
          borderRadius: BorderRadius.circular(AppShapes.medium),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (leader != null)
                Text(
                  localizedCandidateName(l10n, leader),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: dark.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: AppSpacing.s),
              VoteStackedBar(
                total: provider.settings.totalVoters,
                height: AppSpacing.s,
                restColor: dark.surfaceContainerHighest,
                segments: [
                  for (final c in provider.sortedCandidates)
                    (color: c.color, votes: c.votes),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Anteprima del PDF: un foglio bianco con righe.
class _PdfPreview extends StatelessWidget {
  const _PdfPreview();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Center(
        child: AspectRatio(
          aspectRatio: 0.71,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppShapes.extraSmall),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final w in const [0.8, 0.5, 0.9, 0.7, 0.6])
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: FractionallySizedBox(
                        widthFactor: w,
                        child: SizedBox(
                          height: AppSpacing.xs,
                          child: ColoredBox(color: cs.outlineVariant),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
