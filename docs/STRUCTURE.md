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
│   └── export_format.dart             # Date, decimali, variazioni e nomi file per gli export (senza context)
│
├── providers/
│   ├── scrutiny_provider.dart         # ChangeNotifier centrale: vote-log, undo/redo, archivio, export
│   ├── locale_provider.dart           # Lingua scelta (persistita); null = segui il sistema
│   └── appearance_provider.dart       # Colori di sistema sì/no (persistito)
│
├── screens/
│   ├── app_shell.dart                 # Navigazione Scrutinio / Archivio (NavigationBar o NavigationRail)
│   ├── home_page.dart                 # Home: riepilogo, righe, altre schede, grafici, barra Annulla; due colonne da 840 dp o in orizzontale (altezza < 500 dp)
│   ├── home_actions.dart              # Azioni della Home (impostazioni, lettura schede, proiettore, azzera con conferma)
│   ├── archive_page.dart              # Archivio: Aperto ora / Altri, ricerca, dettaglio (pagina o pannello), Nuovo vuoto/copia/lista, esporta/importa
│   ├── ballot_reading_screen.dart     # Lettura schede: tessere che riempiono lo schermo, bianche e nulle in fondo, barra Annulla
│   ├── projector_mode_screen.dart     # Proiettore a schermo intero: intestazione, righe animate, bianche e nulle in fondo
│   ├── settings_page.dart             # Impostazioni dello scrutinio: pagina sul telefono, finestra sul tablet
│   └── app_settings_page.dart         # Impostazioni dell'app: lingua e aspetto
│
├── widgets/
│   ├── vote_summary_card.dart         # Riepilogo: barra impilata, schede, chi è in testa, esito
│   ├── vote_stacked_bar.dart          # Barra impilata dei voti (Home, Archivio, Lettura, Proiettore, Condividi)
│   ├── candidate_row.dart             # Righe dei candidati e "Altre schede" (bianche, nulle)
│   ├── edit_candidate_dialog.dart     # Dialog "Modifica candidato" (nome, colore, risultato precedente)
│   ├── undo_bar.dart                  # Barra Annulla / Ripeti fissa in fondo, con il nome dell'ultimo voto
│   ├── charts_card.dart               # Card apribile Andamento / Confronto
│   ├── charts/                        # Un file per grafico (fl_chart)
│   │   ├── trend_chart.dart           # Andamento: linee a gradini, chip, lettura a una scheda
│   │   └── compare_chart.dart         # Confronto: barre con il risultato precedente
│   ├── export_sheet.dart              # Foglio Condividi: Immagine e PDF grandi, CSV e JSON piccoli
│   ├── keep_screen_on.dart            # Schermo acceso mentre la schermata è aperta
│   └── social_results_card.dart       # Immagine da condividere, 4:5
│
├── services/
│   ├── export_controller.dart         # Prepara lo stato per PNG/PDF/CSV/JSON (un solo punto)
│   ├── results_snapshot.dart          # Fotografia dei risultati comune a tutti gli export
│   ├── archive_transfer_service.dart  # Esporta/importa l'archivio in un file JSON (backup, cambio telefono)
│   ├── pdf_palette.dart               # Colori del PDF dallo schema chiaro dell'app
│   ├── wakelock_service.dart          # Wakelock con conteggio delle richieste
│   ├── configuration_service.dart     # Import/export configurazione candidati (JSON via file_picker)
│   ├── data_export_service.dart       # CSV per Excel e JSON nel formato dell'Archivio
│   ├── pdf_export_service.dart        # Verbale dei risultati PDF, più pagine (package pdf/printing)
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
Icona e splash Android: `res/mipmap-anydpi-v26/ic_launcher.xml` (adaptive),
`res/drawable/ic_launcher_*.xml`, temi `values*/styles.xml` (splash 12+ in
`values-v31`), colori in `values*/colors.xml`; la debug cambia icona e nome in
`android/app/src/debug/res/`. I disegni si rigenerano con `scripts/make_icons.py`.
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
├── bump_version.py             # Bump MANUALE di pubspec.yaml + rigenera CHANGELOG (alla release)
└── make_icons.py               # Icona e splash: genera vettoriali Android e PNG (Android, web, iOS, Play Store)
assets/icon/                    # SVG dell'icona (release e debug) e PNG 512 per il Play Store (non nel bundle)
l10n.yaml                       # Config gen-l10n (arb-dir, classe, output)
```
