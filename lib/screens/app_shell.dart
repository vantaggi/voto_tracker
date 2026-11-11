import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/l10n/app_localizations.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/screens/archive_page.dart';
import 'package:voto_tracker/screens/home_page.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Navigazione principale (UI-005): Scrutinio / Archivio.
/// `NavigationBar` sotto i 600 dp di larghezza (telefono), `NavigationRail`
/// sopra (tablet, desktop, telefono in orizzontale).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // Chiave globale: passando da NavigationBar a NavigationRail (rotazione,
  // finestra ridimensionata) le pagine conservano il loro stato.
  final _pagesKey = GlobalKey();

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = IndexedStack(
      key: _pagesKey,
      index: _index,
      children: [
        const HomePage(),
        ArchivePage(onOpened: () => _select(0)),
      ],
    );

    // LayoutBuilder e non MediaQuery: conta lo spazio davvero disponibile
    // (finestre ridimensionate, multi-finestra).
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth < AppDimensions.compactBreakpoint
          ? _compact(l10n, pages)
          : _expanded(l10n, pages),
    );
  }

  Widget _compact(AppLocalizations l10n, Widget pages) {
    return Scaffold(
      body: pages,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.how_to_vote_outlined),
            selectedIcon: const Icon(Icons.how_to_vote),
            label: l10n.navScrutiny,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: l10n.navArchive,
          ),
        ],
      ),
    );
  }

  Widget _expanded(AppLocalizations l10n, Widget pages) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.how_to_vote_outlined),
                  selectedIcon: const Icon(Icons.how_to_vote),
                  label: Text(l10n.navScrutiny),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.inventory_2_outlined),
                  selectedIcon: const Icon(Icons.inventory_2),
                  label: Text(l10n.navArchive),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: pages),
        ],
      ),
    );
  }
}
