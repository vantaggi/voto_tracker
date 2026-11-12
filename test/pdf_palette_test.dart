import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/services/pdf_palette.dart';
import 'package:voto_tracker/theme/app_theme.dart';

/// P6, C3: il verbale PDF usa i colori dello schema chiaro dell'app.
void main() {
  PdfColor c(Color color) => PdfColor.fromInt(color.toARGB32());

  test('i colori vengono dallo schema chiaro, anche col colore dinamico', () {
    final themes = AppThemes.from(systemPrimary: const Color(0xFF2E7D32));
    final scheme = themes.light.colorScheme;
    final p = PdfPalette.fromScheme(scheme);
    expect(p.accent, c(scheme.primary));
    expect(p.outcome, c(scheme.primaryContainer));
    expect(p.text, c(scheme.onSurface));
    // Diverso dal marchio indaco: segue davvero il colore del telefono.
    expect(p.accent, isNot(PdfPalette.brand.accent));
  });

  test('esito: vincitore, senza vincitore, in corso', () {
    final p = PdfPalette.brand;
    for (final s in [WinnerStatus.elected, WinnerStatus.mathematical]) {
      expect(p.outcomeColors(s), (p.outcome, p.onOutcome));
    }
    for (final s in [
      WinnerStatus.tie,
      WinnerStatus.noMajority,
      WinnerStatus.noQuorum,
    ]) {
      expect(p.outcomeColors(s), (p.inconclusive, p.onInconclusive));
    }
    expect(p.outcomeColors(WinnerStatus.none), (p.panel, p.text));
  });
}
