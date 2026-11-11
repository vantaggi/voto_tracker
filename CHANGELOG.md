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
- **Archivio scrutini:** più scrutini salvati, con nuovo, duplica come modello
  (stessi candidati, nessuna scheda), riapri, rinomina ed elimina con conferma.
- **Navigazione Scrutinio / Archivio:** barra in basso sul telefono, barra
  laterale su tablet e desktop.
- **Regole di vittoria:** maggioranza relativa (come prima) o assoluta, e quorum
  di affluenza; nuovi esiti "Ballottaggio" e "Quorum non raggiunto".
- **Lettura schede:** una scheda alla volta con pulsanti grandi, "Scheda N di M",
  annulla sempre visibile e protezione dai doppi tocchi.
- **Colore dinamico (Material You):** su Android 12+ l'app prende i colori dello
  sfondo; si può disattivare in Impostazioni → Aspetto.

### 🎨 Interfaccia & Design
- Palette dei candidati ridisegnata (HCT) per essere leggibile in light e dark;
  le schede nulle non sono più nere (invisibili nel tema scuro).
- Spaziature, raggi e testi solo da token e `textTheme`; aree di tocco ≥ 48 dp.
- Edge-to-edge con barre di sistema trasparenti; etichette per i lettori di
  schermo su voti, +/- e reset; nessun overflow con testo al 200%.

### 🛠️ Refactoring
- Logica dello scrutinio in `ScrutinyEngine` (puro, testato a parte) e
  persistenza in `ScrutinyRepository` con schema v2. I dati della 1.x vengono
  migrati al primo avvio; le vecchie chiavi restano come copia di sicurezza.
- Migrazione a Flutter 3.50 e ai package `material_ui` / `cupertino_ui` (Material
  e Cupertino sono usciti dal framework in Flutter 3.47). Corretto un problema
  che con il nuovo Material faceva ignorare la lingua italiana.
- Dipendenze aggiornate: `flutter_lints` 6, `share_plus` 13, `file_picker` 13,
  `wakelock_plus` 1.8, `fl_chart` 1.3 e minori.
- Lo schermo resta acceso solo mentre Home o proiettore sono aperti (prima il
  wakelock veniva riattivato a ogni rebuild e mai spento).
- Esportazioni riunite in `ExportController`; widget grandi divisi in file più
  piccoli. Aggiunti test sul controller, sul menu export e golden della Home.

### 🎨 Interfaccia & Design
- Grafico "Corrente": asse Y con pochi tick leggibili (niente più interi
  duplicati) ed etichette dei candidati orizzontali con ellissi al posto dei
  nomi ruotati e illeggibili.

### 🐞 Bug Fix
- "Mancano N voti per la vittoria" non considera più bianche e nulle come
  leader; a parità di voti la classifica non cambia più ordine a caso.
- Corretto l'overflow della barra dei controlli quando la label del reset è più
  lunga (es. in italiano "Tieni premuto per resettare"): il bottone ora si
  comprime con ellissi. Aggiunto `navigatorKey` stabile e test di interazione
  (apri/chiudi e cambio lingua delle impostazioni) per prevenire regressioni.

## [1.2.0] - 2026-06-09

### 🚀 Nuove Funzionalità
- **Interfaccia multilingua Italiano/Inglese** (`flutter_localizations` + ARB),
  con selettore di lingua nelle impostazioni ("Sistema" per seguire il
  dispositivo); identità di schede/vincitore portata su `enum` per consentire la
  traduzione senza toccare la logica. Localizzate anche le esportazioni (PDF,
  immagine social, testo di condivisione).
- Export dei risultati in **CSV** e **JSON** dal menu di condivisione (i dati
  erano già calcolati ma non raggiungibili dall'interfaccia).
- **Redo** ora funzionante: il pulsante di ripristino riapplica l'ultima azione
  annullata (prima era inerte).

### ⚡ Prestazioni
- I voti aggiornano i conteggi in modo incrementale invece di rigiocare l'intero
  storico a ogni tap: da O(voti) a O(candidati) per operazione (il replay
  completo resta solo al caricamento e ai reset).

### 🛠️ Refactoring
- Identità di schede e vincitore portata su `enum` (`CandidateType`,
  `WinnerStatus`), rimuovendo i confronti fragili su stringhe.
- Stringhe della UI e delle esportazioni centralizzate (l10n / `AppStrings`
  ridotto ai soli semi-dati non localizzati).

### 🧪 Test
- Aggiunta copertura su `ScrutinyProvider` e `Settings` (vote-log, vincitore,
  undo/redo, tipi, clamp, export) e sulla localizzazione: 24 test, tutti verdi.

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

[Unreleased]: https://github.com/vantaggi/voto_tracker/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/vantaggi/voto_tracker/releases/tag/v1.2.0
[1.1.2]: https://github.com/vantaggi/voto_tracker/releases/tag/v1.1.2
[1.1.0]: https://github.com/vantaggi/voto_tracker/releases/tag/v1.1.0
[1.0.0]: https://github.com/vantaggi/voto_tracker/releases/tag/v1.0.0
