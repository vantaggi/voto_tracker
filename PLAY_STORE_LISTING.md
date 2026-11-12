# Voto Tracker - Play Store Listing Info

## Titolo (Max 30 caratteri)

Voto Tracker - Scrutini Live

## Descrizione Breve (Max 80 caratteri)

Monitora scrutini elettorali in tempo reale con grafici, statistiche e proiezioni.

## Descrizione Completa (Max 4000 caratteri)

**Voto Tracker** ti aiuta a contare le schede di uno scrutinio senza errori: rappresentanti di classe, assemblee, consigli, associazioni, seggi. Tocchi il + del candidato, l'app tiene il conto, calcola chi è in testa e ti dice quando il risultato è deciso.

**Conta le schede**
- Tutti i candidati in una schermata, il + resta fermo sotto il dito.
- Lettura schede: una scheda alla volta con pulsanti grandi e protezione dai doppi tocchi.
- Annulla e ripeti sempre a portata, schede bianche e nulle.

**Sai subito com'è andata**
- Maggioranza relativa o assoluta, quorum di affluenza facoltativo.
- Esiti chiari: eletto, pareggio, ballottaggio, quorum non raggiunto.
- "Mancano N voti per la vittoria" mentre conti.

**Grafici e proiettore**
- Andamento a gradini scheda per scheda e confronto con il risultato precedente.
- Modalità proiettore a schermo intero per mostrare lo spoglio in sala.

**Archivio e liste**
- Tieni tutti gli scrutini: riapri, duplica, rinomina.
- Liste di candidati da riusare.
- Esporta e importa l'archivio per un backup o per cambiare telefono.

**Condividi i risultati**
- Immagine pronta per WhatsApp e social.
- PDF "Verbale dei risultati" con le righe per le firme.
- CSV per Excel e JSON.

**Fatta per il tuo telefono**
- Colori dinamici di Android, tema chiaro e scuro, icona a tema.
- Italiano e inglese, TalkBack e testo grande.

**Privacy totale**
Voto Tracker funziona offline. I dati restano sul tuo dispositivo: nessun account, nessun cloud, nessuna pubblicità.

## Novità della versione 2.0.0 (Max 500 caratteri)

Nuova versione, ridisegnata da capo:
• Archivio con più scrutini e liste di candidati
• Maggioranza assoluta, quorum e ballottaggio
• Lettura schede una alla volta
• Nuovi grafici e modalità proiettore
• Immagine, PDF verbale, CSV per Excel
• Backup dell'archivio in un file
• Nuova icona, colori dinamici e tema scuro

## Parole Chiave (Tags)

elezioni, scrutinio, voti, politica, rappresentante di lista, conteggio, statistiche, sondaggi, seggio

## Requisiti Grafici

- **Icona App**: 512px x 512px (PNG, 32-bit): `assets/icon/play_store_512.png`, generata da `scripts/make_icons.py` (icona "Stanghette").
- **Immagine in Evidenza (Feature Graphic)**: 1024px x 500px (JPG o PNG, nessun canale alpha). "Voto Tracker" al centro, sfondo scuro/tech.
- **Screenshot Telefono**: Rapporto 16:9 o 9:16 (Min 2 lati > 320px, Max < 3840px). Consigliati almeno 4 screenshot della 2.0: Home durante lo scrutinio, esito "Eletto", Archivio, Condividi (immagine o PDF), più uno in tema scuro.

## Note per la Pubblicazione

1. La versione è in `pubspec.yaml` (`2.0.0+6`: il numero dopo `+` è il `versionCode`, deve crescere a ogni caricamento). Build: `flutter build appbundle --release` con `android/key.properties`.
2. Generare il Keystore di upload se non presente.
3. Compilare la scheda "Sicurezza dei dati" nella Console Google Play indicando che l'app non raccoglie dati.
