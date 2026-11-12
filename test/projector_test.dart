import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/screens/projector_mode_screen.dart';
import 'package:voto_tracker/services/wakelock_service.dart';

import 'home_test_utils.dart';

/// S5: proiettore a schermo intero, bianche e nulle fuori classifica.
void main() {
  testWidgets('schermo intero, × per uscire, barre ripristinate', (
    tester,
  ) async {
    WakelockService.toggle = (_) async {};
    final modes = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemChrome.setEnabledSystemUIMode') {
          modes.add('${call.arguments}');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({'locale': 'it'});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();
    final p = Provider.of<ScrutinyProvider>(
      tester.element(find.byType(HomePage)),
      listen: false,
    );
    p.renameCandidate(0, 'Rossi');
    p.vote(0);
    p.vote(p.candidates.indexWhere((c) => c.isTechnical));
    await tester.pumpAndSettle();

    await openHomeProjector(tester);
    expect(modes.last, contains('immersiveSticky'));
    expect(find.byType(AppBar), findsNothing);
    // Bianche nel piè di pagina, non tra le righe numerate.
    expect(find.textContaining('Schede bianche'), findsOneWidget);
    expect(find.text('1° posto'), findsNothing);

    // La × sparisce da sola e ricompare con un tocco.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(640, 400));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Chiudi'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectorModeScreen), findsNothing);
    expect(modes.last, contains('edgeToEdge'));
  });
}
