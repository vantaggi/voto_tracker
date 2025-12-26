import 'package:flutter/material.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/charts_section.dart';
import 'package:voto_tracker/widgets/candidates_section.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:voto_tracker/screens/settings_dialog.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/projector_mode_screen.dart';
import 'package:voto_tracker/services/social_share_service.dart';
import 'package:voto_tracker/services/pdf_export_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable(); // Keep screen on while on this page
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
            IconButton(
                icon: const Icon(Icons.ios_share),
                tooltip: "Esporta / Condividi",
                onPressed: () => _showExportOptions(context),
            ),
            IconButton(
                icon: const Icon(Icons.tv),
                tooltip: "Modalità Proiettore",
                onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ProjectorModeScreen())
                ),
            ),
            IconButton(
                icon: const Icon(Icons.settings),
                tooltip: AppStrings.settingsButtonTooltip,
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
          builder: (context) => SafeArea(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      ListTile(
                          leading: const Icon(Icons.image),
                          title: const Text("Condividi immagine social"),
                          subtitle: const Text("Ottimizzata per Instagram/WhatsApp"),
                          onTap: () async {
                              Navigator.pop(context);
                              final provider = context.read<ScrutinyProvider>();
                              
                              String? label;
                              if (provider.winner != null) {
                                  if (provider.winner == AppStrings.tie) {
                                      label = "RISULTATO FINALE";
                                  } else {
                                      label = provider.remainingVotes <= 0 ? "ELETTO" : "MAGGIORANZA RAGGIUNTA";
                                  }
                              }

                              await SocialShareService.shareResults(
                                  candidates: provider.sortedCandidates, 
                                  totalVotes: provider.totalVotesAssigned,
                                  totalVoters: provider.settings.totalVoters,
                                  remainingVotes: provider.remainingVotes,
                                  winner: provider.winner,
                                  winnerLabel: label
                              );
                          },
                      ),
                      ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: const Text("Esporta Report PDF"),
                          subtitle: const Text("Documento ufficiale con grafici"),
                          onTap: () async {
                               Navigator.pop(context);
                               final provider = context.read<ScrutinyProvider>();
                               
                               String? label;
                               if (provider.winner != null) {
                                   if (provider.winner == AppStrings.tie) {
                                       label = "RISULTATO FINALE";
                                   } else {
                                       label = provider.remainingVotes <= 0 ? "ELETTO" : "MAGGIORANZA RAGGIUNTA";
                                   }
                               }

                               await PdfExportService.exportToPdf(
                                   candidates: provider.candidates, 
                                   totalVotesAssigned: provider.totalVotesAssigned,
                                   totalVoters: provider.settings.totalVoters,
                                   remainingVotes: provider.remainingVotes,
                                   historyPoints: provider.historyPoints,
                                   winner: provider.winner,
                                   winnerLabel: label
                               );
                          },
                      ),
                  ],
              )
          )
      );
  }
}
