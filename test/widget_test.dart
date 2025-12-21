import 'package:flutter_test/flutter_test.dart';
import 'package:voto_tracker/main.dart'; // Ensure this points to where VotoTrackerApp is defined

void main() {
  testWidgets('App smoke test - verifies title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VotoTrackerApp());

    // Verify that the app title is displayed on the AppBar
    // "Voto Tracker" is the title in AppStrings and likely shown in AppBar
    expect(find.text('Voto Tracker'), findsOneWidget);
  });
}
