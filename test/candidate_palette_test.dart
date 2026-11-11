import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/theme/app_theme.dart';
import 'package:voto_tracker/theme/candidate_palette.dart';

void main() {
  final surfaces = {
    'light': AppTheme.lightTheme.colorScheme.surface,
    'dark': AppTheme.darkTheme.colorScheme.surface,
  };
  final all = [
    ...CandidatePalette.candidates,
    CandidatePalette.blank,
    CandidatePalette.spoiled,
  ];

  test('8 colori candidati distinti', () {
    expect(CandidatePalette.candidates.toSet(), hasLength(8));
  });

  for (final entry in surfaces.entries) {
    test('contrasto >= 3:1 sulla superficie ${entry.key}', () {
      for (final c in all) {
        expect(
          CandidatePalette.contrast(c, entry.value),
          greaterThanOrEqualTo(3.0),
          reason: 'colore ${c.toARGB32().toRadixString(16)}',
        );
      }
    });
  }

  test('testo sul colore (onColor) con contrasto >= 4.5:1', () {
    for (final c in all) {
      final on = CandidatePalette.onColor(c);
      expect(
        CandidatePalette.contrast(c, on),
        greaterThanOrEqualTo(4.5),
        reason: 'colore ${c.toARGB32().toRadixString(16)}',
      );
    }
  });

  test('il nero puro salvato fino alla 1.2 diventa il grigio delle nulle', () {
    final c = Candidate.fromJson({
      'name': 'Schede Nulle',
      'votes': 3,
      'color': 0xFF000000,
    });
    expect(c.color, CandidatePalette.spoiled);
    expect(c.type, CandidateType.spoiled);
  });
}
