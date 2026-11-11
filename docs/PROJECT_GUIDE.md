# 🧭 Voto Tracker — Project Guide

Architettura, algoritmi e decisioni tecniche. Responsabilità unica: **come e
perché** il codice funziona così. Lo stato dei task vive nel BOARD, non qui.

## 1. Architettura ad alto livello

App Flutter a singola sorgente di stato, **interamente locale e offline**.

```
   UI         AppShell → HomePage · ArchivePage · BallotReadingScreen ·
   (screens)  ProjectorMode · SettingsDialog          (+ widgets/*)
                             │ context.watch / read
              ┌──────────────▼──────────────┐
   Stato      │      ScrutinyProvider       │  ChangeNotifier: _voteLog,
              │                             │  _candidates, _settings, archivio
              └───────┬──────────────┬──────┘
                      │              │
              ┌───────▼──────┐ ┌─────▼──────────────┐
   Dominio    │ScrutinyEngine│ │ ScrutinyRepository │  Dati
   (puro)     │ tally, rank, │ │ shared_preferences │  scrutinies,
              │ vincitore    │ │ schema v2          │  current_scrutiny_id
              └──────────────┘ └────────────────────┘

   Servizi (stateless): ExportController → PdfExportService ·
   SocialShareService · DataExportService · ConfigurationService.
```

- **State management:** `provider` (`ChangeNotifierProvider` in `main.dart`).
  La UI legge con `context.watch<ScrutinyProvider>()` e agisce con `read`.
- **Persistenza:** `ScrutinyRepository` su `shared_preferences` (ADR-001).
  Il provider salva l'archivio dopo ogni mutazione con `_persistState()`.
- **Logica:** `ScrutinyEngine` (funzioni statiche pure). Il provider gli passa
  tipi, voti, schede attese, regola e quorum e ne copia il risultato.
- **Niente rete / niente account.** Tutta la portabilità dei dati passa da
  import/export file (CSV, JSON, PDF, PNG).

## 2. Modello dati e fonte di verità

Il `_voteLog` (`List<int>`, ogni elemento = indice di un candidato) è la **fonte
di verità** dei voti. I conteggi `Candidate.votes` sono **derivati**: vengono
azzerati e ricostruiti rieseguendo il log in `_recalculateState()`.

**Identità via enum, mai stringhe.** Schede bianche/nulle si riconoscono da
`Candidate.type` (`CandidateType.normal/blank/spoiled`), non dal nome; lo stato
del vincitore è `WinnerStatus` (`none/mathematical/elected/tie/noMajority/
noQuorum`), non il
confronto con una stringa. Questo rende i nomi liberamente localizzabili/
rinominabili senza rompere la logica (prerequisito per la i18n, FEAT-001).

Implicazioni da rispettare:

- Non scrivere `candidate.votes` direttamente fuori dal replay del log.
- Aggiungere un voto = `_voteLog.add(index)`; togliere un voto = rimuovere
  l'**ultima** occorrenza di quell'indice (`lastIndexOf`).
- L'**undo** sposta l'ultima azione (`_voteLog.removeLast()`) su un `_redoStack`
  in memoria; il **redo** la riapplica. Ogni nuova azione svuota il redo-stack
  (invalidazione standard). Il redo-stack è transiente: non persiste fra riavvii.
