import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpWithLocale(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
    ));
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
}
