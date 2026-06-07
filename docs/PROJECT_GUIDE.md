# 🧭 Voto Tracker — Project Guide

Architettura, algoritmi e decisioni tecniche. Responsabilità unica: **come e
perché** il codice funziona così. Lo stato dei task vive nel BOARD, non qui.

## 1. Architettura ad alto livello

App Flutter a singola sorgente di stato, **interamente locale e offline**.

```
              ┌─────────────────────────────┐
   UI         │ HomePage / ProjectorMode /  │  widgets/* (CandidateCard,
   (widgets)  │ SettingsDialog              │  ChartsSection, ...)
              └──────────────┬──────────────┘
                             │ context.watch / read
              ┌──────────────▼──────────────┐
   Stato      │      ScrutinyProvider       │  (ChangeNotifier)
              │  _voteLog · _candidates ·   │
              │  _settings · winner         │
              └──────────────┬──────────────┘
                             │ jsonEncode/Decode
              ┌──────────────▼──────────────┐
   Persist.   │     shared_preferences      │  keys: candidates, settings, vote_log
              └─────────────────────────────┘

   Servizi (stateless, statici): PdfExportService · SocialShareService ·
   ConfigurationService  → consumano lo stato corrente del provider.
```

- **State management:** `provider` (`ChangeNotifierProvider` in `main.dart`).
  La UI legge con `context.watch<ScrutinyProvider>()` e agisce con `read`.
- **Persistenza:** `shared_preferences`, JSON serializzato. Salvataggio dopo ogni
  mutazione tramite `_persistState()`.
- **Niente rete / niente account.** Tutta la portabilità dei dati passa da
  import/export file (CSV, JSON, PDF, PNG).

## 2. Modello dati e fonte di verità

Il `_voteLog` (`List<int>`, ogni elemento = indice di un candidato) è la **fonte
di verità** dei voti. I conteggi `Candidate.votes` sono **derivati**: vengono
azzerati e ricostruiti rieseguendo il log in `_recalculateState()`.

Implicazioni da rispettare:

- Non scrivere `candidate.votes` direttamente fuori dal replay del log.
- Aggiungere un voto = `_voteLog.add(index)`; togliere un voto = rimuovere
  l'**ultima** occorrenza di quell'indice (`lastIndexOf`).
- L'**undo** rimuove l'ultima azione assoluta (`_voteLog.removeLast()`); il
  **redo** è disabilitato (modello a log distruttivo, vedi FEAT-002 nel BOARD).
- Il **rename** non riscrive il log (la storia è ancorata all'indice), quindi è
  un'operazione sicura ed economica.

`Candidate.rank` e `previousPercentage` sono proprietà di visualizzazione
(swing analysis); `rank` è transiente e ricalcolato a ogni `_calculateResults()`.

## 3. Algoritmi chiave (in `ScrutinyProvider`)

### 3.1 Calcolo del vincitore — `_calculateResults()`
1. Crea una lista **ombra** ordinata per voti (mai ordinare `_candidates` in
   place: farebbe saltare la UI). Assegna `rank`.
2. Calcola `totalVotesAssigned` e `remainingVotes = totalVoters − assegnati`.
3. Esclude schede bianche/nulle dai candidati "validi".
4. **Vittoria matematica anticipata:** se `voteGap(1°, 2°) > remainingVotes`, il
   primo è già vincitore (vantaggio incolmabile).
5. **Fine scrutinio** (`remainingVotes <= 0`): vincitore = primo, oppure
   `AppStrings.tie` se i primi due pareggiano con voti > 0.

### 3.2 Magic number — `votesUntilMajority`
Stima i voti che il leader deve ancora prendere per chiudere i giochi contro il
secondo: `(voti2° + remaining − voti1°) / 2`, arrotondato per difetto + 1,
clampato a ≥ 0. Con un solo candidato valido usa la soglia di maggioranza
assoluta (`totalVoters/2 + 1`).

### 3.3 Grafico storico — `historyPoints`
Ricostruisce, rieseguendo il log, una mappa `passo → {nome: voti}`. Il punto 0 è
lo stato iniziale; ogni voto aggiunge uno snapshot. Consumato da
`ChartsSection` (tab Storico) e dal PDF.

## 4. Servizi di output

| Servizio | Tecnica | Output |
|:--|:--|:--|
| `PdfExportService` | package `pdf` + `printing`, layout a pagina singola, font Roboto | PDF condiviso |
| `SocialShareService` | `screenshot` cattura `SocialResultsCard` forzando il dark theme | PNG condiviso |
| `ConfigurationService` | `file_picker` + `share_plus`, JSON candidati con voti azzerati | template di configurazione |
| `ScrutinyProvider.exportToCsv/Json` | serializzazione diretta | stringa CSV / mappa JSON |

## 5. Decisioni & vincoli (ADR leggeri)

- **`provider` invece di Bloc/Riverpod:** dominio piccolo, un solo aggregato di
  stato. Cambiarlo richiede una nota qui prima dell'implementazione.
- **Vote-log invece di snapshot:** undo e grafico storico derivano gratis da
  un'unica struttura; il costo è un replay O(n) a ogni mutazione (accettabile
  alle dimensioni reali di uno scrutinio — vedi PERF-001).
- **App locale, niente backend:** nessun segreto da iniettare, nessuna
  cache-busting CDN, nessun deploy server. La "release" è una build store
  (`release-android` agent). Per questo gli strati Supabase/Vercel/cache-bust
  del workflow kit originale **non si applicano** qui.
- **Stringhe in `AppStrings`:** abilita una futura i18n reale (FEAT-001) e tiene
  i widget puliti.
