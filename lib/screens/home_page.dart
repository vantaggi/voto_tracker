import 'package:flutter/material.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:voto_tracker/widgets/charts_section.dart';
import 'package:voto_tracker/widgets/candidates_section.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:voto_tracker/screens/settings_dialog.dart';

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
              if (constraints.maxWidth > 800) {
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
}
