import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/widgets/charts_section.dart';
import 'package:voto_tracker/widgets/candidates_section.dart';
import 'package:voto_tracker/widgets/export_sheet.dart';
import 'package:voto_tracker/widgets/keep_screen_on.dart';
import 'package:voto_tracker/screens/settings_dialog.dart';
import 'package:voto_tracker/screens/ballot_reading_screen.dart';
import 'package:voto_tracker/screens/projector_mode_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Schermo acceso finché la Home è nell'albero (non a ogni rebuild).
    return KeepScreenOn(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: l10n.exportShareTooltip,
              onPressed: () => showExportSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.ballot_outlined),
              tooltip: l10n.ballotReadingTitle,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BallotReadingScreen(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tv),
              tooltip: l10n.projectorMode,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectorModeScreen(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: l10n.settingsTooltip,
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              ),
            ),
          ],
        ),
        // Edge-to-edge: l'AppBar gestisce l'inset in alto, la barra dei
        // controlli quello in basso; qui restano i lati (notch in orizzontale).
        body: SafeArea(
          top: false,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Only switch to side-by-side if we have enough width AND height
              if (constraints.maxWidth > 800 && constraints.maxHeight > 500) {
                // Desktop / Tablet Landscape
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: ChartsSection()),
                    VerticalDivider(width: 1),
                    Expanded(flex: 2, child: CandidatesSection()),
                  ],
                );
              } else {
                // Mobile
                return const SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: AppDimensions.chartsSectionHeight,
                        child: ChartsSection(),
                      ),
                      Divider(height: 1),
                      CandidatesSection(isScrollable: false),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
