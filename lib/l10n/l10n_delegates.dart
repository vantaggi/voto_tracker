import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart' as material;
import 'package:voto_tracker/l10n/app_localizations.dart';

/// Delegate di localizzazione dell'app.
///
/// Da Flutter 3.47 Material e Cupertino vivono nei package `material_ui` e
/// `cupertino_ui`: il loro `MaterialApp` cerca le localizzazioni di quei
/// package. `AppLocalizations.localizationsDelegates` (generato da
/// `flutter gen-l10n`) fornisce ancora quelle di `flutter_localizations`, che
/// non vengono riconosciute: con locale `it` l'app mostrerebbe l'avviso
/// "locale non supportato". Usa sempre questa lista, mai quella generata.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  material.GlobalMaterialLocalizations.delegate,
  cupertino.GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];
