import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:voto_tracker/domain/scrutiny_engine.dart';
import 'package:voto_tracker/theme/app_theme.dart';

/// Colori del verbale PDF presi dallo schema **chiaro** dell'app (P6): il PDF
/// si stampa su carta bianca, quindi non segue il tema scuro, ma segue il
/// colore dinamico. Così app e PDF hanno gli stessi toni.
class PdfPalette {
  const PdfPalette({
    required this.text,
    required this.textVariant,
    required this.line,
    required this.accent,
    required this.panel,
    required this.outcome,
    required this.onOutcome,
    required this.inconclusive,
    required this.onInconclusive,
  });

  /// Testi forti (titolo, numeri, nomi).
  final PdfColor text;

  /// Testi secondari (date, intestazioni, note).
  final PdfColor textVariant;

  /// Linee della tabella e griglia del grafico.
  final PdfColor line;

  /// "VERBALE DEI RISULTATI".
  final PdfColor accent;

  /// Riquadro del risultato provvisorio.
  final PdfColor panel;

  /// Riquadro dell'esito con un vincitore.
  final PdfColor outcome;
  final PdfColor onOutcome;

  /// Riquadro dell'esito senza vincitore (pareggio, ballottaggio, quorum).
  final PdfColor inconclusive;
  final PdfColor onInconclusive;

  static PdfColor of(Color c) => PdfColor.fromInt(c.toARGB32());

  factory PdfPalette.fromScheme(ColorScheme s) => PdfPalette(
    text: of(s.onSurface),
    textVariant: of(s.onSurfaceVariant),
    line: of(s.outlineVariant),
    accent: of(s.primary),
    panel: of(s.surfaceContainerHigh),
    outcome: of(s.primaryContainer),
    onOutcome: of(s.onPrimaryContainer),
    inconclusive: of(s.tertiaryContainer),
    onInconclusive: of(s.onTertiaryContainer),
  );

  /// Colori del marchio (indaco), quando non c'è un tema a disposizione.
  static final PdfPalette brand = PdfPalette.fromScheme(
    AppThemes.brand.light.colorScheme,
  );

  /// Colori del riquadro dell'esito per [status]: (sfondo, testo).
  (PdfColor, PdfColor) outcomeColors(WinnerStatus status) => switch (status) {
    WinnerStatus.elected || WinnerStatus.mathematical => (outcome, onOutcome),
    WinnerStatus.tie ||
    WinnerStatus.noMajority ||
    WinnerStatus.noQuorum => (inconclusive, onInconclusive),
    WinnerStatus.none => (panel, text),
  };
}
