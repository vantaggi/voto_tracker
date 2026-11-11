# 🗳️ Voto Tracker — Project Board

Source of Truth per task, idee e avanzamento. Leggibile da umani e IA.
Se un'informazione può stare qui, **non creare un nuovo `.md`**: il BOARD è
l'unico posto dove vive lo stato dei task.

## 🚀 Stato Corrente: v1.2.0

**Branch attivo:** claude/project-thread-0j7sox (Fasi 2-4, PR in bozza) · **Ultimo aggiornamento:** 2026-11-12

L'app è funzionante e pubblicabile. Backlog Wave 1/1.1/2 completato: kit
documentale, audit & bugfix, test, redo, performance e i18n IT/EN.

## 🎯 Wave 1 — Fondamenta AI-driven (giugno 2026)

| ID | Task | Status | Priorità | Rischio | Stima | Target |
|:--|:--|:--:|:--:|:--:|:--:|:--:|
| DOC-001 | **README come Master Brain Index** (AI Guide + Regole Assolute) | ✅ Fatto | 🔴 Alta | 🟢 Basso | - | 2026-06-07 |
| DOC-002 | **docs/STRUCTURE, PROJECT_GUIDE, DESIGN_SYSTEM, CONVENTIONAL_COMMITS** | ✅ Fatto | 🔴 Alta | 🟢 Basso | - | 2026-06-07 |
| DOC-003 | **CHANGELOG.md** (Keep a Changelog + semver) | ✅ Fatto | 🟡 Media | 🟢 Basso | - | 2026-06-07 |
| INFRA-001 | **Flotta subagent** in `.claude/agents/` | ✅ Fatto | 🟡 Media | 🟢 Basso | - | 2026-06-07 |
| INFRA-002 | **Script di versioning manuale** (`scripts/bump_version.py`) | ✅ Fatto | 🟡 Media | 🟢 Basso | - | 2026-06-07 |
| INFRA-003 | **Rimosso il workflow CI `auto-version.yml`** (ghost version su ogni push) | ✅ Fatto | 🟡 Media | 🟢 Basso | - | 2026-06-07 |

## 🐞 Wave 1.1 — Audit & Bugfix (giugno 2026)

Esito dell'audit del codice + `dart analyze` (31 issue → 0).

| ID | Task | Status | Priorità | Rischio | Stima | Target |
|:--|:--|:--:|:--:|:--:|:--:|:--:|
| FIX-001 | **PDF export: classifica ordinata** (usava ordine originale) | ✅ Fatto | 🔴 Alta | 🟢 Basso | - | 2026-06-07 |
| FIX-002 | **Dispose dei controller** nel dialog di rinomina (leak) | ✅ Fatto | 🟡 Media | 🟢 Basso | - | 2026-06-07 |
| FIX-003 | **Clamp `totalVoters`/`participants`** nel costruttore `Settings` | ✅ Fatto | 🟡 Media | 🟢 Basso | - | 2026-06-07 |
| FIX-004 | **`winnerLabel` centralizzato + dicitura accurata** (no duplicazione) | ✅ Fatto | 🟡 Media | 🟢 Basso | - | 2026-06-07 |
| FIX-005 | **Azzera gli issue dell'analyzer** (`withValues`, codice morto, lint) | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | 2026-06-07 |

## 🔭 Wave 2 — Backlog candidato (idee, non pianificate)

| ID | Task | Status | Priorità | Rischio | Stima | Note |
|:--|:--|:--:|:--:|:--:|:--:|:--|
| FEAT-001 | **Internazionalizzazione reale IT/EN** (`flutter_localizations` + ARB) | ✅ Fatto | 🟡 Media | 🟡 Medio | - | ARB IT/EN, `context.l10n`, toggle lingua; 4 test l10n. Da verificare a runtime |
| REFACTOR-003 | **Rimuovere le costanti `AppStrings` UI ora superate da l10n** | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | `AppStrings` ridotto a 10 semi-dati non localizzati |
| FEAT-003 | **Esporre export CSV/JSON in UI** | ✅ Fatto | 🟡 Media | 🟢 Basso | - | `DataExportService` + voci nel menu di export |
| REFACTOR-001 | **Centralizzare le stringhe UI** di screen e widget in `AppStrings` | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | home_page, settings, proiettore, card, charts |
| REFACTOR-002 | **Localizzare le superfici di export** (PDF, social card, share text) | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | `ExportLabels` risolto da `context.l10n` e iniettato nei servizi |
| TEST-001 | **Test unitari su `ScrutinyProvider`** (vote-log, vincitore, undo) | ✅ Fatto | 🔴 Alta | 🟢 Basso | - | 14 test in `test/`, tutti verdi |
| FEAT-002 | **Redo** | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | Redo-stack nel provider; il pulsante UI esistente ora funziona |
| PERF-001 | **Aggiornamento incrementale dei voti** (no replay a ogni tap) | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | Da O(voti) a O(candidati) per voto; replay solo su load/reset |

## 🧱 Wave 3 — Modernizzazione, Fase 1: Fondamenta (novembre 2026)

Spec: `specs/fase-1-fondamenta.md`. Piano completo nel documento di modernizzazione.

