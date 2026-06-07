# Changelog

Tutte le modifiche rilevanti a questo progetto sono documentate qui.
Il formato segue [Keep a Changelog](https://keepachangelog.com/it/1.1.0/) e il
progetto aderisce al [Versionamento Semantico](https://semver.org/lang/it/).

Le sezioni sono generate dai commit convenzionali (vedi
`docs/CONVENTIONAL_COMMITS.md`) tramite `scripts/bump_version.py`.

## [Unreleased]

### 📝 Documentazione
- Adottato l'AI Workflow Kit: README come Master Brain Index, `docs/` (STRUCTURE,
  BOARD, PROJECT_GUIDE, CONVENTIONAL_COMMITS, DESIGN_SYSTEM), CHANGELOG.

### ⚙️ Manutenzione
- Flotta di subagent in `.claude/agents/` e auto-versioning CI
  (`scripts/bump_version.py` + `.github/workflows/auto-version.yml`).

## [1.1.0] - 2025

### 🚀 Nuove Funzionalità
- Tema scuro, statistiche avanzate, calcolo matematico del vincitore e
  miglioramenti al grafico storico.
- Modalità proiettore, export PDF e immagine social, import/export configurazione.

## [1.0.0]

### 🚀 Nuove Funzionalità
- Prima versione: tracciamento voti in tempo reale, grafici, calcolo vincitore,
  configurazione scrutinio ed esportazione CSV/JSON.

[Unreleased]: https://github.com/vantaggi/voto_tracker/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/vantaggi/voto_tracker/releases/tag/v1.1.0
[1.0.0]: https://github.com/vantaggi/voto_tracker/releases/tag/v1.0.0
