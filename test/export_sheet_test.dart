import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/main.dart';

void main() {
  testWidgets('il menu export mostra le 4 opzioni e si chiude', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const VotoTrackerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.ios_share));
    await tester.pumpAndSettle();
    for (final icon in [
      Icons.image,
      Icons.picture_as_pdf,
      Icons.table_chart_outlined,
      Icons.data_object,
    ]) {
      expect(find.byIcon(icon), findsOneWidget);
    }
    expect(find.textContaining('Share “'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10)); // fuori dal sheet
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.data_object), findsNothing);
  });
}
