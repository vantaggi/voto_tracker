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

## [1.1.1] - 2026-06-07

### 🚀 Nuove Funzionalità
- Implement candidate card UI with vote controls, percentage swing, and scrutiny state management.
- Implement core vote tracking functionality including candidate management, real-time scrutiny, data visualization, and export/sharing capabilities.
- add charts section with current results bar chart and history line chart
- introduce `ScrutinyProvider` to manage candidate votes, settings, and a vote log with undo capability.
- add home page with export/projector modes and a settings dialog for scrutiny configuration.
- add ScrutinyProvider for managing vote tracking, candidate data, settings, and persistent vote history.
- Add responsive home page, projector mode, social sharing, and PDF export functionalities.
- Add social media sharing for election results with a dedicated card and service, and introduce a candidates section.
- Introduce social sharing, PDF export, and projector mode with a new home page layout.
- Implement core voting tracker features including projector mode, candidate management, settings, and social sharing services.
- implement PDF export service for vote tracking reports with charts and statistics
- add initial Android build configuration and application manifest files.
- Implement initial scrutiny tracking UI including settings, candidate display, and vote statistics.
- Implement core candidate voting UI and data management.
- Implement core voting scrutiny logic, UI components, data models, and persistence.

### 🐞 Bug Fix
- change colorValue alignment

### 🛠️ Refactoring
- Introduce AppConstants and integrate into UI

### 📝 Documentazione
- adotta AI Workflow Kit (Brain + Fleet + Automation)
- Add privacy policy and Play Store listing information, and update README with enhanced features and details.

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
