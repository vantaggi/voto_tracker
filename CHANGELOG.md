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

### 🐞 Bug Fix
- **Home: i + e i − non si spostano più durante lo scrutinio.** Il riepilogo
  in cima cambiava altezza alla vittoria matematica e a scrutinio chiuso
  (comparivano "ELETTO" e il pulsante Condividi), e su schermi stretti la
  tendenza accanto alla percentuale andava a capo allungando la riga: in
  entrambi i casi i tasti si spostavano sotto il dito. Ora il riepilogo ha la
  stessa struttura e altezza in ogni stato (riga grande con chi è in testa o
  l'esito, riga piccola sotto, barra, numeri; "Condividi" prende il posto
  delle schede rimanenti) e percentuale e tendenza stanno su una riga sola.
  L'ordine dei candidati resta quello di inserimento. Test
  `home_stable_layout_test.dart` su uno scrutinio intero a 360 e 412 dp
  (FIX-015).
- "Manca 1 voto per la vittoria" al singolare (prima "Mancano 1 voti").
- **Riepilogo: pareggio in testa.** Con lo stesso numero di voti il riepilogo
  diceva "In testa" al primo inserito; ora dice "Pareggio in testa"
  (FIX-016, trovato provando FIX-015 sul telefono).

## [2.0.0] - 2026-11-12

### 🐞 Bug Fix
- **Home: i + non saltano più al primo voto.** Il riquadro "Nessuna scheda
  ancora" era più alto di quello del conteggio: al primo voto la lista saliva
  di circa 60 dp e i tocchi veloci successivi cadevano fuori dal +. Ora il
  riepilogo ha sempre la stessa forma ("0 / 100 schede" e "Tocca + per
  contare la prima scheda") e la riga "In testa" tiene il posto di due righe.
  Imposta e Lettura schede restano nel menu e nella barra in alto (FIX-014).

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
- **Esporta e importa l'archivio:** tutti gli scrutini in un file JSON da
  condividere (backup, cambio telefono); l'import aggiunge senza sovrascrivere.
- **Liste di candidati:** salva i candidati come lista e parti da lì per un
  nuovo scrutinio; le impostazioni si possono usare anche per i nuovi.
- **Archivio a due colonne sui tablet:** elenco a sinistra, esito e classifica
  dello scrutinio scelto a destra.
- I nomi predefiniti dei candidati seguono la lingua dell'app.
- Il PDF usa i colori dell'app (anche quelli dinamici) e mostra pareggio,
  ballottaggio e quorum non raggiunto con colori neutri.

### 🎨 Interfaccia & Design
- **Home ridisegnata:** tutti i + nella prima schermata (righe da 84 dp al
  posto delle card), riepilogo in cima con chi è in testa e quanti voti
  mancano, pillola "Annulla Rossi" sempre a portata, grafici Storico e
  Percentuali in una card apribile (il grafico "Corrente" non c'è più), titolo
  dello scrutinio nella barra in alto. Proiettore, impostazioni e "Azzera
  scrutinio" (ora con conferma) sono nel menu ⋮. Sul tablet lista, riepilogo
  e grafico stanno insieme.
- **Altre schermate ridisegnate:**
  - Impostazioni a pagina intera sul telefono (finestra sul tablet), in tre
    gruppi, con − e + per votanti e candidati; lingua e aspetto spostati in
    "Impostazioni dell'app" (dal menu dell'Archivio).
  - Archivio con "Aperto ora" in cima, barra dei voti in ogni riga, ricerca
    oltre 8 scrutini e un dettaglio con Riapri, Duplica ed Esporta; "Nuovo
    scrutinio" offre vuoto, copia dello scrutinio aperto o una lista.
  - Lettura schede con tessere che riempiono lo schermo, bianche e nulle in
    fondo e la pillola "Annulla Rossi".
  - Proiettore a schermo intero, con intestazione e barra, righe che si
    riordinano con un'animazione, bianche e nulle fuori classifica.
  - Foglio Condividi con Immagine e PDF in evidenza; "Modifica candidato"
    permette di scegliere il colore.
- **Condivisioni ridisegnate:**
  - Immagine 4:5 (1080 × 1350) con titolo, data, stato, esito, barra dei voti
    e una riga con barra per ogni candidato (fino a 8, poi "+N altri"); non
    esce più dai bordi quando c'è un vincitore.
  - PDF "Verbale dei risultati": titolo dello scrutinio, data in italiano,
    esito, numeri chiave, una sola tabella con barre e "Rispetto a prima",
    andamento a gradini con legenda, firme a scrutinio completo, più pagine
    se servono.
  - CSV che si apre bene in Excel italiano (punto e virgola, virgola
    decimale, accenti), senza righe di totale e protetto dalle formule.
  - JSON nel formato dell'Archivio: si reimporta da "Importa da file".
  - File con il nome dello scrutinio e la data.
- **Icona e splash nuovi:** icona "Stanghette" (quattro stanghette e la barra
  che le chiude) adaptive, con la versione per le icone a tema di Android 13+;
  splash chiaro o scuro come il telefono, con la schermata di avvio di Android
  12+. La build di debug ha la banda "DEBUG" e si chiama "Voto Tracker debug".
- **Grafici della Home:** "Andamento" con linee a gradini, chip con nome e voti
  per accendere e spegnere le linee e lettura a una scheda col dito;
  "Confronto" con barre e il risultato precedente al posto della ciambella.
- Percentuali con la virgola decimale in italiano.
- Palette dei candidati ridisegnata (HCT) per essere leggibile in light e dark;
  le schede nulle non sono più nere (invisibili nel tema scuro).
- Spaziature, raggi e testi solo da token e `textTheme`; aree di tocco ≥ 48 dp.
- Edge-to-edge con barre di sistema trasparenti; etichette per i lettori di
  schermo su voti, +/- e reset; nessun overflow con testo al 200%.

### 🐛 Correzioni
- Cambiare il numero di candidati (o bianche e nulle) nelle impostazioni non
  cancella più nomi, colori e risultati precedenti: si azzerano solo i voti,
  con un avviso e il pulsante "Salva e azzera". Anche "Azzera scrutinio" ora
  tiene nomi e colori.
- Nel grafico dell'andamento due candidati con lo stesso nome finivano su
  una sola linea: ora la storia è per posizione.

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
- I voti si salvano a gruppi (al massimo uno ogni 300 ms) e sempre quando
  l'app va in background: meno scritture a ogni tocco.
- Rimossi i getter `winner`/`winnerLabel` del provider: l'esito passa solo da
  `winnerStatus` e `winnerName`.
- Test d'integrazione in `integration_test/` da lanciare sul telefono.
- Esportazioni riunite in `ExportController`; widget grandi divisi in file più
  piccoli. Aggiunti test sul controller, sul menu export e golden della Home.

### 🎨 Interfaccia & Design
- Grafico "Corrente": asse Y con pochi tick leggibili (niente più interi
  duplicati) ed etichette dei candidati orizzontali con ellissi al posto dei
  nomi ruotati e illeggibili.

### 🐞 Bug Fix
- Modalità proiettore: sul telefono con testo grande le righe uscivano dallo
  schermo; ora sono leggibili anche da TalkBack (una riga per candidato).
- Chiudere il dialog "Modifica nome" (Salva, Annulla o tocco fuori) mandava
  l'app in errore (schermo rosso): i campi di testo venivano liberati mentre
  l'animazione di chiusura li usava ancora.
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
