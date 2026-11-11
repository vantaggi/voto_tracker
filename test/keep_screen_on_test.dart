import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voto_tracker/services/wakelock_service.dart';
import 'package:voto_tracker/widgets/keep_screen_on.dart';

void main() {
  late List<bool> calls;

  setUp(() {
    calls = [];
    WakelockService.reset();
    WakelockService.toggle = (enable) async => calls.add(enable);
  });

  testWidgets('attiva una sola volta anche con molti rebuild', (tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pumpWidget(
        KeepScreenOn(child: Text('$i', textDirection: TextDirection.ltr)),
      );
    }
    expect(calls, [true]);

    await tester.pumpWidget(const SizedBox());
    expect(calls, [true, false]);
  });

  testWidgets('chiudere il proiettore non spegne lo schermo della Home', (
    tester,
  ) async {
    Widget tree({required bool projector}) => KeepScreenOn(
      child: projector
          ? const KeepScreenOn(child: SizedBox())
          : const SizedBox(),
    );

    await tester.pumpWidget(tree(projector: true));
    expect(WakelockService.holders, 2);

    await tester.pumpWidget(tree(projector: false));
    expect(WakelockService.holders, 1);
    expect(calls, [true]);
  });
}
