# 🗂️ Voto Tracker — Mappa della Struttura

> Mappa completa di file e cartelle. Aggiornala quando aggiungi/sposti file.
> Responsabilità unica di questo documento: **dove sta cosa**.

## Albero `lib/` (codice applicativo)

```
lib/
├── main.dart                          # Entry point: Provider + MaterialApp + tema
│
├── models/                            # Modelli dati puri (+ JSON)
│   ├── candidate.dart                 # Candidate: name, votes, color, rank, previousPercentage
│   └── settings.dart                  # Settings: totalVoters, participantsCount, schede bianche/nulle
│
├── providers/
│   └── scrutiny_provider.dart         # ChangeNotifier centrale: vote-log, calcolo vincitore, undo, export
│
├── screens/
│   ├── home_page.dart                 # Schermata principale (grafici + controlli, responsive)
│   ├── projector_mode_screen.dart     # Modalità proiettore fullscreen
│   └── settings_dialog.dart           # Dialog di configurazione scrutinio
│
├── widgets/
│   ├── candidate_card.dart            # Card singolo candidato: voto +/-, %, swing, stato
│   ├── candidates_section.dart        # Lista/griglia delle candidate card
│   ├── charts_section.dart            # Tab Corrente / Storico / Percentuali (fl_chart)
│   └── social_results_card.dart       # Card renderizzata per l'immagine social
│
├── services/
│   ├── configuration_service.dart     # Import/export configurazione candidati (JSON via file_picker)
│   ├── data_export_service.dart       # Export risultati grezzi CSV/JSON (condivisione file)
│   ├── pdf_export_service.dart        # Report PDF a pagina singola (package pdf/printing)
│   └── social_share_service.dart      # Screenshot di SocialResultsCard → condivisione PNG
│
├── theme/
│   └── app_theme.dart                 # Tema Material 3, seed indigo, light/dark
│
└── utils/
    └── app_constants.dart             # AppStrings (testi IT) + AppDimensions (spaziature/raggi)
```

## Cartelle di piattaforma (generate da Flutter)

```
android/   ios/   linux/   macos/   windows/   web/   test/
```

Non modificare a mano i file generati salvo necessità (icone, manifest, versione).
La versione canonica dell'app vive in `pubspec.yaml` (`version: X.Y.Z+build`).

## Documentazione (`docs/` + root)

```
README.md                       # Master Brain Index + AI Guide + Regole Assolute
CHANGELOG.md                    # Storico per versione (Keep a Changelog + semver)
PRIVACY_POLICY.md               # Informativa privacy (store)
PLAY_STORE_LISTING.md           # Testi per la scheda Play Store
docs/
├── STRUCTURE.md                # Questo file
├── BOARD.md                    # Source of truth dei task (Wave)
├── PROJECT_GUIDE.md            # Architettura, algoritmi, decisioni tecniche
├── CONVENTIONAL_COMMITS.md     # Formato commit → changelog automatico
└── DESIGN_SYSTEM.md            # Token UI Material 3 + regole di stile
```

## Automazione & agenti

```
.claude/agents/                 # Flotta di subagent specializzati (vedi BOARD/PROJECT_GUIDE)
├── flutter-logic.md            # Logica: provider, modelli, calcolo, persistenza
├── flutter-ui.md               # UI: widget, screen, tema, grafici
├── testing.md                  # flutter test, smoke, debug flaky
├── git-github.md               # Branch, conventional commit, PR
├── documentation.md            # Sync README/BOARD/CHANGELOG/STRUCTURE
└── release-android.md          # Build release, versioning, scheda Play Store

scripts/
└── bump_version.py             # Bump MANUALE di pubspec.yaml + rigenera CHANGELOG (alla release)
```
