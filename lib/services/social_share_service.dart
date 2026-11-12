import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/export_format.dart';
import 'package:voto_tracker/services/results_snapshot.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/social_results_card.dart';

/// Cattura [SocialResultsCard] a 1080 × 1350 px e la condivide (C2).
class SocialShareService {
  const SocialShareService._();

  /// `false` se la cattura o la condivisione falliscono.
  static Future<bool> shareResults({
    required ResultsSnapshot snapshot,
    required AppLocalizations l10n,
    required ExportFormat format,
    required ThemeData theme,
  }) async {
    try {
      final Uint8List image = await ScreenshotController().captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Theme(
              data: theme,
              child: SocialResultsCard(
                snapshot: snapshot,
                l10n: l10n,
                format: format,
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 10),
        pixelRatio: AppDimensions.socialPixelRatio,
      );
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/${ExportFormat.fileName(snapshot.title, snapshot.at, 'png')}',
      );
      await file.writeAsBytes(image);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: l10n.exportShareText(snapshot.title),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Errore condivisione immagine: $e');
      return false;
    }
  }
}
