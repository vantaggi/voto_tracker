# Voto Tracker Pro

Un'applicazione Flutter avanzata per il monitoraggio e l'analisi di scrutini elettorali in tempo
reale.

![Screenshot dell'App](https://i.imgur.com/your-screenshot-url.png) ## Caratteristiche Principali

Voto Tracker Pro è evoluto da un semplice contatore a uno strumento di analisi completo, che offre:

- **Tracciamento Voti in Tempo Reale**: Aggiungi o rimuovi voti per ogni candidato con
  un'interfaccia semplice e reattiva.
- **Dashboard Avanzata**: Visualizza i dati attraverso tre diversi grafici interattivi:
    - **Grafico a Barre**: Per un'istantanea dei risultati correnti.
    - **Grafico a Torta**: Per analizzare le percentuali di voto.
    - **Grafico Storico Sincronizzato**: Per confrontare l'andamento dei candidati nel tempo, con
      una linea del tempo unificata che gestisce correttamente le correzioni.
- **Calcolo del Vincitore Intelligente**:
    - Determina il vincitore non appena raggiunge un **vantaggio matematicamente incolmabile**.
    - Dichiara il vincitore o un pareggio alla fine dello scrutinio.
- **Pannelli di Analisi Dettagliata**:
    - **Statistiche**: Tieni traccia dell'affluenza e del numero di schede scrutinate.
    - **Confronto Diretto**: Isola e confronta i primi due candidati per analizzare il distacco.
- **Alta Configurabilità**:
    - Imposta il numero totale di votanti.
    - Scegli il numero di candidati (da 2 a 8).
    - Includi o escludi le schede bianche e nulle.
    - **Personalizza i nomi** dei candidati.
- **Esportazione Dati**: Esporta i risultati finali in formati standard come **CSV** e **JSON**.
- **Tema Scuro Predefinito**: Un'interfaccia moderna e gradevole, con un tema chiaro alternativo.
- **Layout Responsivo**: L'interfaccia si adatta elegantemente a schermi di diverse dimensioni (
  mobile, tablet e desktop).

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