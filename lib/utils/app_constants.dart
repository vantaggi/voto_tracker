/// Costanti **non localizzate**: semi di dati e identificatori usati dove non c'è
/// un `BuildContext` (provider, modelli, servizi di export) o dai test.
/// I testi della UI vivono nei file ARB (`lib/l10n/`) e si usano via
/// `context.l10n` — NON aggiungere qui stringhe di interfaccia.
class AppStrings {
  // Nomi/prefissi di default dei candidati (dato persistito, fallback export)
  static const String candidatePrefix = 'Candidato';
  static const String blankVotes = 'Schede Bianche';
  static const String nullVotes = 'Schede Nulle';

  // Numeri
  static const int minParticipants = 2;
  static const int maxParticipants = 8;
}

class AppDimensions {
  /// Altezza minima della riga dei numeri del riepilogo: l'area di tocco del
  /// pulsante "Condividi", che a scrutinio completo prende il posto delle
  /// schede rimanenti.
  static const double summaryNumbersRow = 48;

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
  static const double chartsSectionHeight = 350.0;

  /// Sotto questa larghezza: NavigationBar; sopra: NavigationRail (M3).
  static const double compactBreakpoint = 600.0;

  /// Larghezza dell'archivio da cui elenco e dettaglio stanno affiancati
  /// (P8). Più del breakpoint compatto: a fianco c'è già il NavigationRail.
  static const double archiveTwoPaneBreakpoint = 720.0;

  /// Larghezza dell'elenco nell'archivio a due colonne.
  static const double archiveListPaneWidth = 400.0;

  /// Immagine da condividere (C2): 4:5, catturata a 2x = 1080 × 1350 px.
  static const double socialWidth = 540.0;
  static const double socialHeight = 675.0;
  static const double socialPixelRatio = 2.0;
  static const double socialRankDot = 30.0;
  static const double socialRowMin = 36.0;
  static const double socialRowMax = 64.0;
  static const double socialVotesWidth = 44.0;
  static const double socialBar = 8.0;
  static const double socialStackedBar = 14.0;

  /// Grafici della Home (C5).
  static const double trendChartHeight = 240.0;
  static const double chartAxisReserved = 32.0;
  static const double chartBottomReserved = 24.0;
  static const double chartLegendDot = 6.0;
  static const double compareBarHeight = 12.0;
  static const double comparePreviousTick = 3.0;
  static const double compareValueWidth = 96.0;
}

/// Scala di spaziatura (multipli di 4, griglia M3). Padding, margini e gap nei
/// widget usano solo questi valori.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double lPlus = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Spazio in fondo alle liste perché l'ultimo elemento non finisca sotto
  /// la barra dei controlli.
  static const double bottomBarClearance = 80;
}

/// Scala delle forme (raggi degli angoli) Material 3.
class AppShapes {
  AppShapes._();
  static const double extraSmall = 4;
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double largeIncreased = 20;
  static const double extraLargeCard = 24;
  static const double extraLarge = 28;
}

/// Area minima di tocco (Material e WCAG 2.5.8).
class AppTouch {
  AppTouch._();
  static const double minTarget = 48;
}
