import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voto_tracker/providers/appearance_provider.dart';
import 'package:voto_tracker/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('senza colore di sistema si usano i temi del brand', () {
    expect(identical(AppThemes.from(), AppThemes.brand), isTrue);
  });

  test('con colore di sistema lo schema nasce da quel colore', () {
    const green = Color(0xFF2E7D32);
    final themes = AppThemes.from(systemPrimary: green);
    expect(themes.light.colorScheme.brightness, Brightness.light);
    expect(themes.dark.colorScheme.brightness, Brightness.dark);
    expect(
      themes.light.colorScheme.primary,
      isNot(AppTheme.lightTheme.colorScheme.primary),
    );
    // Le tinte del primario restano nella famiglia del verde.
    final hue = HSLColor.fromColor(themes.light.colorScheme.primary).hue;
    expect(hue, inInclusiveRange(90, 160));
  });

  test('AppearanceProvider: default attivo, persiste la scelta', () async {
    SharedPreferences.setMockInitialValues({});
    final p = AppearanceProvider();
    await Future<void>.delayed(Duration.zero);
    expect(p.useSystemColors, isTrue);
    await p.setUseSystemColors(false);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('use_system_colors'), isFalse);

    final reloaded = AppearanceProvider();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(reloaded.useSystemColors, isFalse);
  });
}
