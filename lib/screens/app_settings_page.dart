import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/appearance_provider.dart';
import 'package:voto_tracker/providers/locale_provider.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Impostazioni dell'app (D3): lingua e aspetto, valgono per tutti gli
/// scrutini. Si apre dal menu ⋮ dell'Archivio e dal fondo delle impostazioni
/// dello scrutinio.
class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const AppSettingsPage()),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleProvider>().locale;
    final appearance = context.watch<AppearanceProvider>();
    final selected = locale?.languageCode ?? 'system';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appSettingsTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          children: [
            _Header(l10n.language),
            RadioGroup<String>(
              groupValue: selected,
              onChanged: (value) {
                if (value == null) return;
                context.read<LocaleProvider>().setLocale(
                  value == 'system' ? null : Locale(value),
                );
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'system',
                    title: Text(l10n.languageSystem),
                  ),
                  RadioListTile<String>(
                    value: 'it',
                    title: Text(l10n.languageItalian),
                  ),
                  RadioListTile<String>(
                    value: 'en',
                    title: Text(l10n.languageEnglish),
                  ),
                ],
              ),
            ),
            const Divider(),
            _Header(l10n.appearance),
            SwitchListTile(
              title: Text(l10n.useSystemColors),
              subtitle: Text(l10n.useSystemColorsSubtitle),
              value: appearance.useSystemColors,
              onChanged: (value) =>
                  context.read<AppearanceProvider>().setUseSystemColors(value),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.l,
      AppSpacing.l,
      AppSpacing.l,
      AppSpacing.s,
    ),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    ),
  );
}
