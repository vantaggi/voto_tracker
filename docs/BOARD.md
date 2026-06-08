# 🗳️ Voto Tracker — Project Board

Source of Truth per task, idee e avanzamento. Leggibile da umani e IA.
Se un'informazione può stare qui, **non creare un nuovo `.md`**: il BOARD è
l'unico posto dove vive lo stato dei task.

## 🚀 Stato Corrente: v1.1.0

**Branch attivo:** master · **Ultimo aggiornamento:** 2026-06-07

L'app è funzionante e pubblicabile. Questa Wave 1 introduce il "sistema operativo"
documentale e di automazione (AI Workflow Kit) sopra al codice esistente.

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
| REFACTOR-003 | **Rimuovere le costanti `AppStrings` UI ora superate da l10n** | 📅 Pianificato | 🟢 Bassa | 🟢 Basso | 1h | Restano solo dati per provider/servizi |
| FEAT-003 | **Esporre export CSV/JSON in UI** | ✅ Fatto | 🟡 Media | 🟢 Basso | - | `DataExportService` + voci nel menu di export |
| REFACTOR-001 | **Centralizzare le stringhe UI** di screen e widget in `AppStrings` | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | home_page, settings, proiettore, card, charts |
| REFACTOR-002 | **Centralizzare le stringhe di export** (PDF, social card, share text) | 📅 Pianificato | 🟢 Bassa | 🟢 Basso | 1h | Molte interpolate; superficie separata |
| TEST-001 | **Test unitari su `ScrutinyProvider`** (vote-log, vincitore, undo) | ✅ Fatto | 🔴 Alta | 🟢 Basso | - | 14 test in `test/`, tutti verdi |
| FEAT-002 | **Redo** | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | Redo-stack nel provider; il pulsante UI esistente ora funziona |
| PERF-001 | **Aggiornamento incrementale dei voti** (no replay a ogni tap) | ✅ Fatto | 🟢 Bassa | 🟢 Basso | - | Da O(voti) a O(candidati) per voto; replay solo su load/reset |

## Convenzioni ID

Prefissi progressivi per sezione: `FEAT-`, `FIX-`, `INFRA-`, `DOC-`, `TEST-`, `PERF-`.
Mappano ai prefissi dei conventional commit (vedi `docs/CONVENTIONAL_COMMITS.md`).

**Status:** 📅 Pianificato → 🏗️ In corso → ✅ Fatto
**Priorità:** 🔴 Alta · 🟡 Media · 🟢 Bassa
**Rischio:** 🔴 Alto · 🟡 Medio · 🟢 Basso
