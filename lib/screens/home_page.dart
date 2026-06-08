import 'package:flutter/material.dart';
import 'package:voto_tracker/l10n/export_labels.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/widgets/charts_section.dart';
import 'package:voto_tracker/widgets/candidates_section.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:voto_tracker/screens/settings_dialog.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/projector_mode_screen.dart';
import 'package:voto_tracker/services/social_share_service.dart';
import 'package:voto_tracker/services/pdf_export_service.dart';
import 'package:voto_tracker/services/data_export_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable(); // Keep screen on while on this page
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
            IconButton(
                icon: const Icon(Icons.ios_share),
                tooltip: l10n.exportShareTooltip,
                onPressed: () => _showExportOptions(context),
            ),
            IconButton(
                icon: const Icon(Icons.tv),
                tooltip: l10n.projectorMode,
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProjectorModeScreen())
                ),
            ),
            IconButton(
                icon: const Icon(Icons.settings),
                tooltip: l10n.settingsTooltip,
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const SettingsDialog()
                ),
            )
        ],
      ),
      body: LayoutBuilder(
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
                      ]
                  );
              } else {
                  // Mobile
                          return const SingleChildScrollView(
                              child: Column(
                                  children: [
                                      SizedBox(height: 350, child: ChartsSection()),
                                      Divider(height: 1),
                                      CandidatesSection(isScrollable: false),
                                  ]
                              )
                          );
              }
          }
      ),
    );
  }
  void _showExportOptions(BuildContext context) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            final l10n = context.l10n;
            final labels = ExportLabels.of(l10n);
            return SafeArea(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      ListTile(
                          leading: const Icon(Icons.image),
                          title: Text(l10n.shareImageTitle),
                          subtitle: Text(l10n.shareImageSubtitle),
                          onTap: () async {
                              final provider = context.read<ScrutinyProvider>();
                              final winnerName = provider.isTie ? l10n.tie : provider.winnerName;
                              final winnerLbl = localizedWinnerLabel(l10n, provider.winnerStatus);
                              Navigator.pop(context);

                              await SocialShareService.shareResults(
                                  candidates: provider.sortedCandidates,
                                  totalVotes: provider.totalVotesAssigned,
                                  totalVoters: provider.settings.totalVoters,
                                  remainingVotes: provider.remainingVotes,
                                  labels: labels,
                                  winner: winnerName,
                                  winnerLabel: winnerLbl
                              );
                          },
                      ),
                      ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: Text(l10n.exportPdfTitle),
                          subtitle: Text(l10n.exportPdfSubtitle),
                          onTap: () async {
                               final provider = context.read<ScrutinyProvider>();
                               final winnerName = provider.isTie ? l10n.tie : provider.winnerName;
                               final winnerLbl = localizedWinnerLabel(l10n, provider.winnerStatus);
                               Navigator.pop(context);

                               await PdfExportService.exportToPdf(
                                   candidates: provider.sortedCandidates,
                                   totalVotesAssigned: provider.totalVotesAssigned,
                                   totalVoters: provider.settings.totalVoters,
                                   remainingVotes: provider.remainingVotes,
                                   historyPoints: provider.historyPoints,
                                   labels: labels,
                                   winner: winnerName,
                                   winnerLabel: winnerLbl
                               );
                          },
                      ),
                      ListTile(
                          leading: const Icon(Icons.table_chart_outlined),
                          title: Text(l10n.exportCsvTitle),
                          subtitle: Text(l10n.exportCsvSubtitle),
                          onTap: () async {
                              final provider = context.read<ScrutinyProvider>();
                              final messenger = ScaffoldMessenger.of(context);
                              final errorMsg = l10n.exportError;
                              Navigator.pop(context);
                              final ok = await DataExportService.shareCsv(provider.exportToCsv());
                              if (!ok) {
                                  messenger.showSnackBar(SnackBar(content: Text(errorMsg)));
                              }
                          },
                      ),
                      ListTile(
                          leading: const Icon(Icons.data_object),
                          title: Text(l10n.exportJsonTitle),
                          subtitle: Text(l10n.exportJsonSubtitle),
                          onTap: () async {
                              final provider = context.read<ScrutinyProvider>();
                              final messenger = ScaffoldMessenger.of(context);
                              final errorMsg = l10n.exportError;
                              Navigator.pop(context);
                              final ok = await DataExportService.shareJson(provider.exportToJson());
                              if (!ok) {
                                  messenger.showSnackBar(SnackBar(content: Text(errorMsg)));
                              }
                          },
                      ),
                  ],
              )
            );
          }
      );
  }
}
