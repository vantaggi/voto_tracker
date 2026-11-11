# 🎨 Voto Tracker — Design System

Token UI e regole di stile. Responsabilità unica: **come deve apparire** l'app.
Fonte tecnica: `lib/theme/app_theme.dart` e `AppDimensions` in
`lib/utils/app_constants.dart`.

> **Regola d'oro:** niente valori hardcoded nei widget. Colori dal `ColorScheme`
> (o `CandidatePalette` / `TrendColors`), spaziature da `AppSpacing`, raggi da
> `AppShapes`, testi dal `textTheme` e dai file ARB via `context.l10n`.
> `test/design_tokens_test.dart` fallisce se in `lib/widgets` o `lib/screens`
> compaiono `Colors.*` (tranne `transparent`), `fontSize`, `EdgeInsets`,
> `SizedBox` o `BorderRadius.circular` con numeri.

## 1. Colore

- **Material 3** con `ColorScheme.fromSeed`, light e dark, `ThemeMode.system`.
- **Colore dinamico** (`dynamic_color`, default attivo): su Android 12+ il seed è
  il colore primario dello sfondo, variante `tonalSpot` (come Material You).
  Senza colore di sistema o con l'interruttore spento: seed indigo
  `0xFF6366F1` (`AppTheme.primarySeed`), variante `fidelity`. I temi si leggono
  con `context.read<AppThemes>()` (es. il proiettore usa sempre `dark`).
- Usa **sempre** i ruoli del `ColorScheme`: `surface*`, `onSurface*`,
  `outline*`, `primary*`, `secondaryContainer`, `error*`.
- **Candidati:** `CandidatePalette` (`lib/theme/candidate_palette.dart`), 8 colori
  HCT tono 52 croma 70, contrasto ≥ 3:1 su entrambe le superfici; bianche
  `0xFF8B8B8B`, nulle `0xFF6A6A6A`. Testo sopra: `CandidatePalette.onColor`.
- **Swing:** `TrendColors.of(context)` (ThemeExtension): `positive` verde HCT,
  `negative` = `colorScheme.error`.

## 2. Forma (border radius) — `AppShapes`

| Token | Valore | Uso |
|:--|:--:|:--|
| `extraSmall` | 4 | barre di avanzamento |
| `small` | 8 | badge, chip dei grafici |
| `medium` | 12 | pill del rank, box informativi |
| `large` | 16 | pulsanti della lettura schede |
| `largeIncreased` | 20 | indicatore delle tab |
| `extraLargeCard` | 24 | card, barra delle tab |
| `extraLarge` | 28 | dialog |

## 3. Spaziatura e dimensioni — `AppSpacing`, `AppTouch`

Scala a multipli di 4: `xs` 4 · `s` 8 · `m` 12 · `l` 16 · `lPlus` 20 · `xl` 24 ·
`xxl` 32 · `xxxl` 48; `bottomBarClearance` 80 in fondo alle liste.
Area di tocco minima `AppTouch.minTarget` = 48 dp (verificata da
`androidTapTargetGuideline` nei test). Breakpoint `AppDimensions.compactBreakpoint`
= 600 dp (NavigationBar sotto, NavigationRail sopra). Le dimensioni dei grafici
restano in `AppDimensions`.

## 3.1 Accessibilità

- Testo al 200% senza overflow (`test/accessibility_test.dart`): righe con testo
  variabile in `Expanded`/`Flexible`.
- Etichette parlate: conteggio voti per candidato, "+"/"−" con il nome, reset
  come pulsante con azione long press.
- Edge-to-edge: barre di sistema trasparenti; inset gestiti da AppBar,
  `SafeArea` e barra dei controlli.

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

- Nuovo testo visibile → aggiungilo a `lib/l10n/app_en.arb` e `app_it.arb`,
  rigenera con `flutter gen-l10n` e usalo via `context.l10n`.
- Nuovo padding/raggio → usa il token più vicino di `AppSpacing`/`AppShapes`;
  una dimensione specifica (es. altezza di un grafico) va in `AppDimensions`.
- Nuovo colore → derivalo dal `ColorScheme`; se serve un colore-dato (es. nuova
  categoria di scheda), documenta la scelta qui.
- Il PDF (`PdfExportService`) replica volutamente la palette indigo del tema con
  `PdfColors.indigo*`: se cambi il seed, allinea anche il PDF.
