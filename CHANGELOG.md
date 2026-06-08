# Changelog

Tutte le modifiche rilevanti a questo progetto sono documentate qui.
Il formato segue [Keep a Changelog](https://keepachangelog.com/it/1.1.0/) e il
progetto aderisce al [Versionamento Semantico](https://semver.org/lang/it/).

Le sezioni sono generate dai commit convenzionali (vedi
`docs/CONVENTIONAL_COMMITS.md`) tramite `scripts/bump_version.py`.

> Nota: le versioni `1.1.1` e `1.1.2` sono state generate da un workflow CI di
> auto-bump poi rimosso. Il loro contenuto reale è consolidato qui sotto in
> `[1.1.2]`; `1.1.1` è una versione "ghost" senza modifiche proprie.

## [Unreleased]

### 🚀 Nuove Funzionalità
- **Interfaccia multilingua Italiano/Inglese** (`flutter_localizations` + ARB),
  con selettore di lingua nelle impostazioni ("Sistema" per seguire il
  dispositivo); identità di schede/vincitore portata su `enum` per consentire la
  traduzione senza toccare la logica.
- Export dei risultati in **CSV** e **JSON** dal menu di condivisione (i dati
  erano già calcolati ma non raggiungibili dall'interfaccia).
- **Redo** ora funzionante: il pulsante di ripristino riapplica l'ultima azione
  annullata (prima era inerte).

### 🧪 Test
- Aggiunti test unitari su `ScrutinyProvider` e `Settings` (vote-log, vincitore,
  undo, clamp, export): 14 test, tutti verdi.

### ⚡ Prestazioni
- I voti aggiornano i conteggi in modo incrementale invece di rigiocare l'intero
  storico a ogni tap: da O(voti) a O(candidati) per operazione (il replay
  completo resta solo al caricamento e ai reset).

### 🛠️ Refactoring
- Centralizzate in `AppStrings` le stringhe UI residue di schermate e widget
  (menu export, impostazioni, proiettore, card, grafici): niente più testi
  hardcoded nell'interfaccia interattiva.
- Localizzate anche le superfici di export (report PDF, immagine social, testo di
  condivisione) tramite `ExportLabels` iniettato dai servizi.
- `AppStrings` ripulito: restano solo i semi-dati non localizzati (brand, nomi di
  default, etichette IT del vincitore per i getter retro-compatibili).

## [1.1.2] - 2026-06-07

### 🐞 Bug Fix
- Export PDF: la classifica e la tabella ora mostrano i candidati ordinati per
  voti (prima usavano l'ordine originale, marcando come leader la prima riga).
- Corretto un memory leak nel dialog di rinomina (controller non disposti).
- Le impostazioni ora validano il numero di votanti/candidati (clamp a valori
  minimi) impedendo conteggi negativi.
- Etichetta del vincitore resa accurata ("Vittoria matematica" per vantaggio
  incolmabile) e centralizzata, eliminando le diciture duplicate.

### ⚙️ Manutenzione
- Azzerati tutti gli avvisi dell'analyzer (`withValues`, rimozione di codice
  morto, lint minori): da 31 a 0 issue.
- Adottato l'AI Workflow Kit: flotta di subagent in `.claude/agents/` e script
  di versioning manuale (`scripts/bump_version.py`).
- Rimosso il workflow CI `auto-version.yml`: bumpava ad ogni push su `master`
  generando commit di versione "ghost". Il bump ora è manuale, alla release.

### 📝 Documentazione
- README come Master Brain Index e `docs/` (STRUCTURE, BOARD, PROJECT_GUIDE,
  CONVENTIONAL_COMMITS, DESIGN_SYSTEM).

## [1.1.0] - 2025

### 🚀 Nuove Funzionalità
- Tema scuro, statistiche avanzate, calcolo matematico del vincitore e
  miglioramenti al grafico storico.
- Modalità proiettore, export PDF e immagine social, import/export configurazione.

## [1.0.0]

### 🚀 Nuove Funzionalità
- Prima versione: tracciamento voti in tempo reale, grafici, calcolo vincitore,
  configurazione scrutinio ed esportazione CSV/JSON.

[Unreleased]: https://github.com/vantaggi/voto_tracker/compare/v1.1.2...HEAD
[1.1.2]: https://github.com/vantaggi/voto_tracker/releases/tag/v1.1.2
[1.1.0]: https://github.com/vantaggi/voto_tracker/releases/tag/v1.1.0
[1.0.0]: https://github.com/vantaggi/voto_tracker/releases/tag/v1.0.0
