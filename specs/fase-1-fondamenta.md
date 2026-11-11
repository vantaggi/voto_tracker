# Fase 1 — Fondamenta (target v1.3.0)

Prima fase del piano di modernizzazione
([documento](https://claude.ai/artifact/VnLmJ43GrRTrfTj6KWbKz2)). Obiettivo: base pulita e
aggiornata **senza cambiare il comportamento visibile** dell'app. Le fasi successive (design
system, modello dati v2) partono da qui.

## Stato misurato (2026-11-11, Flutter 3.50.0 stable nel cloud)

- `flutter test`: **27 test, tutti verdi**.
- `flutter analyze`: **19 info**, tutte `deprecated_member_use`:
  - 17 file importano `package:flutter/material.dart`, deprecato da Flutter 3.47: Material e
    Cupertino sono usciti dal framework nei package `material_ui` (1.11.0) e `cupertino_ui` (1.1.6).
  - `lib/l10n/app_localizations.dart` (generato) usa `GlobalMaterialLocalizations` e
    `GlobalCupertinoLocalizations` dal vecchio percorso.
- `l10n.yaml`: l'opzione `synthetic-package` non ha più effetto (avviso di `flutter pub get`).
- `flutter pub get` con 3.50 riscrive `analysis_options.yaml` (esclude build e cartelle di
  piattaforma) e 2 file generati di `windows/flutter/`.
- Dipendenze indietro di una o più major: `flutter_lints` 2.0.3 → 6.0.0, `fl_chart` 0.68 → 1.3.1,
  `share_plus` 10 → 13, `file_picker` 8 → 13, `wakelock_plus` 1.4 → 1.8.

## Passi (uno per commit, ognuno verificato con analyze + test)

| ID | Passo | Criterio di accettazione |
| --- | --- | --- |
| INFRA-005a | Migrare a `material_ui` / `cupertino_ui`; togliere `synthetic-package`; rigenerare l10n; accettare il nuovo `analysis_options.yaml` | `flutter analyze` → 0 issue; 27 test verdi |
| INFRA-005b | `flutter_lints` 6 + `dart fix --apply` sui nuovi lint | 0 issue; nessuna modifica di comportamento nei test |
| INFRA-005c | Aggiornare le dipendenze minori (`pdf`, `printing`, `shared_preferences`, `intl`, `path_provider`) | 0 issue; test verdi |
| INFRA-005d | Major con breaking change, una per commit: `wakelock_plus`, `share_plus`, `file_picker`, `fl_chart` | 0 issue; test verdi; **verifica manuale in locale** di export/condivisione e grafici |
| REFACTOR-004a | Wakelock attivato in `initState` e spento in `dispose` (Home diventa `StatefulWidget`), non più a ogni `build` | Test widget: `enable` chiamato una volta per ciclo di vita |
| REFACTOR-004b | `ExportController`: un solo punto che prepara i dati per PDF, PNG, CSV, JSON; `home_page.dart` passa da 4 blocchi duplicati a 4 chiamate | Test unitario sul controller; `home_page.dart` < 100 righe |
| REFACTOR-004c | Split di `charts_section.dart` (502 righe) e `candidates_section.dart` (331) in file < 200 righe | Nessuna modifica visiva (golden test della Home prima e dopo, light e dark) |
| DOC-004 | Allineare `docs/DESIGN_SYSTEM.md`, `docs/STRUCTURE.md`, agente `flutter-logic` (testi da ARB, non `AppStrings`); BOARD Wave 3; CHANGELOG | Nessun file cita più `AppStrings` come fonte dei testi UI |

Fuori scope: colore dinamico, nuova navigazione, modello dati v2 (fasi 2 e 3); una CI GitHub
Actions (la CI dei repo privati oggi non parte per il blocco di billing).

## Verifica

- Nel cloud: `flutter analyze` e `flutter test` con Flutter 3.50.0 (scaricato nella sessione).
- In locale (Windows, `D:\flutter`): build Android e prova a mano di export PDF/PNG/CSV/JSON,
  import configurazione, modalità proiettore, dopo INFRA-005d.

## Domande aperte

1. Che versione di Flutter hai in `D:\flutter`? `material_ui` richiede Flutter ≥ 3.47: se è più
   vecchia va aggiornata prima di INFRA-005a, altrimenti in locale non compila.
2. Le major di INFRA-005d (soprattutto `fl_chart` 1.x e `file_picker` 13) possono cambiare
   leggermente l'aspetto dei grafici e il selettore file: va bene farle in questa fase o le
   rimandiamo alla Fase 2?
