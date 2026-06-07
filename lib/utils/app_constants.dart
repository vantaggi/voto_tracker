class AppStrings {
  static const String appTitle = 'Voto Tracker';
  static const String appTitlePro = 'Voto Tracker Pro'; // Updated title
  static const String candidatePrefix = 'Candidato';
  static const String blankVotes = 'Schede Bianche';
  static const String nullVotes = 'Schede Nulle';
  static const String winner = 'VINCITORE';
  static const String tie = 'Pareggio';
  static const String winnerElected = 'ELETTO';
  static const String winnerMathematical = 'VITTORIA MATEMATICA';
  static const String finalResult = 'RISULTATO FINALE';
  static const String totalVoters = 'Votanti';
  static const String resetButtonTooltip = 'Reset voti';
  static const String settingsButtonTooltip = 'Impostazioni';
  static const String noDataAvailable = 'Nessun dato disponibile';
  static const String noHistoryAvailable = 'Nessuno storico disponibile';
  static const String noVotesRecorded = 'Nessun voto registrato';
  static const String editName = 'Modifica Nome';
  static const String candidateName = 'Nome Candidato';
  static const String cancel = 'Annulla';
  static const String save = 'Salva';
  static const String confirmReset = 'Conferma Reset';
  static const String resetConfirmation =
      'Sei sicuro di voler azzerare tutti i voti?';
  static const String reset = 'Reset';
  static const String scrutinyConfiguration = 'Configurazione Scrutinio';
  static const String totalVotersNumber = 'Numero Totale Votanti';
  static const String participantsCount = 'Numero Candidati';
  static const String cardOptions = 'Opzioni Schede';
  static const String exportData = 'Esportazione Dati';
  static const String exportTo = 'Esporta in';
  static const String exportCsvTitle = 'Esporta CSV';
  static const String exportCsvSubtitle = 'Tabella per fogli di calcolo';
  static const String exportJsonTitle = 'Esporta JSON';
  static const String exportJsonSubtitle = 'Dati strutturati completi';
  static const String exportError = 'Errore durante l\'esportazione';
  static const String close = 'Chiudi';
  static const String copy = 'Copia';
  static const String dataCopied = 'Dati copiati negli appunti!';
  static const String resetDone = 'Reset effettuato!';
  static const String comparisonNotAvailable =
      'Confronto non disponibile (meno di 2 candidati)';
  static const String lead = 'In Testa';
  static const String advantage = 'Vantaggio';
  static const String votes = 'voti';
  static const String current = 'Corrente';
  static const String history = 'Storico';
  static const String percentages = 'Percentuali';
  static const String scrutinisedVotes = 'Voti Scrutinati';
  static const String votesShort = 'Voti';


  static const String undoTooltip = 'Annulla ultima azione';
  static const String redoTooltip = 'Ripristina azione';
  static const String resetButton = 'TIENI PREMUTO PER RESETTARE';

  // AppBar / azioni
  static const String exportShareTooltip = 'Esporta / Condividi';
  static const String projectorMode = 'Modalità Proiettore';

  // Menu di esportazione
  static const String shareImageTitle = 'Condividi immagine social';
  static const String shareImageSubtitle = 'Ottimizzata per Instagram/WhatsApp';
  static const String exportPdfTitle = 'Esporta Report PDF';
  static const String exportPdfSubtitle = 'Documento ufficiale con grafici';

  // Statistiche / proiettore
  static const String remaining = 'Rimanenti';
  static const String votesTotal = 'VOTI TOTALI';
  static const String waitingForData = 'In attesa di dati...';
  static String votesToWin(int n) => 'Mancano $n voti per la vittoria';

  // Impostazioni
  static const String votersHint = 'Es. 100';
  static const String votingOptions = 'Opzioni di Voto';
  static const String dataManagement = 'Gestione Dati';
  static const String exportLabel = 'Esporta';
  static const String importLabel = 'Importa';
  static const String configLoaded = 'Configurazione caricata con successo';

  // Modifica candidato (swing)
  static const String previousResultLabel = 'Risultato Precedente (%)';
  static const String previousResultHint = 'Es. 25.5';

  // Numbers
  static const int minParticipants = 2;
  static const int maxParticipants = 8;
}

class AppDimensions {
  static const double paddingAll = 16.0;
  static const double paddingIconText = 12.0;
  static const double paddingAppBarIcon = 8.0;
  static const double iconSizeAppBar = 20.0;
  static const double iconButtonSize = 36.0;
  static const double iconButtonIconSize = 18.0;
  static const double borderRadiusCircular = 12.0;
  static const double borderRadiusCard = 24.0;
  static const double borderRadiusButton = 16.0;
  static const double borderRadiusToggle = 30.0;
  static const double borderRadiusExport = 12.0;
  static const double chartBarWidth = 24.0;
  static const double chartBarRadius = 4.0;
  static const double chartLineBarWidth = 3.0;
  static const double chartPieRadius = 60.0;
  static const double chartPieSpace = 2.0;
  static const double chartPieCenterSpaceRadius = 40.0;
  static const double statIconSize = 24.0;
  static const double statItemSpacing = 8.0;
  static const double statItemPadding = 12.0;
  static const double comparisonBarHeight = 24.0;
  static const double comparisonNameWidth = 80.0;
}
