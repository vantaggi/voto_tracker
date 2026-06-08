/// Costanti **non localizzate**: semi di dati e identificatori usati dove non c'è
/// un `BuildContext` (provider, modelli, servizi di export) o dai test.
/// I testi della UI vivono nei file ARB (`lib/l10n/`) e si usano via
/// `context.l10n` — NON aggiungere qui stringhe di interfaccia.
class AppStrings {
  // Brand (non tradotto)
  static const String appTitlePro = 'Voto Tracker Pro';

  // Nomi/prefissi di default dei candidati (dato persistito, fallback export)
  static const String candidatePrefix = 'Candidato';
  static const String blankVotes = 'Schede Bianche';
  static const String nullVotes = 'Schede Nulle';

  // Etichette IT dello stato del vincitore (usate dai getter retro-compatibili
  // del provider `winner`/`winnerLabel` e dai test; la UI usa `context.l10n`).
  static const String tie = 'Pareggio';
  static const String winnerElected = 'ELETTO';
  static const String winnerMathematical = 'VITTORIA MATEMATICA';
  static const String finalResult = 'RISULTATO FINALE';

  // Numeri
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
