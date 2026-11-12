import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';

/// UI-003: nei widget e negli schermi niente valori di stile scritti a mano.
/// Spaziature e raggi vengono da `AppSpacing`/`AppShapes`, i colori dal tema
/// (o da `CandidatePalette`), le dimensioni del testo da `textTheme`.
void main() {
  final rules = <String, RegExp>{
    'Colors.* (tranne transparent)': RegExp(r'\bColors\.(?!transparent\b)\w+'),
    'fontSize numerico': RegExp(r'fontSize:\s*\d'),
    'EdgeInsets numerico': RegExp(
      r'EdgeInsets\.\w+\([^)]*(?<![\w.])[1-9]\d*(\.\d+)?(?![\w.])',
    ),
    'BorderRadius.circular numerico': RegExp(r'BorderRadius\.circular\(\d'),
    'SizedBox numerico': RegExp(r'SizedBox\((width|height):\s*\d'),
  };

  test('nessun letterale di stile in lib/widgets e lib/screens', () {
    final files = [
      ...Directory('lib/widgets').listSync(recursive: true),
      ...Directory('lib/screens').listSync(recursive: true),
    ].whereType<File>().where((f) => f.path.endsWith('.dart'));

    final violations = <String>[];
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final rule in rules.entries) {
          if (rule.value.hasMatch(lines[i])) {
            violations.add(
              '${file.path}:${i + 1} ${rule.key}: '
              '${lines[i].trim()}',
            );
          }
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  for (final size in const [Size(420, 900), Size(1400, 900)]) {
    testWidgets('Home: target di tocco ≥ 48 dp (${size.width.toInt()})', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const VotoTrackerApp());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });
  }
}
