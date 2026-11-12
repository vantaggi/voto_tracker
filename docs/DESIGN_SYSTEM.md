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
Dialog, bottoni (Elevated/Filled/Text/Outlined), input (filled, senza
bordo a riposo, bordo `primary` al focus), FAB, Slider, Switch, Divider,
SnackBar (floating, `inverseSurface`).

## 5.1 Home (ridisegno R1-R7)

- Righe di conteggio: 84 dp di altezza minima (64 per bianche e nulle),
  pallino del candidato da 40 dp con la posizione, + pieno da 56 dp
  (`IconButton.filled`), − standard con area da 48 dp, voti in cifre
  tabellari in un riquadro da 48 dp.
- Il + è l'unico elemento pieno della riga; bianche e nulle usano il +
  tonale. L'ordine delle righe non cambia mai: la classifica sta nel pallino.
- Riepilogo su `surfaceContainerHigh`; esito su `primaryContainer`
  (`tertiaryContainer` se senza vincitore) con tutto il testo `on*Container`.
- Pillola Annulla su `inverseSurface`, a forma di stadio, alta 56 dp.
- Niente `iconButtonTheme` con `foregroundColor`: renderebbe grigia l'icona
  delle IconButton piene.

## 5.2 Altre schermate (ridisegno S1-S7)

- `VoteStackedBar` è l'unica barra dei voti: 12 dp in Home, 6 dp nelle righe
  dell'Archivio, 8 dp in Lettura schede e in Condividi, 12 dp nel proiettore.
  Ordine: classifica, poi bianche e nulle; il resto è `surfaceContainerHighest`.
- Impostazioni: gruppi con titolo `titleSmall` in `primary`, contatori − / +
  con `IconButton.outlined` e campo da 88 dp. Pagina intera sotto 600 dp,
  finestra da 560 dp sopra. Salva pieno; diventa "Salva e azzera" su `error`
  quando si perderebbero voti.
- Lettura schede: tessere 88–300 dp, nome `headlineSmall` (`headlineMedium`
  da 160 dp), voti in un riquadro piccolo nell'angolo; bianche e nulle
  `OutlinedButton` da 72 dp.
- Proiettore: tema scuro, righe 56–160 dp su `surfaceContainer` con la quota
  in colore al 45%; primo posto su `primary`.
- Colori dei candidati scelti solo da `CandidatePalette.candidates`, cerchi
  da 36 dp in aree da 48 dp.

## 5.3 Condivisioni e grafici (C1-C6)

- Tutti gli export partono da una sola `ResultsSnapshot` e formattano con
  `ExportFormat`: virgola decimale in italiano, variazioni "+6,7 punti" con
  il segno sempre scritto, date "12 novembre 2026, 10:28", file
  "Titolo - AAAA-MM-GG.ext".
- Immagine: 540 × 675 dp catturati a 2x, tema scuro, righe 36–64 dp con barra
  da 8 dp, al massimo quante ne entrano e poi "+N altri".
- PDF: A4 verticale, schema chiaro (`PdfPalette`), esito su
  `primaryContainer` (`tertiaryContainer` senza vincitore), una sola tabella
  dei risultati; firme solo a scrutinio completo.
- Grafici: linee a gradini (mai curve), tacche intere con passo 1/2/5,
  `FilterChip` come legenda; Confronto a barre con tacca sul precedente.

## 5.4 Icona e splash (I1-I5)

- Icona "Stanghette": quattro stanghette bianche e la diagonale corallo
  `#FF8F80` su indaco `#4648D4` (primary chiaro), nel quadro da 108 dp con
  tutto dentro la zona sicura (raggio 33). Livello monocromatico per le icone a
  tema. Geometria e colori solo in `scripts/make_icons.py`.
- Debug: banda ambra `#FFC857` con "DEBUG" in basso.
- Splash: fondo `surface` (`#FCF8FF` / `#13131B`), disegno su cerchio
  `primary` (indaco in chiaro, lilla `#C0C1FF` con stanghette `#1000A9` in
  scuro). Niente animazione né logo in basso; la finestra dietro Flutter ha lo
  stesso fondo.

## 6. Regole pratiche

- Nuovo testo visibile → aggiungilo a `lib/l10n/app_en.arb` e `app_it.arb`,
  rigenera con `flutter gen-l10n` e usalo via `context.l10n`.
- Nuovo padding/raggio → usa il token più vicino di `AppSpacing`/`AppShapes`;
  una dimensione specifica (es. altezza di un grafico) va in `AppDimensions`.
- Nuovo colore → derivalo dal `ColorScheme`; se serve un colore-dato (es. nuova
  categoria di scheda), documenta la scelta qui.
- Il PDF (`PdfExportService`) prende i colori dallo schema chiaro dell'app
  con `PdfPalette.fromScheme`: segue anche il colore dinamico.
