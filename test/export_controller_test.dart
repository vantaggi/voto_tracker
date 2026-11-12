import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/services/export_controller.dart';

Future<ScrutinyProvider> _provider({required int voters}) async {
  SharedPreferences.setMockInitialValues({});
  final p = ScrutinyProvider();
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  p.updateSettings(
    Settings(
      totalVoters: voters,
      participantsCount: 2,
      showBlankVotes: false,
      showNullVotes: false,
    ),
  );
  await Future<void>.delayed(Duration.zero);
  return p;
}

/// C1: una sola fotografia dei risultati per tutti gli export.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final en = lookupAppLocalizations(const Locale('en'));
  final it = lookupAppLocalizations(const Locale('it'));
  final now = DateTime(2026, 11, 12, 10, 28);

  test('titolo predefinito con la data, nella lingua', () async {
    final p = await _provider(voters: 4);
    final (s, f) = await ExportController(p, it, clock: () => now).snapshot();
    expect(s.title, startsWith('Scrutinio del '));
    expect(f.decimalComma, isTrue);
    expect(s.at, now);
    final (e, fe) = await ExportController(p, en, clock: () => now).snapshot();
    expect(e.title, isNot(s.title));
    expect(fe.decimalComma, isFalse);
  });

  test('titolo scelto dall\'utente', () async {
    final p = await _provider(voters: 4);
    await p.renameScrutiny(p.currentScrutinyId!, 'Consiglio 3B');
    final (s, _) = await ExportController(p, it).snapshot();
    expect(s.title, 'Consiglio 3B');
  });

  test('pareggio ed eletto', () async {
    final p = await _provider(voters: 2);
    p.vote(0);
    p.vote(1);
    var (s, _) = await ExportController(p, it).snapshot();
    expect(s.status, WinnerStatus.tie);
    expect(s.winnerName, isNull);
    expect(s.isComplete, isTrue);

    final q = await _provider(voters: 3);
    q.vote(0);
    q.vote(0);
    q.vote(1);
    (s, _) = await ExportController(q, en).snapshot();
    expect(s.status, WinnerStatus.elected);
    expect(s.winnerName, q.candidates[0].name);
    expect(s.rows.first.rank, 1);
    expect(s.scrutiny!.voteLog, [0, 0, 1]);
  });
}