- Il **rename** non riscrive il log (la storia è ancorata all'indice), quindi è
  un'operazione sicura ed economica.

`Candidate.rank` e `previousPercentage` sono proprietà di visualizzazione
(swing analysis); `rank` è transiente e ricalcolato a ogni `_calculateResults()`.

## 3. Algoritmi chiave (in `ScrutinyEngine`, `lib/domain/`)

### 3.1 Classifica e vincitore — `evaluate()`
1. `ranking()`: indici ordinati per voti, a parità l'ordine originale
   (stabile). `_candidates` non viene mai riordinato: la UI non salta.
2. `totalAssigned` e `remaining = totalVoters − assegnati`.
3. Solo i candidati `normal` possono vincere; bianche e nulle contano nel totale.
4. **Maggioranza relativa** (default): vittoria matematica se
   `voti1° − voti2° > remaining`; a scrutinio chiuso eletto il primo, o `tie`.
5. **Maggioranza assoluta:** soglia `floor(totalVoters/2) + 1` (bianche e nulle
   comprese). Raggiunta = `mathematical`/`elected`; a scrutinio chiuso senza
   soglia = `noMajority` (ballottaggio), anche prima se nessuno può più
   arrivarci.
6. **Quorum:** `Settings.quorumReached` (schede attese ≥ aventi diritto × %).
   Se manca, ogni esito diventa `noQuorum`.

### 3.2 Magic number — `votesToWin`
Relativa: `(voti2° + remaining − voti1°) / 2` per difetto + 1, ≥ 0, calcolato fra
candidati reali. Assoluta o un solo candidato: `soglia − voti1°`.

### 3.3 Grafico storico — `history()`
Una lista di conteggi per indice dopo ogni scheda valida (punto 0 = tutto a
zero). Il provider la converte in `historyPoints` (`passo → {nome: voti}`) per
`HistoryChart` e il PDF.

### 3.4 Archivio — `ScrutinyRepository`
Chiavi v2: `schema_version` = 2, `scrutinies` (lista JSON di `Scrutiny`),
`current_scrutiny_id`. Al primo avvio dopo l'aggiornamento i dati v1
(`settings`, `candidates`, `vote_log`) diventano il primo scrutinio
dell'archivio; le chiavi v1 non vengono cancellate. Dati senza registro (1.1)
diventano un registro equivalente. Un archivio illeggibile viene copiato in
`scrutinies_corrupt_backup`, mai sovrascritto in silenzio.

## 4. Servizi di output

| Servizio | Tecnica | Output |
|:--|:--|:--|
| `PdfExportService` | package `pdf` + `printing`, layout a pagina singola, font Roboto | PDF condiviso |
| `SocialShareService` | `screenshot` cattura `SocialResultsCard` forzando il dark theme | PNG condiviso |
| `ConfigurationService` | `file_picker` + `share_plus`, JSON candidati con voti azzerati | template di configurazione |
| `DataExportService` | scrive su file temporaneo e condivide (`share_plus`) | file CSV / JSON dei risultati |
| `ScrutinyProvider.exportToCsv/Json` | serializzazione diretta (consumata da `DataExportService`) | stringa CSV / mappa JSON |

## 5. Decisioni & vincoli (ADR leggeri)

- **`provider` invece di Bloc/Riverpod:** dominio piccolo, un solo aggregato di
  stato. Cambiarlo richiede una nota qui prima dell'implementazione.
- **Vote-log invece di snapshot:** undo/redo e grafico storico derivano da
  un'unica struttura. Le mutazioni di voto (increment/decrement/undo/redo)
  aggiornano i conteggi in modo **incrementale** (O(candidati)); il replay
  completo del log (`_recalculateState`, O(voti)) serve solo al caricamento da
  `shared_preferences` e ai reset strutturali (PERF-001). `historyPoints` resta
  O(voti) ma è ricostruito solo quando il grafico storico è visibile.
- **App locale, niente backend:** nessun segreto da iniettare, nessuna
  cache-busting CDN, nessun deploy server. La "release" è una build store
  (`release-android` agent). Per questo gli strati Supabase/Vercel/cache-bust
  del workflow kit originale **non si applicano** qui.
- **ADR-001 — `shared_preferences` invece di `drift`/SQLite (2026-11-11):**
  pochi dati (decine di scrutini, registri di migliaia di interi), nessun
  codegen, nessuna libreria nativa nuova. L'archivio è un'unica stringa JSON
  riscritta a ogni voto. Da rivedere se servono ricerche o migliaia di scrutini:
  il repository isola il resto dell'app dal cambio.
- **Stringhe localizzate (i18n):** la UI usa `AppLocalizations` (ARB IT/EN) via
  `context.l10n`; `AppStrings` resta per i contesti senza `BuildContext` e i
  fallback dati (vedi §6).

## 6. Internazionalizzazione (i18n)

- **Stack:** `flutter_localizations` + `gen-l10n`. Sorgenti in `lib/l10n/*.arb`
  (template `app_en.arb`), config in `l10n.yaml` (`synthetic-package: false`,
  output in `lib/l10n/`). Dopo aver toccato un ARB: `flutter gen-l10n`.
- **Accesso:** `context.l10n.<chiave>` (estensione in `l10n/l10n_ext.dart`). Lo
  stesso file espone `localizedCandidateName()` (nome reale o etichetta tecnica
  localizzata) e `localizedWinnerLabel(WinnerStatus)`.
- **Lingua:** `LocaleProvider` (persistito su `shared_preferences`, `null` =
  sistema) wired in `main.dart` su `MaterialApp.locale`; selettore nelle
  impostazioni. Il cambio lingua ricostruisce l'app via `Consumer<LocaleProvider>`.
- **Confine localizzazione / dati:** si localizza solo a **display time**.
  L'identità resta su `enum` (`CandidateType`, `WinnerStatus`); i nomi dei
  candidati reali sono **dati editabili** (non tradotti), mentre schede
  bianche/nulle e label vincitore si traducono dall'enum.
- **Export senza contesto:** PDF, immagine social e testo di condivisione girano
  fuori dall'albero dei widget. Le loro stringhe sono risolte in `home_page` con
  `ExportLabels.of(context.l10n)` e **iniettate** nei servizi
  (`PdfExportService`, `SocialShareService`/`SocialResultsCard`). `AppStrings`
  resta solo per i semi-dati non localizzati (brand, nomi di default, etichette
  IT dei getter retro-compatibili `winner`/`winnerLabel`).
