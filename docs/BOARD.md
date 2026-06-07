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
| INFRA-002 | **Auto-versioning workflow** (`bump_version.py` + CI su master) | ✅ Fatto | 🟡 Media | 🟡 Medio | - | 2026-06-07 |

## 🔭 Wave 2 — Backlog candidato (idee, non pianificate)

| ID | Task | Status | Priorità | Rischio | Stima | Note |
|:--|:--|:--:|:--:|:--:|:--:|:--|
| FEAT-001 | **Internazionalizzazione reale IT/EN** (`flutter_localizations` + ARB) | 📅 Pianificato | 🟡 Media | 🟡 Medio | 6h | Oggi solo IT in `AppStrings` |
| TEST-001 | **Test unitari su `ScrutinyProvider`** (vote-log, vincitore, undo) | 📅 Pianificato | 🔴 Alta | 🟢 Basso | 4h | La logica critica è scoperta |
| FEAT-002 | **Redo** (oggi disabilitato nel modello a log sequenziale) | 📅 Pianificato | 🟢 Bassa | 🟡 Medio | 3h | Richiede redo-stack separato |
| PERF-001 | **Audit replay vote-log** su scrutini molto grandi | 📅 Pianificato | 🟢 Bassa | 🟢 Basso | 2h | `_recalculateState` rigioca tutto il log |

## Convenzioni ID

Prefissi progressivi per sezione: `FEAT-`, `FIX-`, `INFRA-`, `DOC-`, `TEST-`, `PERF-`.
Mappano ai prefissi dei conventional commit (vedi `docs/CONVENTIONAL_COMMITS.md`).

**Status:** 📅 Pianificato → 🏗️ In corso → ✅ Fatto
**Priorità:** 🔴 Alta · 🟡 Media · 🟢 Bassa
**Rischio:** 🔴 Alto · 🟡 Medio · 🟢 Basso
