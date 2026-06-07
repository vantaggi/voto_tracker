# 🎨 Voto Tracker — Design System

Token UI e regole di stile. Responsabilità unica: **come deve apparire** l'app.
Fonte tecnica: `lib/theme/app_theme.dart` e `AppDimensions` in
`lib/utils/app_constants.dart`.

> **Regola d'oro:** niente valori hardcoded nei widget. Colori dal `ColorScheme`,
> dimensioni/raggi da `AppDimensions`, testi da `AppStrings`.

## 1. Colore

- **Material 3** (`useMaterial3: true`) con `ColorScheme.fromSeed`.
- **Seed:** `Color(0xFF6366F1)` (indigo) — `AppTheme.primarySeed`.
- **Variante schema:** `DynamicSchemeVariant.fidelity` (più vivace/espressivo).
- **Light & dark** generati dallo stesso seed; `themeMode: ThemeMode.system`.
- Usa **sempre** i ruoli del `ColorScheme`, mai colori letterali:
  - sfondi: `surface`, `surfaceContainerLow/High/Highest`
  - testo: `onSurface`, `onSurfaceVariant`
  - bordi: `outline`, `outlineVariant`
  - azione: `primary` / `onPrimary`, `primaryContainer` / `onPrimaryContainer`
- **Eccezione legittima:** i colori identificativi dei candidati sono una palette
  distinta dedicata (`Candidate.color`), non un token di tema. Schede bianche =
  grigio, schede nulle = nero (vedi `_initializeCandidates`).

## 2. Forma (border radius)

Material 3 "expressive". I raggi canonici vivono in `AppDimensions`:

| Token | Valore | Uso |
|:--|:--:|:--|
| `borderRadiusCircular` | 12 | snackbar, raggio generico |
| `borderRadiusExport` | 12 | bottoni di esportazione |
| `borderRadiusButton` | 16 | bottoni |
| `borderRadiusToggle` | 30 | toggle/segmented |
| `borderRadiusCard` | 24 | card (Large expressive shape) |
| Dialog | 28 | dialoghi (Extra-large shape, nel tema) |

Bottoni nel tema usano raggio 20; gli input 16. Mantieni la coerenza: una nuova
superficie sceglie il token più vicino, non un numero nuovo.

## 3. Spaziatura e dimensioni

Tutto in `AppDimensions`. I principali:

| Token | Valore | Uso |
|:--|:--:|:--|
| `paddingAll` | 16 | padding standard di sezione |
| `paddingIconText` | 12 | gap icona↔testo |
| `iconButtonSize` | 36 | bottoni icona (voto +/-) |
| `iconButtonIconSize` | 18 | icona dentro il bottone |
| `iconSizeAppBar` | 20 | icone AppBar |
| `statIconSize` | 24 | icone statistiche |
| `comparisonBarHeight` | 24 | barra del confronto diretto |

Grafici (`fl_chart`): `chartBarWidth` 24, `chartBarRadius` 4,
`chartLineBarWidth` 3, `chartPieRadius` 60, `chartPieCenterSpaceRadius` 40.

## 4. Tipografia

`Typography.material2021()` (black per light, white per dark). Titolo AppBar 22 /
`w600`, titoli dialog 24 / `w600`. Non impostare `fontSize` arbitrari: parti dal
`textTheme` del contesto.

## 5. Componenti (override nel tema)

Già tematizzati centralmente — **non** ridefinirli inline nei widget: AppBar
(piatta, centrata, senza tint), Card (bordo `outlineVariant`, elevation 0),
Dialog, bottoni (Elevated/Filled/Text/Outlined/Icon), input (filled, senza
bordo a riposo, bordo `primary` al focus), FAB, Slider, Switch, Divider,
SnackBar (floating, `inverseSurface`).

## 6. Regole pratiche

- Nuovo testo visibile → aggiungilo a `AppStrings`, poi referenzialo.
- Nuovo padding/raggio ricorrente → aggiungilo a `AppDimensions`, non inline.
- Nuovo colore → derivalo dal `ColorScheme`; se serve un colore-dato (es. nuova
  categoria di scheda), documenta la scelta qui.
- Il PDF (`PdfExportService`) replica volutamente la palette indigo del tema con
  `PdfColors.indigo*`: se cambi il seed, allinea anche il PDF.
