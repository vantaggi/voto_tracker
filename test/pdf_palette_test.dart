import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/export_labels.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/services/pdf_export_service.dart';
import 'package:voto_tracker/services/pdf_palette.dart';
import 'package:voto_tracker/theme/app_theme.dart';

/// P6: il PDF usa l'esito nuovo e i colori dello schema chiaro dell'app.
void main() {
  PdfColor c(Color color) => PdfColor.fromInt(color.toARGB32());

  test('i colori vengono dallo schema chiaro, anche col colore dinamico', () {
    final themes = AppThemes.from(systemPrimary: const Color(0xFF2E7D32));
    final scheme = themes.light.colorScheme;
    final p = PdfPalette.fromScheme(scheme);
    expect(p.header, c(scheme.primary));
    expect(p.onHeader, c(scheme.onPrimary));
    expect(p.strip, c(scheme.primaryContainer));
    // Diverso dal marchio indaco: segue davvero il colore del telefono.
    expect(p.header, isNot(PdfPalette.brand.header));
  });

  test('esito senza vincitore: colori neutri, non quelli della vittoria', () {
    final p = PdfPalette.brand;
    expect(p.outcomeColors(WinnerStatus.elected), (p.outcome, p.onOutcome));
    for (final s in [
      WinnerStatus.tie,
      WinnerStatus.noMajority,
      WinnerStatus.noQuorum,
    ]) {
      expect(p.outcomeColors(s), (p.inconclusive, p.onInconclusive));
    }
  });

  group('testo dell\'esito', () {
    final it = lookupAppLocalizations(const Locale('it'));
    final labels = ExportLabels.of(it);

    String? text(WinnerStatus s, String? name) => PdfExportService.outcomeText(
      s == WinnerStatus.none ? null : localizedOutcomeHeadline(it, s, name),
      localizedWinnerLabel(it, s),
      labels,
    );

    test('nessun esito durante lo scrutinio', () {
      expect(text(WinnerStatus.none, null), isNull);
    });

    test('eletto, pareggio, ballottaggio, quorum', () {
      expect(text(WinnerStatus.elected, 'Rossi'), 'ELETTO: Rossi');
      expect(text(WinnerStatus.tie, null), 'RISULTATO FINALE: Pareggio');
      expect(
        text(WinnerStatus.noMajority, null),
        'RISULTATO FINALE: Ballottaggio',
      );
      expect(
        text(WinnerStatus.noQuorum, null),
        'RISULTATO FINALE: Quorum non raggiunto',
      );
    });

    test('con un pareggio nessuno è segnato in testa', () {
      expect(PdfExportService.marksLeader(WinnerStatus.tie), isFalse);
      expect(PdfExportService.marksLeader(WinnerStatus.none), isTrue);
      expect(PdfExportService.marksLeader(WinnerStatus.elected), isTrue);
    });
  });
}
