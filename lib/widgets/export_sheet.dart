import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/services/export_controller.dart';

/// Bottom sheet con le opzioni di esportazione e condivisione.
Future<void> showExportSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    builder: (context) => const _ExportSheet(),
  );
}

class _ExportSheet extends StatelessWidget {
  const _ExportSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    /// Chiude il sheet e lancia l'export; se fallisce mostra una SnackBar.
    void run(Future<Object?> Function(ExportController c) action) {
      final controller = ExportController(
        context.read<ScrutinyProvider>(),
        l10n,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: Text(l10n.shareImageTitle),
            subtitle: Text(l10n.shareImageSubtitle),
            onTap: () => run((c) => c.shareImage()),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(l10n.exportPdfTitle),
            subtitle: Text(l10n.exportPdfSubtitle),
            onTap: () => run((c) => c.exportPdf()),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: Text(l10n.exportCsvTitle),
            subtitle: Text(l10n.exportCsvSubtitle),
            onTap: () => run((c) => c.shareCsv()),
          ),
          ListTile(
            leading: const Icon(Icons.data_object),
            title: Text(l10n.exportJsonTitle),
            subtitle: Text(l10n.exportJsonSubtitle),
            onTap: () => run((c) => c.shareJson()),
          ),
        ],
      ),
    );
  }
}
