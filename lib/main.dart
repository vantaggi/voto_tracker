import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/l10n_delegates.dart';
import 'package:voto_tracker/providers/appearance_provider.dart';
import 'package:voto_tracker/providers/locale_provider.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/theme/app_theme.dart';

/// Chiave stabile del Navigator: sopravvive ai rebuild di `MaterialApp` causati
/// dal cambio lingua, evitando che l'overlay (es. barriere dei dialog) si
/// desincronizzi e blocchi i tap.
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const VotoTrackerApp());
}

class VotoTrackerApp extends StatelessWidget {
  const VotoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScrutinyProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AppearanceProvider()),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return Consumer2<LocaleProvider, AppearanceProvider>(
            builder: (context, localeProvider, appearance, _) {
              final themes = AppThemes.from(
                systemPrimary: appearance.useSystemColors
                    ? lightDynamic?.primary
                    : null,
              );
              return Provider<AppThemes>.value(
                value: themes,
                child: MaterialApp(
                  navigatorKey: _navigatorKey,
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context).appTitle,
                  debugShowCheckedModeBanner: false,
                  theme: themes.light,
                  darkTheme: themes.dark,
                  themeMode: ThemeMode.system,
                  locale: localeProvider.locale,
                  localizationsDelegates: appLocalizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const HomePage(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
