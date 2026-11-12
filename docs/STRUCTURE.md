# 🗂️ Voto Tracker — Mappa della Struttura

> Mappa completa di file e cartelle. Aggiornala quando aggiungi/sposti file.
> Responsabilità unica di questo documento: **dove sta cosa**.

## Albero `lib/` (codice applicativo)

```
lib/
├── main.dart                          # Entry point: Provider + DynamicColorBuilder + MaterialApp, edge-to-edge
│
├── domain/                            # Logica pura, senza Flutter né persistenza
│   └── scrutiny_engine.dart           # Tally, classifica, vincitore (regole, quorum), magic number, storico
│
├── data/
│   ├── scrutiny_repository.dart       # Archivio su shared_preferences, schema v2, migrazione v1 → v2
│   └── templates_repository.dart      # Liste di candidati e impostazioni predefinite (FEAT-008)
│
├── models/                            # Modelli dati puri (+ JSON)
│   ├── candidate.dart                 # Candidate: name, votes, color, rank, previousPercentage
│   ├── candidate_list.dart            # CandidateList: lista salvata di candidati + impostazioni
│   ├── scrutiny.dart                  # Scrutiny: id, titolo, date, impostazioni, candidati, registro
│   └── settings.dart                  # Settings: votanti, partecipanti, bianche/nulle, regola, quorum
│
├── l10n/                              # Localizzazione i18n
│   ├── app_en.arb                     # Stringhe inglese (template)
│   ├── app_it.arb                     # Stringhe italiano
│   ├── app_localizations*.dart        # AppLocalizations generato (flutter gen-l10n)
│   ├── l10n_delegates.dart            # Delegate di localizzazione (material_ui/cupertino_ui)
│   ├── l10n_ext.dart                  # context.l10n + helper nomi candidato / label vincitore
│   └── export_labels.dart             # Stringhe localizzate per PDF/social (servizi senza context)
│
├── providers/
│   ├── scrutiny_provider.dart         # ChangeNotifier centrale: vote-log, undo/redo, archivio, export
│   ├── locale_provider.dart           # Lingua scelta (persistita); null = segui il sistema
│   └── appearance_provider.dart       # Colori di sistema sì/no (persistito)
│
├── screens/
│   ├── app_shell.dart                 # Navigazione Scrutinio / Archivio (NavigationBar o NavigationRail)
│   ├── home_page.dart                 # Home: riepilogo, righe, altre schede, grafici, pillola; due colonne da 840 dp
│   ├── home_actions.dart              # Azioni della Home (impostazioni, lettura schede, proiettore, azzera con conferma)
│   ├── archive_page.dart              # Archivio: nuovo (anche da lista), duplica, riapri, rinomina, elimina, esporta/importa; due colonne sui tablet
│   ├── ballot_reading_screen.dart     # Lettura schede: una scheda alla volta
│   ├── projector_mode_screen.dart     # Modalità proiettore fullscreen (una riga parlata per candidato)
│   └── settings_dialog.dart           # Dialog di configurazione scrutinio
│
├── widgets/
│   ├── vote_summary_card.dart         # Riepilogo: barra impilata, schede, chi è in testa, esito
│   ├── candidate_row.dart             # Righe dei candidati e "Altre schede" (bianche, nulle)
│   ├── edit_candidate_dialog.dart     # Dialog "Modifica nome" (nome e risultato precedente)
│   ├── undo_pill.dart                 # Pillola Annulla / Ripeti con il nome dell'ultimo voto
│   ├── charts_card.dart               # Card apribile Storico / Percentuali
│   ├── charts/                        # Un file per grafico (fl_chart)
│   │   ├── history_chart.dart
│   │   └── percentage_chart.dart
│   ├── export_sheet.dart              # Bottom sheet delle esportazioni
│   ├── keep_screen_on.dart            # Schermo acceso mentre la schermata è aperta
│   └── social_results_card.dart       # Card renderizzata per l'immagine social
│
├── services/
│   ├── export_controller.dart         # Prepara lo stato per PNG/PDF/CSV/JSON (un solo punto)
│   ├── archive_transfer_service.dart  # Esporta/importa l'archivio in un file JSON (backup, cambio telefono)
│   ├── pdf_palette.dart               # Colori del PDF dallo schema chiaro dell'app
│   ├── wakelock_service.dart          # Wakelock con conteggio delle richieste
│   ├── configuration_service.dart     # Import/export configurazione candidati (JSON via file_picker)
│   ├── data_export_service.dart       # Export risultati grezzi CSV/JSON (condivisione file)
│   ├── pdf_export_service.dart        # Report PDF a pagina singola (package pdf/printing)
│   └── social_share_service.dart      # Screenshot di SocialResultsCard → condivisione PNG
│
├── theme/
│   ├── app_theme.dart                 # Tema Material 3: colore di sistema o seed indigo, light/dark
│   ├── candidate_palette.dart         # Colori dei candidati (HCT) e colore del testo sopra
│   └── trend_colors.dart              # ThemeExtension: verde/rosso dello swing
│
└── utils/
    └── app_constants.dart             # AppStrings, AppDimensions, AppSpacing, AppShapes, AppTouch
```

## Cartelle di piattaforma (generate da Flutter)

```
android/   ios/   linux/   macos/   windows/   web/   test/
```

`integration_test/app_flow_test.dart`: flusso completo da lanciare sul telefono
(`flutter test integration_test -d ID_TELEFONO`, build di debug, dati finti).

Non modificare a mano i file generati salvo necessità (icone, manifest, versione).
La versione canonica dell'app vive in `pubspec.yaml` (`version: X.Y.Z+build`).

## Documentazione (`docs/` + root)

```
README.md                       # Master Brain Index + AI Guide + Regole Assolute
CLAUDE.md                       # Comandi, definizione di fatto, trappole note (per Claude)
specs/                          # Spec delle fasi (fase-1-fondamenta, notte-2026-11-11)
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
l10n.yaml                       # Config gen-l10n (arb-dir, classe, output)
```
