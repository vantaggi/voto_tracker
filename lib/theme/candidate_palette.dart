import 'package:material_ui/material_ui.dart';

/// Colori identificativi dei candidati. Sono **dati** (persistiti con il
/// candidato), non token di tema, quindi devono funzionare sia in light sia
/// in dark.
///
/// Generati in HCT (Material Color Utilities) con tono 52 e croma 70 su 8
/// tinte equidistanti: ogni colore ha contrasto ≥ 3:1 sia sulla superficie
/// chiara sia su quella scura del tema (WCAG 1.4.11, componenti grafici),
/// verificato da `test/candidate_palette_test.dart`.
class CandidatePalette {
  CandidatePalette._();

  static const List<Color> candidates = [
    Color(0xFFD84B41), // rosso (h 25)
    Color(0xFF007FD7), // blu (h 255)
    Color(0xFF049023), // verde (h 145)
    Color(0xFFBA6700), // arancio (h 60)
    Color(0xFF8C5FF2), // viola (h 300)
    Color(0xFF008B83), // verde acqua (h 190)
    Color(0xFFCF4899), // rosa (h 350)
    Color(0xFF8E7C00), // oliva (h 100)
  ];

  /// Schede bianche: grigio chiaro (tono 58).
  static const Color blank = Color(0xFF8B8B8B);

  /// Schede nulle: grigio scuro (tono 45). Prima era nero puro, invisibile
  /// sul tema scuro.
  static const Color spoiled = Color(0xFF6A6A6A);

  static Color forIndex(int index) => candidates[index % candidates.length];

  /// Colore da mostrare: i dati salvati dalle versioni ≤ 1.2 possono avere il
  /// nero puro per le schede nulle, illeggibile su sfondo scuro.
  static Color display(Color stored) =>
      stored.toARGB32() == 0xFF000000 ? spoiled : stored;

  /// Bianco o nero, quello con contrasto maggiore su [background].
  static Color onColor(Color background) {
    final l = background.computeLuminance();
    final withWhite = 1.05 / (l + 0.05);
    final withBlack = (l + 0.05) / 0.05;
    return withWhite >= withBlack ? Colors.white : Colors.black;
  }

  /// Rapporto di contrasto WCAG fra due colori.
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }
}
