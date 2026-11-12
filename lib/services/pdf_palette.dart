import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/theme/app_theme.dart';

/// Colori del report PDF presi dallo schema **chiaro** dell'app (P6): il PDF
/// si stampa su carta bianca, quindi non segue il tema scuro, ma segue il
/// colore dinamico. Così app e PDF hanno gli stessi toni.
class PdfPalette {
  const PdfPalette({
    required this.title,
    required this.subtitle,
    required this.strip,
    required this.onStrip,
    required this.divider,
    required this.border,
    required this.header,
    required this.onHeader,
    required this.stripe,
    required this.outcome,
    required this.onOutcome,
    required this.inconclusive,
    required this.onInconclusive,
  });

  /// Testi forti (titolo, numeri).
  final PdfColor title;

  /// Testi secondari del titolo e delle statistiche.
  final PdfColor subtitle;

  /// Fascia delle statistiche.
  final PdfColor strip;
  final PdfColor onStrip;
  final PdfColor divider;

  /// Bordi dei riquadri.
  final PdfColor border;

  /// Intestazione della tabella.
  final PdfColor header;
  final PdfColor onHeader;

  /// Righe alterne della tabella.
  final PdfColor stripe;

  /// Etichetta dell'esito con un vincitore.
  final PdfColor outcome;
  final PdfColor onOutcome;

  /// Etichetta dell'esito senza vincitore (pareggio, ballottaggio, quorum).
  final PdfColor inconclusive;
  final PdfColor onInconclusive;

  static PdfColor _c(Color c) => PdfColor.fromInt(c.toARGB32());

  factory PdfPalette.fromScheme(ColorScheme s) => PdfPalette(
    title: _c(s.onSurface),
    subtitle: _c(s.primary),
    strip: _c(s.primaryContainer),
    onStrip: _c(s.onPrimaryContainer),
    divider: _c(s.outlineVariant),
    border: _c(s.outlineVariant),
    header: _c(s.primary),
    onHeader: _c(s.onPrimary),
    stripe: _c(s.surfaceContainerHigh),
    outcome: _c(s.tertiaryContainer),
    onOutcome: _c(s.onTertiaryContainer),
    inconclusive: _c(s.secondaryContainer),
    onInconclusive: _c(s.onSecondaryContainer),
  );

  /// Colori del marchio (indaco), quando non c'è un tema a disposizione.
  static final PdfPalette brand = PdfPalette.fromScheme(
    AppThemes.brand.light.colorScheme,
  );

  /// Colori dell'etichetta per [status]: (sfondo, testo).
  (PdfColor, PdfColor) outcomeColors(WinnerStatus status) =>
      status.isInconclusive
      ? (inconclusive, onInconclusive)
      : (outcome, onOutcome);
}