| ID | Task | Status | Priorità | Rischio | Stima | Note |
|:--|:--|:--:|:--:|:--:|:--:|:--|
| INFRA-005a | **Migrazione a `material_ui` / `cupertino_ui`** (Flutter 3.47+) | ✅ Fatto | 🔴 Alta | 🟡 Medio | - | Corretto bug: italiano non riconosciuto con i delegate generati |
| INFRA-005b | **`flutter_lints` 6** + `dart fix` | ✅ Fatto | 🟡 Media | 🟢 Basso | - | |
| INFRA-005c | **Dipendenze minori** aggiornate, SDK `^3.13.0` | ✅ Fatto | 🟡 Media | 🟢 Basso | - | |
| INFRA-005d | **Major:** share_plus 13, file_picker 13, wakelock_plus 1.8, fl_chart 1.3 | 🏗️ In corso | 🟡 Media | 🟡 Medio | - | Codice migrato; da verificare a mano in locale (export, import, grafici, build Android) |
| REFACTOR-004a | **Wakelock fuori dal `build`** con conteggio delle richieste | ✅ Fatto | 🟡 Media | 🟢 Basso | - | `KeepScreenOn` + `WakelockService` |
| REFACTOR-004b | **`ExportController`** + `export_sheet.dart` | ✅ Fatto | 🟡 Media | 🟢 Basso | - | `home_page.dart` 167 → 77 righe |
| REFACTOR-004c | **Split dei widget** sopra 200 righe | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | Golden della Home invariati |
| DOC-004 | **Docs allineate** (testi da ARB, `material_ui`, nuova struttura) | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | |

## 🌙 Wave 4 — Modernizzazione, Fasi 2-4 (notte 11→12 novembre 2026)

Spec: `specs/notte-2026-11-11.md`. Fatto nel cloud con Flutter 3.50; la prova sul
telefono resta da fare (vedi PR).

| ID | Task | Status | Priorità | Rischio | Stima | Note |
|:--|:--|:--:|:--:|:--:|:--:|:--|
| DOC-005 | **`CLAUDE.md` del repo** | ✅ Fatto | 🟡 Media | 🟢 Basso | - | Comandi, definizione di fatto, trappole note |
| UI-001 | **Colore dinamico** (`dynamic_color`) con ripiego indigo | 🏗️ In corso | 🔴 Alta | 🟡 Medio | - | Interruttore in Impostazioni → Aspetto; da provare su Android 12+ |
| UI-002 | **Palette candidati HCT**, contrasto ≥ 3:1 in light e dark | ✅ Fatto | 🟡 Media | 🟢 Basso | - | Nero puro delle nulle 1.2 → grigio scuro al caricamento |
| UI-003 | **Token** `AppSpacing` / `AppShapes` / `AppTouch`, `TrendColors` | ✅ Fatto | 🟡 Media | 🟢 Basso | - | `test/design_tokens_test.dart` blocca i letterali |
| UI-004 | **Edge-to-edge, Semantics, testo grande** | 🏗️ In corso | 🟡 Media | 🟡 Medio | - | Test con textScaler 2.0; da provare con TalkBack e Android 15 |
| REFACTOR-005 | **`ScrutinyEngine`** puro in `lib/domain/` | ✅ Fatto | 🔴 Alta | 🟡 Medio | - | Magic number ora solo fra candidati reali |
| REFACTOR-006 | **`ScrutinyRepository`** schema v2 + migrazione v1 | 🏗️ In corso | 🔴 Alta | 🔴 Alto | - | Test con dati 1.2; da provare aggiornando sopra una debug con dati |
| FEAT-004 | **Archivio scrutini** (nuovo, duplica, riapri, rinomina, elimina) | ✅ Fatto | 🔴 Alta | 🟡 Medio | - | |
| UI-005 | **Navigazione adattiva** Scrutinio / Archivio | ✅ Fatto | 🟡 Media | 🟢 Basso | - | NavigationBar < 600 dp, NavigationRail sopra |
| FEAT-005 | **Regole**: relativa, assoluta, quorum di affluenza | ✅ Fatto | 🟡 Media | 🟡 Medio | - | Esiti Ballottaggio / Quorum non raggiunto |
| FEAT-006 | **Lettura scheda** | ✅ Fatto | 🟡 Media | 🟢 Basso | - | Protezione dai doppi tocchi (350 ms) |
| DOC-006 | **Docs allineate** alla Wave 4 | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | |
| FEAT-007 | **Widget home screen / Quick Settings tile** | 📅 Pianificato | 🟢 Bassa | 🟡 Medio | - | Codice nativo, rimandato (piano, Fase 4) |
| FEAT-008 | **Liste e preferenze** (voto di lista) | 📅 Pianificato | 🟢 Bassa | 🔴 Alto | - | Cambia il modello dati, serve una spec |
| FIX-006 | **Dialog modifica candidato:** controller liberati prima della fine dell'animazione | ✅ Fatto | 🔴 Alta | 🟢 Basso | - | Schermo rosso sul telefono alla prima prova; riprodotto e coperto da `test/edit_candidate_dialog_test.dart` |

## Convenzioni ID

Prefissi progressivi per sezione: `FEAT-`, `FIX-`, `INFRA-`, `DOC-`, `TEST-`, `PERF-`.
Mappano ai prefissi dei conventional commit (vedi `docs/CONVENTIONAL_COMMITS.md`).

**Status:** 📅 Pianificato → 🏗️ In corso → ✅ Fatto
**Priorità:** 🔴 Alta · 🟡 Media · 🟢 Bassa
**Rischio:** 🔴 Alto · 🟡 Medio · 🟢 Basso
