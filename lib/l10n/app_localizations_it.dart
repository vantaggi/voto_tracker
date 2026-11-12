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
  String get shareImageTitle => 'Immagine';

  @override
  String get shareImageSubtitle => 'Per WhatsApp e social';

  @override
  String get exportPdfTitle => 'Report PDF';

  @override
  String get exportPdfSubtitle => 'Da stampare o archiviare';

  @override
  String get exportCsvTitle => 'CSV';

  @override
  String get exportCsvSubtitle => 'Per fogli di calcolo';

  @override
  String get exportJsonTitle => 'JSON';

  @override
  String get exportJsonSubtitle => 'Tutti i dati';

  @override
  String get exportError => 'Errore durante l\'esportazione';

  @override
  String votesToWin(int count) {
    return 'Mancano $count voti per la vittoria';
  }

  @override
  String get winnerElected => 'ELETTO';

  @override
  String get winnerMathematical => 'VITTORIA MATEMATICA';

  @override
  String get finalResult => 'RISULTATO FINALE';

  @override
  String get tie => 'Pareggio';

  @override
  String get blankVotes => 'Schede bianche';

  @override
  String get spoiledVotes => 'Schede nulle';

  @override
  String get editName => 'Modifica candidato';

  @override
  String get candidateName => 'Nome';

  @override
  String get previousResultLabel => 'Risultato precedente';

  @override
  String get previousResultHint => 'Es. 25.5';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get undoTooltip => 'Annulla ultima azione';

  @override
  String get redoTooltip => 'Ripristina azione';

  @override
  String get participantsCount => 'Numero Candidati';

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

  @override
  String get appearance => 'Aspetto';

  @override
  String get useSystemColors => 'Colori di sistema';

  @override
  String get useSystemColorsSubtitle =>
      'Usa i colori dello sfondo del telefono (Android 12+)';

  @override
  String addVoteFor(String name) {
    return 'Aggiungi un voto a $name';
  }

  @override
  String removeVoteFor(String name) {
    return 'Togli un voto a $name';
  }

  @override
  String get navScrutiny => 'Scrutinio';

  @override
  String get navArchive => 'Archivio';

  @override
  String get archiveTitle => 'Archivio scrutini';

  @override
  String get newScrutiny => 'Nuovo scrutinio';

  @override
  String defaultScrutinyTitle(String date) {
    return 'Scrutinio del $date';
  }

  @override
  String get archiveOpen => 'Apri';

  @override
  String get archiveDuplicate => 'Duplica come modello';

  @override
  String get archiveRename => 'Rinomina';

  @override
  String get archiveDelete => 'Elimina';

  @override
  String archiveBallots(int counted, int total) {
    return '$counted su $total schede';
  }

  @override
  String archiveLeader(String name) {
    return 'In testa: $name';
  }

  @override
  String get archiveDeleteTitle => 'Eliminare lo scrutinio?';

  @override
  String archiveDeleteBody(String title) {
    return '«$title» e tutte le sue schede verranno eliminati. L\'operazione non si può annullare.';
  }

  @override
  String get archiveRenameHint => 'Lascia vuoto per il titolo predefinito';

  @override
  String get scrutinyTitleLabel => 'Titolo';

  @override
  String archiveOpened(String title) {
    return 'Aperto «$title»';
  }

  @override
  String archiveActions(String title) {
    return 'Azioni per $title';
  }

  @override
  String get outcomeNoMajority => 'Ballottaggio';

  @override
  String get outcomeNoQuorum => 'Quorum non raggiunto';

  @override
  String get victoryRuleTitle => 'Regola di vittoria';

  @override
  String get rulePlurality => 'Maggioranza relativa';

  @override
  String get ruleAbsoluteMajority => 'Maggioranza assoluta';

  @override
  String get ruleAbsoluteMajorityHint =>
      'Vince chi supera la metà delle schede, bianche e nulle comprese';

  @override
  String get quorumTitle => 'Quorum di affluenza';

  @override
  String get quorumSubtitle =>
      'Valido solo se votano abbastanza aventi diritto';

  @override
  String get eligibleVotersLabel => 'Aventi diritto';

  @override
  String get quorumPercentLabel => 'Quorum (%)';

  @override
  String get ballotReadingTitle => 'Lettura schede';

  @override
  String ballotNumber(int n, int total) {
    return 'Scheda $n di $total';
  }

  @override
  String get countingComplete => 'Scrutinio completato';

  @override
  String get ballotHint => 'Tocca il nome scritto sulla scheda';

  @override
  String defaultCandidateName(int number) {
    return 'Candidato $number';
  }

  @override
  String get archiveMoreActions => 'Altre azioni dell\'archivio';

  @override
  String get archiveExport => 'Esporta archivio';

  @override
  String get archiveImport => 'Importa da file';

  @override
  String get archiveImportTitle => 'Importa scrutini';

  @override
  String archiveImportBody(int count) {
    return 'Nel file ci sono $count scrutini. Verranno aggiunti all\'archivio: quelli già presenti non vengono toccati.';
  }

  @override
  String get archiveImportConfirm => 'Aggiungi';

  @override
  String archiveImported(int added, int skipped) {
    return 'Scrutini aggiunti: $added. Già presenti: $skipped.';
  }

  @override
  String get archiveImportInvalid =>
      'Questo file non è un archivio di Voto Tracker';

  @override
  String get archiveImportEmpty => 'Il file non contiene scrutini';

  @override
  String projectorRowSemantics(
    int position,
    String name,
    int votes,
    String percent,
  ) {
    return '$position° posto, $name: $votes voti, $percent%';
  }

  @override
  String get useAsDefaults => 'Usa anche per i nuovi scrutini';

  @override
  String get useAsDefaultsHint =>
      'Votanti, regola e quorum di partenza per ogni nuovo scrutinio';

  @override
  String get saveAsList => 'Salva i candidati come lista';

  @override
  String get listNameLabel => 'Nome della lista';

  @override
  String listSaved(String name) {
    return 'Lista «$name» salvata';
  }

  @override
  String get newEmptyScrutiny => 'Scrutinio vuoto';

  @override
  String listCandidates(int count) {
    return '$count candidati';
  }

  @override
  String deleteList(String name) {
    return 'Elimina la lista $name';
  }

  @override
  String homeSubtitle(int assigned, int total) {
    return '$assigned di $total schede';
  }

  @override
  String summaryOfTotal(int total) {
    return '/ $total schede';
  }

  @override
  String summaryRemaining(int count) {
    return '$count rimanenti';
  }

  @override
  String get summaryCompleted => 'Completato';

  @override
  String summaryLeading(String name) {
    return 'In testa $name';
  }

  @override
  String get summaryLeadingTie => 'Pareggio in testa';

  @override
  String get summaryEmptyTitle => 'Nessuna scheda ancora';

  @override
  String get summaryEmptyHint => 'Tocca + per contare la prima scheda.';

  @override
  String get shareResults => 'Condividi i risultati';

  @override
  String get otherBallots => 'Altre schede';

  @override
  String candidateRowSemantics(String name, int votes, String percent) {
    return '$name: $votes voti, $percent';
  }

  @override
  String get chartsTitle => 'Andamento e grafici';

  @override
  String get chartsSubtitle => 'Andamento e confronto';

  @override
  String undoLastVote(String name) {
    return 'Annulla $name';
  }

  @override
  String get moreActions => 'Altre azioni';

  @override
  String get resetScrutiny => 'Azzera scrutinio';

  @override
  String get resetConfirmTitle => 'Azzerare lo scrutinio?';

  @override
  String get resetConfirmBody =>
      'Tutti i voti tornano a zero. Nomi e colori dei candidati restano. Non si può annullare.';

  @override
  String get resetConfirm => 'Azzera';

  @override
  String settingsResetWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'le $count schede contate',
      one: 'la scheda contata',
    );
    return 'Cambiando candidati, bianche o nulle si azzerano $_temp0. Nomi e colori restano.';
  }

  @override
  String get saveAndReset => 'Salva e azzera';

  @override
  String get settingsTitle => 'Impostazioni dello scrutinio';

  @override
  String get settingsGroupBallots => 'Schede e candidati';

  @override
  String get settingsGroupRules => 'Regole';

  @override
  String get settingsGroupLists => 'Liste di candidati';

  @override
  String get settingsVoters => 'Votanti';

  @override
  String get settingsVotersHint => 'Schede attese in tutto';

  @override
  String get settingsCandidates => 'Candidati';

  @override
  String settingsCandidatesHint(int min, int max) {
    return 'Da $min a $max';
  }

  @override
  String stepperDecrease(String label) {
    return 'Diminuisci $label';
  }

  @override
  String stepperIncrease(String label) {
    return 'Aumenta $label';
  }

  @override
  String get listExportFile => 'Esporta i candidati in un file';

  @override
  String get listImportFile => 'Importa i candidati da un file';

  @override
  String get appSettingsTitle => 'Impostazioni dell\'app';

  @override
  String get appSettingsSubtitle => 'Lingua e aspetto';

  @override
  String get archiveGroupCurrent => 'Aperto ora';

  @override
  String get archiveGroupOthers => 'Altri scrutini';

  @override
  String get archiveSearch => 'Cerca per nome';

  @override
  String get archiveNoResults => 'Nessuno scrutinio con questo nome';

  @override
  String get archiveReopen => 'Riapri';

  @override
  String get archiveGoToCount => 'Vai al conteggio';

  @override
  String get archiveExportOne => 'Esporta';

  @override
  String get newEmptyScrutinyHint => 'Candidati e impostazioni di partenza';

  @override
  String newFromCopy(String title) {
    return 'Copia «$title»';
  }

  @override
  String get newFromCopyHint => 'Stessi candidati e regole, nessuna scheda';

  @override
  String get newFromList => 'Da una lista salvata';

  @override
  String get ballotBackToCount => 'Torna allo scrutinio';

  @override
  String ballotTileSemantics(String name, int votes) {
    String _temp0 = intl.Intl.pluralLogic(
      votes,
      locale: localeName,
      other: '$votes voti',
      one: '1 voto',
    );
    return '$name, $_temp0';
  }

  @override
  String exportSheetTitle(String title) {
    return 'Condividi «$title»';
  }

  @override
  String get exportDataLabel => 'Solo i dati';

  @override
  String get candidateColor => 'Colore';

  @override
  String candidateColorOption(int n) {
    return 'Colore $n';
  }

  @override
  String get previousResultHelper =>
      'Nelle righe compare di quanto è salito o sceso';

  @override
  String previousResultHintNumber(String example) {
    return 'Es. $example';
  }

  @override
  String get exportStatusInProgress => 'In corso';

  @override
  String get exportStatusFinal => 'Risultato finale';

  @override
  String exportVotesPercent(String votes, String percent) {
    return '$votes voti · $percent';
  }

  @override
  String exportMoreCandidates(String count) {
    return '+$count altri';
  }

  @override
  String get exportFooterApp => 'Creato con Voto Tracker';

  @override
  String exportShareText(String title) {
    return '$title · risultati';
  }

  @override
  String get pdfTitle => 'VERBALE DEI RISULTATI';

  @override
  String pdfExpectedVoters(String count) {
    return '$count schede attese';
  }

  @override
  String pdfProvisional(String counted, String total) {
    return 'Risultato provvisorio: contate $counted schede su $total.';
  }

  @override
  String pdfWinnerDetail(String votes, String counted, String percent) {
    return '$votes voti su $counted schede ($percent)';
  }

  @override
  String get pdfKeyCounted => 'schede contate';

  @override
  String get pdfKeyRemaining => 'rimanenti';

  @override
  String get pdfKeyValid => 'voti validi';

  @override
  String get pdfKeyBlankSpoiled => 'bianche · nulle';

  @override
  String get pdfKeyTurnout => 'affluenza';

  @override
  String pdfCountedOf(String counted, String total) {
    return '$counted di $total';
  }

  @override
  String get pdfResults => 'Risultati';

  @override
  String get pdfColCandidate => 'Candidato';

  @override
  String get pdfColVotes => 'Voti';

  @override
  String get pdfColChange => 'Rispetto a prima';

  @override
  String get pdfTotal => 'Totale';

  @override
  String get pdfNote => 'Percentuali sulle schede contate.';

  @override
  String get pdfNoteChange =>
      '«Rispetto a prima» in punti percentuali sul risultato precedente.';

  @override
  String get pdfTrend => 'Andamento';

  @override
  String get pdfTrendAxes => 'voti · schede contate';

  @override
  String get pdfSignPresident => 'Il presidente';

  @override
  String get pdfSignTellers => 'Gli scrutatori';

  @override
  String pdfPage(String page, String pages) {
    return 'Pagina $page di $pages';
  }

  @override
  String get csvPosition => 'Posizione';

  @override
  String get csvCandidate => 'Candidato';

  @override
  String get csvType => 'Tipo';

  @override
  String get csvVotes => 'Voti';

  @override
  String get csvPercent => 'Percentuale';

  @override
  String get csvPrevious => 'Percentuale precedente';

  @override
  String get csvChange => 'Variazione';

  @override
  String get csvTypeCandidate => 'candidato';

  @override
  String get csvTypeBlank => 'bianca';

  @override
  String get csvTypeSpoiled => 'nulla';

  @override
  String get chartTrend => 'Andamento';

  @override
  String get chartCompare => 'Confronto';

  @override
  String get chartBallotsAxis => 'Schede contate';

  @override
  String get chartTechnicalChip => 'Bianche e nulle';

  @override
  String chartAtBallot(String n, String values) {
    return 'Alla scheda $n: $values';
  }

  @override
  String chartAfter(String n, String values) {
    return 'Dopo $n schede: $values';
  }

  @override
  String get chartEmpty => 'I grafici compaiono dal primo voto';

  @override
  String get chartLegendNow => 'Ora';

  @override
  String get chartLegendPrevious => 'Risultato precedente';

  @override
  String chartPoints(String value) {
    return '$value punti';
  }

  @override
  String chartCompareRow(String name, String percent) {
    return '$name: $percent';
  }

  @override
  String chartCompareRowChange(String name, String percent, String change) {
    return '$name: $percent, $change punti rispetto a prima';
  }
}
