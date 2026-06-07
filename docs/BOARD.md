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
| FEAT-001 | **Internazionalizzazione reale IT/EN** (`flutter_localizations` + ARB) | 📅 Pianificato | 🟡 Media | 🟡 Medio | 6h | Oggi solo IT in `AppStrings` |
| FEAT-003 | **Esporre export CSV/JSON in UI** | 📅 Pianificato | 🟡 Media | 🟢 Basso | 1h | `exportToCsv/Json` esistono ma non collegati; README li promette |
| REFACTOR-001 | **Centralizzare le stringhe hardcoded residue** in `AppStrings` | 📅 Pianificato | 🟢 Bassa | 🟢 Basso | 2h | "Rimanenti", "Opzioni di Voto", ecc.; abilita FEAT-001 |
| TEST-001 | **Test unitari su `ScrutinyProvider`** (vote-log, vincitore, undo) | 📅 Pianificato | 🔴 Alta | 🟢 Basso | 4h | La logica critica è scoperta |
| FEAT-002 | **Redo** (oggi disabilitato nel modello a log sequenziale) | 📅 Pianificato | 🟢 Bassa | 🟡 Medio | 3h | Richiede redo-stack separato |
| PERF-001 | **Audit replay vote-log** su scrutini molto grandi | 📅 Pianificato | 🟢 Bassa | 🟢 Basso | 2h | `_recalculateState` rigioca tutto il log |

## Convenzioni ID

Prefissi progressivi per sezione: `FEAT-`, `FIX-`, `INFRA-`, `DOC-`, `TEST-`, `PERF-`.
Mappano ai prefissi dei conventional commit (vedi `docs/CONVENTIONAL_COMMITS.md`).

**Status:** 📅 Pianificato → 🏗️ In corso → ✅ Fatto
**Priorità:** 🔴 Alta · 🟡 Media · 🟢 Bassa
**Rischio:** 🔴 Alto · 🟡 Medio · 🟢 Basso
