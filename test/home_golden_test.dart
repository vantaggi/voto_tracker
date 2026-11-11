import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';

/// Golden della Home con alcuni voti, per accorgersi di modifiche visive non
/// volute durante i refactoring. I PNG sono generati su Linux (cloud): su altri
/// sistemi il rendering differisce di qualche pixel, quindi lì vengono saltati.
/// Rigenera con: flutter test --update-goldens test/home_golden_test.dart
void main() {
  final skip = !Platform.isLinux;

  for (final size in const [Size(1400, 900), Size(420, 900)]) {
    for (final brightness in Brightness.values) {
      final name =
          'home_${size.width.toInt()}x${size.height.toInt()}_${brightness.name}';
      testWidgets(name, skip: skip, (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({});

        await tester.pumpWidget(const VotoTrackerApp());
        await tester.pumpAndSettle();
        for (final i in [0, 0, 1, 0, 2]) {
          await tester.tap(find.byIcon(Icons.add).at(i));
          await tester.pump();
        }
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(VotoTrackerApp),
          matchesGoldenFile('goldens/$name.png'),
        );
      });
    }
  }
}
