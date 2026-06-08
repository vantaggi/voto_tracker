# Voto Tracker — Master Brain Index

> **AVVISO PER LE IA:** Questo è il file di ingresso del repository. Leggi TUTTO
> prima di toccare qualsiasi cosa e segui la AI Interpretation Guide qui sotto.
> La documentazione è la prima fonte di verità, sia per gli umani che per le IA.

Un'applicazione **Flutter** avanzata per il monitoraggio e l'analisi di scrutini
elettorali in tempo reale. Funziona **interamente in locale** (nessun backend,
nessun account, nessuna rete): tutti i dati vivono su `shared_preferences`.

## 🤖 AI Interpretation Guide

Leggi questi file in QUEST'ORDINE prima di iniziare un task:

| Priorità | File | Cosa contiene |
|:--:|:--|:--|
| 1️⃣ | `README.md` (questo) | Visione globale + Regole Assolute |
| 2️⃣ | `docs/STRUCTURE.md` | Mappa COMPLETA dei file |
| 3️⃣ | `docs/BOARD.md` | Source of truth dei task attivi |
| 4️⃣ | `docs/PROJECT_GUIDE.md` | Architettura, algoritmi, decisioni |
| 5️⃣ | `docs/DESIGN_SYSTEM.md` | Token UI Material 3 + regole di stile |
| 6️⃣ | `CHANGELOG.md` | Storico modifiche per versione |

### Regole Assolute

- **Stack:** Flutter + Dart (SDK `>=3.2.2 <4.0.0`), Material 3. State management
  con **`provider`** (`ChangeNotifier`). Persistenza con **`shared_preferences`**.
  NON introdurre altri framework di state (Bloc, Riverpod…) o un backend senza
  prima registrare la decisione in `docs/PROJECT_GUIDE.md`.
- **App 100% locale e offline.** Nessuna chiamata di rete, nessun login, nessun
  tenant. Non aggiungere SDK di telemetria/analytics o segreti nel repo.
- **Stringhe localizzate (i18n).** I testi della UI vivono nei file ARB
  (`lib/l10n/app_it.arb`, `app_en.arb`) e si usano via `context.l10n.<chiave>`
  (`AppLocalizations`). MAI stringhe hardcoded nei widget; dopo aver modificato
  un ARB rigenera con `flutter gen-l10n`. `AppStrings` resta solo per i testi
  dei contesti **senza** `BuildContext` (provider, servizi di export) e come
  fallback dati. Lingue: **Italiano** (default) ed **Inglese**.
- **Token UI, mai valori hardcoded.** Colori dal `ColorScheme` del tema
  (`lib/theme/app_theme.dart`); dimensioni/padding/raggi da `AppDimensions`.
  Niente `Color(0x...)` o numeri magici sparsi nei widget.
- **Stato solo dal `ScrutinyProvider`.** La verità sui voti è il `_voteLog`
  (lista di indici candidato). I voti dei candidati sono **derivati** rieseguendo
  il log; non scriverli a mano fuori da `_recalculateState()`.
- **Non ordinare `_candidates` in place** (fa "saltare" la UI): usa il getter
  `sortedCandidates` o una copia ombra. Vedi `_calculateResults()`.
- **Errori mai ingoiati in silenzio:** `debugPrint("contesto: $e")` nel catch +,
  dove l'utente è coinvolto, feedback visibile (SnackBar).

## 🗺️ Mappa Rapida dei File Chiave

| File | Scopo |
|:--|:--|
| `lib/main.dart` | Entry point, `ChangeNotifierProvider`, `MaterialApp` |
| `lib/providers/scrutiny_provider.dart` | **Cuore logico**: voti, vote-log, vincitore, undo, export |
| `lib/models/candidate.dart` | Modello candidato + (de)serializzazione JSON |
| `lib/models/settings.dart` | Configurazione scrutinio (votanti, candidati, schede) |
| `lib/screens/home_page.dart` | Schermata principale (grafici + controlli) |
| `lib/screens/projector_mode_screen.dart` | Modalità proiettore a schermo intero |
| `lib/screens/settings_dialog.dart` | Dialog di configurazione |
| `lib/widgets/*` | Card candidato, sezioni grafici, card social |
| `lib/services/pdf_export_service.dart` | Report PDF |
| `lib/services/social_share_service.dart` | Immagine condivisibile |
| `lib/services/configuration_service.dart` | Import/export configurazione JSON |
| `lib/theme/app_theme.dart` | Tema Material 3 (seed indigo) |
| `lib/utils/app_constants.dart` | `AppStrings` + `AppDimensions` |

---

## Caratteristiche Principali

Voto Tracker è evoluto da un semplice contatore a uno strumento di analisi completo:

- **Tracciamento Voti in Tempo Reale**: aggiungi o rimuovi voti per ogni
  candidato con un'interfaccia semplice e reattiva.
- **Multilingua IT/EN**: interfaccia localizzata in Italiano e Inglese, con
  selettore di lingua nelle impostazioni (o "Sistema" per seguire il dispositivo).
- **Dashboard Avanzata**: grafico a barre (risultati correnti), grafico a torta
  (percentuali) e grafico storico sincronizzato (andamento nel tempo).
- **Calcolo del Vincitore Intelligente**: dichiara il vincitore appena raggiunge
  un **vantaggio matematicamente incolmabile**, o un pareggio a fine scrutinio.
- **Esperienza Ottimizzata**: schermo sempre attivo (`wakelock_plus`), feedback
  aptico, dialoghi di conferma sulle azioni distruttive, rinomina rapida.
- **Pannelli di Analisi**: affluenza, schede scrutinate, confronto diretto fra i
  primi due candidati, analisi dello swing (percentuale precedente).
- **Alta Configurabilità**: numero votanti e candidati (da 2 a 8), schede
  bianche/nulle, nomi e colori personalizzati.
- **Esportazione**: CSV, JSON, **report PDF** e **immagine social**.
- **Modalità Proiettore** per la visualizzazione su grande schermo.
- **Tema Material 3** chiaro/scuro che segue il sistema.
- **Layout Responsivo** per smartphone, tablet e desktop.

## Getting Started

Richiede un ambiente Flutter funzionante.

```bash
git clone https://github.com/vantaggi/voto_tracker.git
cd voto_tracker
flutter pub get
flutter run
```

Comandi utili durante lo sviluppo:

```bash
flutter analyze        # lint statico (deve passare pulito)
flutter test           # suite di test
flutter build apk      # build release Android
```

## Utilizzo

1. **Area Grafici**: naviga fra "Corrente", "Storico" e "Percentuali".
2. **Area Controlli**: statistiche, confronto fra i primi due candidati,
   rinomina (icona matita), voto con i pulsanti `+`/`−`, esportazione.

Usa l'icona impostazioni nell'AppBar per configurare lo scrutinio.

## Contributi

Apri pull request seguendo il flusso descritto in `docs/CONVENTIONAL_COMMITS.md`
e tieni aggiornato `docs/BOARD.md`. Merge a `master` sempre supervisionato.

## Licenza

Rilasciato sotto licenza MIT — vedi il file `LICENSE` per i dettagli.
