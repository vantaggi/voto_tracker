import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/ballot_reading_screen.dart';
import 'package:voto_tracker/screens/projector_mode_screen.dart';
import 'package:voto_tracker/screens/settings_dialog.dart';

/// Azioni della Home richiamate da più punti (barra in alto, menu ⋮, card di
/// riepilogo): un solo posto per aprire ogni schermata.
abstract final class HomeActions {
  static Future<void> openSettings(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => const SettingsDialog(),
  );

  static Future<void> openBallotReading(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const BallotReadingScreen()),
  );

  static Future<void> openProjector(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const ProjectorModeScreen()),
  );

  /// Azzera lo scrutinio dopo una conferma esplicita: non si può annullare.
  static Future<void> confirmReset(BuildContext context) async {
    final provider = context.read<ScrutinyProvider>();
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.restart_alt),
        title: Text(l10n.resetConfirmTitle),
        content: Text(l10n.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.resetConfirm),
          ),
        ],
      ),
    );
    if (ok == true) provider.reset();
  }
}
