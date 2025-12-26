# Voto Tracker

Un'applicazione Flutter avanzata per il monitoraggio e l'analisi di scrutini elettorali in tempo
reale.

## Caratteristiche Principali

Voto Tracker è evoluto da un semplice contatore a uno strumento di analisi completo, che offre:

- **Tracciamento Voti in Tempo Reale**: Aggiungi o rimuovi voti per ogni candidato con un'interfaccia semplice e reattiva.
- **Multilingua**: Supporto nativo per **Italiano** e **Inglese**, con selezione manuale o automatica.
- **Dashboard Avanzata**: Visualizza i dati attraverso tre diversi grafici interattivi:
  - **Grafico a Barre**: Per un'istantanea dei risultati correnti.
  - **Grafico a Torta**: Per analizzare le percentuali di voto.
  - **Grafico Storico Sincronizzato**: Per confrontare l'andamento dei candidati nel tempo.
- **Calcolo del Vincitore Intelligente**:
  - Determina il vincitore non appena raggiunge un **vantaggio matematicamente incolmabile**.
  - Dichiara il vincitore o un pareggio alla fine dello scrutinio.
- **Esperienza Utente Ottimizzata**:
  - **Schermo Sempre Attivo**: Impedisce il blocco dello schermo durante le operazioni di voto.
  - **Feedback Aptico**: Vibrazione alla pressione dei tasti per una conferma tattile.
  - **Prevenzione Errori**: Dialoghi di conferma per reset e azioni distruttive.
  - **Modifica Rapida**: Pressione prolungata sulle card per modificare rapidamente i nomi.
- **Pannelli di Analisi Dettagliata**:
  - **Statistiche**: Tieni traccia dell'affluenza e del numero di schede scrutinate.
  - **Confronto Diretto**: Isola e confronta i primi due candidati per analizzare il distacco.
- **Alta Configurabilità**:
  - Imposta il numero totale di votanti e candidati (da 2 a 8).
  - Includi o escludi le schede bianche e nulle.
  - **Personalizza i nomi** dei candidati e i colori dell'interfaccia.
- **Esportazione Dati**: Esporta i risultati finali in formati standard come **CSV** e **JSON**.
- **Tema Scuro Predefinito**: Un'interfaccia moderna e gradevole, con un tema chiaro alternativo.
- **Layout Responsivo**: Adatto a smartphone, tablet e desktop.

## Getting Started

Per avviare il progetto in locale, assicurati di avere un ambiente di sviluppo Flutter funzionante e
segui questi passaggi:

1. **Clona il repository del progetto:**

   ```bash
   git clone [https://github.com/vantaggi/voto_tracker.git](https://github.com/vantaggi/voto_tracker.git)
   ```

2. **Entra nella cartella del progetto:**

   ```bash
   cd voto_tracker
   ```

3. **Installa le dipendenze:**

   ```bash
   flutter pub get
   ```

4. **Avvia l'applicazione:**
   ```bash
   flutter run
   ```

## Utilizzo

L'interfaccia è divisa in due sezioni principali:

1. **Area Grafici (sinistra o in alto)**: Naviga tra le schede "Corrente", "Storico" e "Percentuali"
   per analizzare i dati da diverse prospettive.
2. **Area Controlli e Statistiche (destra o in basso)**:
   - Visualizza le statistiche generali e il confronto tra i primi due candidati.
   - Modifica i nomi dei candidati cliccando sull'icona a forma di matita.
   - Aggiungi e rimuovi i voti usando i pulsanti `+` e `-`.
   - Esporta i dati usando i pulsanti in fondo al pannello.

Usa il pulsante delle impostazioni (icona a forma di ingranaggio) nell'AppBar per configurare lo
scrutinio.

## Contributi

I contributi a questo progetto sono i benvenuti. Sentiti libero di aprire pull request per
correggere bug, aggiungere nuove funzionalità o proporre altri miglioramenti.

## Licenza

Questo progetto è rilasciato sotto la licenza MIT - vedi il file `LICENSE` per i dettagli.
