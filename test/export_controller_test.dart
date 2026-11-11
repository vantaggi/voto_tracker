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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final en = lookupAppLocalizations(const Locale('en'));
  final it = lookupAppLocalizations(const Locale('it'));

  test('nessun vincitore: nome e label nulli', () async {
    final c = ExportController(await _provider(voters: 4), en);
    expect(c.winnerName, isNull);
    expect(c.winnerLabel, isNull);
  });

  test('pareggio: nome = label di pareggio localizzata', () async {
    final p = await _provider(voters: 2);
    p.vote(0);
    p.vote(1);
    expect(ExportController(p, en).winnerName, 'Tie');
    expect(ExportController(p, en).winnerLabel, 'FINAL RESULT');
    expect(ExportController(p, it).winnerName, it.tie);
  });

  test('eletto: nome del candidato e label localizzata', () async {
    final p = await _provider(voters: 3);
    p.vote(0);
    p.vote(0);
    p.vote(1);
    final c = ExportController(p, en);
    expect(c.winnerName, p.sortedCandidates.first.name);
    expect(c.winnerLabel, 'ELECTED');
  });
}
