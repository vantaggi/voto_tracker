import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/services/configuration_service.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _totalVotersController;
  late double _participantsCount;
  late bool _showBlankVotes;
  late bool _showNullVotes;

  @override
  void initState() {
    super.initState();
    final settings = context.read<ScrutinyProvider>().settings;
    _totalVotersController = TextEditingController(text: settings.totalVoters.toString());
    _participantsCount = settings.participantsCount.toDouble();
    _showBlankVotes = settings.showBlankVotes;
    _showNullVotes = settings.showNullVotes;
  }
  
  @override
  void dispose() {
      _totalVotersController.dispose();
      super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dialog theme is already handled by AppTheme (rounded corners, bg color)
    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          const Icon(Icons.settings_outlined, size: 28),
          const SizedBox(width: 12),
          Text(AppStrings.scrutinyConfiguration, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _totalVotersController,
              autofocus: true,
              keyboardType: TextInputType.number,
              // Theme handles InputDecoration
              decoration: const InputDecoration(
                labelText: AppStrings.totalVotersNumber,
                prefixIcon: Icon(Icons.people_outline),
                hintText: "Es. 100",
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
                '${AppStrings.participantsCount}: ${_participantsCount.toInt()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("${AppStrings.minParticipants}", style: Theme.of(context).textTheme.bodySmall),
                Expanded(
                  child: Slider(
                    value: _participantsCount,
                    min: AppStrings.minParticipants.toDouble(),
                    max: AppStrings.maxParticipants.toDouble(),
                    divisions: (AppStrings.maxParticipants - AppStrings.minParticipants),
                    label: _participantsCount.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _participantsCount = value;
                      });
                    },
                  ),
                ),
                Text("${AppStrings.maxParticipants}", style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            
            const SizedBox(height: 24),
            Text("Opzioni di Voto", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(AppStrings.blankVotes),
                    secondary: const Icon(Icons.check_box_outline_blank),
                    value: _showBlankVotes,
                    onChanged: (value) => setState(() => _showBlankVotes = value),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text(AppStrings.nullVotes),
                     secondary: const Icon(Icons.block),
                    value: _showNullVotes,
                    onChanged: (value) => setState(() => _showNullVotes = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text("Gestione Dati", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // Using OutlinedButtons for secondary actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Esporta"),
                    onPressed: () async {
                       final provider = context.read<ScrutinyProvider>();
                       await ConfigurationService.exportConfiguration(provider.candidates);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Importa"),
                    onPressed: () async {
                       final candidates = await ConfigurationService.importConfiguration();
                       if (candidates != null && context.mounted) {
                           Navigator.pop(context); // Close dialog
                           context.read<ScrutinyProvider>().loadConfiguration(candidates);
                           ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("Configurazione caricata con successo"))
                           );
                       }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel),
        ),
        FilledButton.tonal( // Tonal button for save
          onPressed: () {
            final int voters = int.tryParse(_totalVotersController.text) ?? 100;
            final newSettings = Settings(
                totalVoters: voters,
                participantsCount: _participantsCount.toInt(),
                showBlankVotes: _showBlankVotes,
                showNullVotes: _showNullVotes,
            );
            
            final provider = context.read<ScrutinyProvider>();
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
            Future.delayed(const Duration(milliseconds: 150), () {
                try {
                   provider.updateSettings(newSettings);
                } catch(e) {
                   debugPrint("Error saving settings: $e");
                }
            });
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}
