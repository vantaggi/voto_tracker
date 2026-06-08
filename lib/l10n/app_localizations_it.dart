// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Voto Tracker';

  @override
  String get settingsTooltip => 'Impostazioni';

  @override
  String get exportShareTooltip => 'Esporta / Condividi';

  @override
  String get projectorMode => 'Modalità Proiettore';

  @override
  String get shareImageTitle => 'Condividi immagine social';

  @override
  String get shareImageSubtitle => 'Ottimizzata per Instagram/WhatsApp';

  @override
  String get exportPdfTitle => 'Esporta Report PDF';

  @override
  String get exportPdfSubtitle => 'Documento ufficiale con grafici';

  @override
  String get exportCsvTitle => 'Esporta CSV';

  @override
  String get exportCsvSubtitle => 'Tabella per fogli di calcolo';

  @override
  String get exportJsonTitle => 'Esporta JSON';

  @override
  String get exportJsonSubtitle => 'Dati strutturati completi';

  @override
  String get exportError => 'Errore durante l\'esportazione';

  @override
  String get scrutinisedVotes => 'Voti Scrutinati';

  @override
  String get remaining => 'Rimanenti';

  @override
  String get votesTotal => 'VOTI TOTALI';

  @override
  String get waitingForData => 'In attesa di dati...';

  @override
  String votesToWin(int count) {
    return 'Mancano $count voti per la vittoria';
  }

  @override
  String get votes => 'voti';

  @override
  String get votesShort => 'Voti';

  @override
  String get winnerElected => 'ELETTO';

  @override
  String get winnerMathematical => 'VITTORIA MATEMATICA';

  @override
  String get finalResult => 'RISULTATO FINALE';

  @override
  String get tie => 'Pareggio';

  @override
  String get winnerFallback => 'VINCITORE';

  @override
  String get blankVotes => 'Schede Bianche';

  @override
  String get spoiledVotes => 'Schede Nulle';

  @override
  String get editName => 'Modifica Nome';

  @override
  String get candidateName => 'Nome Candidato';

  @override
  String get previousResultLabel => 'Risultato Precedente (%)';

  @override
  String get previousResultHint => 'Es. 25.5';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get current => 'Corrente';

  @override
  String get history => 'Storico';

  @override
  String get percentages => 'Percentuali';

  @override
  String get noDataAvailable => 'Nessun dato disponibile';

  @override
  String get noHistoryAvailable => 'Nessuno storico disponibile';

  @override
  String get noVotesRecorded => 'Nessun voto registrato';

  @override
  String get undoTooltip => 'Annulla ultima azione';

  @override
  String get redoTooltip => 'Ripristina azione';

  @override
  String get resetButton => 'TIENI PREMUTO PER RESETTARE';

  @override
  String get scrutinyConfiguration => 'Configurazione Scrutinio';

  @override
  String get totalVotersNumber => 'Numero Totale Votanti';

  @override
  String get votersHint => 'Es. 100';

  @override
  String get participantsCount => 'Numero Candidati';

  @override
  String get votingOptions => 'Opzioni di Voto';

  @override
  String get dataManagement => 'Gestione Dati';

  @override
  String get exportLabel => 'Esporta';

  @override
  String get importLabel => 'Importa';

  @override
  String get configLoaded => 'Configurazione caricata con successo';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageEnglish => 'English';
}
