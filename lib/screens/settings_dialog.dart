import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
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
    return AlertDialog(
      title: const Text(AppStrings.scrutinyConfiguration),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _totalVotersController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.totalVotersNumber,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 24),
            Text('${AppStrings.participantsCount}: ${_participantsCount.toInt()}',
                style: Theme.of(context).textTheme.titleSmall),
            Slider(
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
            const SizedBox(height: 16),
            const Text(AppStrings.cardOptions),
            SwitchListTile(
              title: const Text(AppStrings.blankVotes),
              value: _showBlankVotes,
              onChanged: (value) => setState(() => _showBlankVotes = value),
            ),
            SwitchListTile(
              title: const Text(AppStrings.nullVotes),
              value: _showNullVotes,
              onChanged: (value) => setState(() => _showNullVotes = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final int voters = int.tryParse(_totalVotersController.text) ?? 100;
            final newSettings = Settings(
                totalVoters: voters,
                participantsCount: _participantsCount.toInt(),
                showBlankVotes: _showBlankVotes,
                showNullVotes: _showNullVotes,
            );
            
            context.read<ScrutinyProvider>().updateSettings(newSettings);
            Navigator.pop(context);
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}
