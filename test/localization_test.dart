import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/l10n_delegates.dart';
import 'package:voto_tracker/providers/locale_provider.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpWithLocale(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Column(
              children: [
                Text(l10n.settingsTooltip),
                Text(l10n.winnerElected),
                Text(l10n.votesToWin(3)),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('le stringhe sono in inglese con locale en', (tester) async {
    await pumpWithLocale(tester, const Locale('en'));
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('ELECTED'), findsOneWidget);
    expect(find.text('3 votes left to win'), findsOneWidget);
  });

  testWidgets('le stringhe sono in italiano con locale it', (tester) async {
    await pumpWithLocale(tester, const Locale('it'));
    expect(find.text('Impostazioni'), findsOneWidget);
    expect(find.text('ELETTO'), findsOneWidget);
    expect(find.text('Mancano 3 voti per la vittoria'), findsOneWidget);
  });

  group('LocaleProvider', () {
    test('setLocale aggiorna e persiste la lingua', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();
      expect(provider.locale, isNull); // default: segui il sistema

      await provider.setLocale(const Locale('en'));
      expect(provider.locale, const Locale('en'));

      await provider.setLocale(null);
      expect(provider.locale, isNull);
    });
  });

  group('nomi predefiniti dei candidati (P4)', () {
    test('i candidati nuovi prendono il nome nella lingua scelta', () async {
      SharedPreferences.setMockInitialValues({});
      final p = ScrutinyProvider();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(p.candidates.first.name, 'Candidato 1');

      p.renameCandidate(0, 'Rossi');
      p.setDefaultCandidateNamer(
        'en',
        lookupAppLocalizations(const Locale('en')).defaultCandidateName,
      );
      // Scrutinio senza schede: il nome scelto resta, il predefinito cambia.
      expect(p.candidates.take(2).map((c) => c.name), ['Rossi', 'Candidate 2']);
      await p.newScrutiny();
      expect(p.candidates.map((c) => c.name).take(2), [
        'Candidate 1',
        'Candidate 2',
      ]);
      p.dispose();
    });

    test('con schede già registrate i nomi non cambiano', () async {
      SharedPreferences.setMockInitialValues({});
      final p = ScrutinyProvider();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      p.vote(0);
      p.setDefaultCandidateNamer(
        'en',
        lookupAppLocalizations(const Locale('en')).defaultCandidateName,
      );
      expect(p.candidates.first.name, 'Candidato 1');
      p.dispose();
    });

    testWidgets('l\'app imposta il nome dalla sua lingua', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) =>
                Text(AppLocalizations.of(context).defaultCandidateName(3)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Candidate 3'), findsOneWidget);
    });
  });
}
