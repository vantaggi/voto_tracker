# Voto Tracker — istruzioni per Claude

Leggi prima `README.md` (Master Brain Index, Regole Assolute, ordine di lettura dei docs).
Questo file aggiunge solo comandi, definizione di "fatto" e trappole già pagate.

## Comandi

```bash
flutter pub get
flutter gen-l10n            # dopo ogni modifica a lib/l10n/*.arb
flutter analyze             # deve dire "No issues found!"
flutter test                # i golden (test/home_golden_test.dart) girano solo su Linux
flutter test --update-goldens test/home_golden_test.dart   # solo per cambi visivi voluti
dart format <file toccati>
flutter build apk --debug   # solo sul PC (nel cloud manca l'Android SDK)
```

Nel cloud Flutter non è preinstallato: scarica lo stable da
`https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json` in `/tmp/flutter`.

## Fatto = verificato

- `flutter analyze` pulito e `flutter test` verde, con comando ed esito scritti nel commit o nella PR.
- Cambi visivi: golden rigenerati e guardati, non solo aggiornati.
- `docs/BOARD.md`, `CHANGELOG.md` e, se sposti file, `docs/STRUCTURE.md` aggiornati nella stessa PR.
- Quello che serve provare a mano sul telefono va elencato nella PR.

## Trappole note

- Import Material da `package:material_ui/material_ui.dart`, mai `package:flutter/material.dart`
  (deprecato da Flutter 3.47).
- Delegate di localizzazione: sempre `appLocalizationsDelegates` (`lib/l10n/l10n_delegates.dart`).
  Quelli generati da gen-l10n con `material_ui` fanno ignorare l'italiano.
- `flutter pub get` e le build riscrivono i registranti in `windows/`, `linux/`, `macos/` e
  riformattano `lib/l10n/app_localizations*.dart`: se cambia solo l'ordine o la formattazione,
  ripristinali con `git checkout` prima di committare.
- Build di debug Android: package `com.cioti.voto_tracker.debug`, convive con la release.
  Mai disinstallare la release dal telefono per provare: si perdono gli scrutini salvati.
- `android/gradle.properties` ha `kotlin.incremental=false`: serve con il progetto su D: e la
  pub cache su C: (Windows).
- Chiave di firma della release: non è nel repo. Sta in OneDrive di Cioti
  (`Documenti\Key-ANDROID\VotoTracker\`), vedi "Chiave di firma" in `PLAY_STORE_LISTING.md`.
  Mai generarne una nuova né stampare le password di `key.properties`.
