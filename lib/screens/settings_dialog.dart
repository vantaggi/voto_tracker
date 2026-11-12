import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/appearance_provider.dart';
import 'package:voto_tracker/providers/locale_provider.dart';
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
  late VictoryRule _rule;
  late bool _quorumOn;
  late TextEditingController _eligibleController;
  late TextEditingController _quorumController;
  late bool _useAsDefaults;

  @override
  void initState() {
    super.initState();
    final settings = context.read<ScrutinyProvider>().settings;
    _useAsDefaults = context.read<ScrutinyProvider>().defaultSettings != null;
    _totalVotersController = TextEditingController(
      text: settings.totalVoters.toString(),
    );
    _participantsCount = settings.participantsCount.toDouble();
    _showBlankVotes = settings.showBlankVotes;
    _showNullVotes = settings.showNullVotes;
    _rule = settings.victoryRule;
    _quorumOn = settings.hasQuorum;
    _eligibleController = TextEditingController(
      text: settings.eligibleVoters?.toString() ?? '',
    );
    _quorumController = TextEditingController(
      text: (settings.quorumPercent ?? 50).toString(),
    );
  }

  @override
  void dispose() {
    _totalVotersController.dispose();
    _eligibleController.dispose();
    _quorumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();
    // Dialog theme is already handled by AppTheme (rounded corners, bg color)
    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          const Icon(Icons.settings_outlined, size: 28),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              l10n.scrutinyConfiguration,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _totalVotersController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.totalVotersNumber,
                prefixIcon: const Icon(Icons.people_outline),
                hintText: l10n.votersHint,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text(
              '${l10n.participantsCount}: ${_participantsCount.toInt()}',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Text(
                  "${AppStrings.minParticipants}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: _participantsCount,
                    min: AppStrings.minParticipants.toDouble(),
                    max: AppStrings.maxParticipants.toDouble(),
                    divisions:
                        (AppStrings.maxParticipants -
                        AppStrings.minParticipants),
                    label: _participantsCount.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _participantsCount = value;
                      });
                    },
                  ),
                ),
                Text(
                  "${AppStrings.maxParticipants}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.votingOptions,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.s),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.blankVotes),
                    secondary: const Icon(Icons.check_box_outline_blank),
                    value: _showBlankVotes,
                    onChanged: (value) =>
                        setState(() => _showBlankVotes = value),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text(l10n.spoiledVotes),
                    secondary: const Icon(Icons.block),
                    value: _showNullVotes,
                    onChanged: (value) =>
                        setState(() => _showNullVotes = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildRulesSection(context),
            // P10: queste impostazioni anche per i nuovi scrutini.
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.useAsDefaults),
              subtitle: Text(l10n.useAsDefaultsHint),
              value: _useAsDefaults,
              onChanged: (v) => setState(() => _useAsDefaults = v),
            ),

            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.s),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: 'system',
                  label: Text(l10n.languageSystem),
                  icon: const Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(value: 'it', label: Text(l10n.languageItalian)),
                ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
              ],
              selected: {_localeKey(localeProvider.locale)},
              onSelectionChanged: (selection) {
                final value = selection.first;
                final provider = context.read<LocaleProvider>();
                provider.setLocale(value == 'system' ? null : Locale(value));
              },
            ),

            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.appearance,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.s),
            SwitchListTile(
              title: Text(l10n.useSystemColors),
              subtitle: Text(l10n.useSystemColorsSubtitle),
              secondary: const Icon(Icons.palette_outlined),
              value: context.watch<AppearanceProvider>().useSystemColors,
              onChanged: (value) =>
                  context.read<AppearanceProvider>().setUseSystemColors(value),
            ),

            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.dataManagement,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.s),

            // Using OutlinedButtons for secondary actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: Text(l10n.exportLabel),
                    onPressed: () async {
                      final provider = context.read<ScrutinyProvider>();
                      await ConfigurationService.exportConfiguration(
                        provider.candidates,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(l10n.importLabel),
                    onPressed: () async {
                      final scrutiny = context.read<ScrutinyProvider>();
                      final messenger = ScaffoldMessenger.of(context);
                      final loadedMsg = l10n.configLoaded;
                      final candidates =
                          await ConfigurationService.importConfiguration();
                      if (candidates != null && context.mounted) {
                        Navigator.pop(context); // Close dialog
                        scrutiny.loadConfiguration(candidates);
                        messenger.showSnackBar(
                          SnackBar(content: Text(loadedMsg)),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            // P10: lista riusabile per i prossimi scrutini.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.playlist_add),
                label: Text(l10n.saveAsList),
                onPressed: () => _saveAsList(context),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton.tonal(
          // Tonal button for save
          onPressed: () {
            final int voters = int.tryParse(_totalVotersController.text) ?? 100;
            final newSettings = Settings(
              totalVoters: voters,
              participantsCount: _participantsCount.toInt(),
              showBlankVotes: _showBlankVotes,
              showNullVotes: _showNullVotes,
              victoryRule: _rule,
              eligibleVoters: _quorumOn
                  ? int.tryParse(_eligibleController.text)
                  : null,
              quorumPercent: _quorumOn
                  ? int.tryParse(_quorumController.text)?.clamp(1, 100)
                  : null,
            );

            final provider = context.read<ScrutinyProvider>();
            final useAsDefaults = _useAsDefaults;
            final hadDefaults = provider.defaultSettings != null;
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
            Future.delayed(const Duration(milliseconds: 150), () {
              try {
                provider.updateSettings(newSettings);
                if (useAsDefaults) {
                  provider.setDefaultSettingsFromCurrent();
                } else if (hadDefaults) {
                  provider.setDefaultSettingsFromCurrent(clear: true);
                }
              } catch (e) {
                debugPrint("Error saving settings: $e");
              }
            });
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _saveAsList(BuildContext context) async {
    final l10n = context.l10n;
    final provider = context.read<ScrutinyProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _ListNameDialog(),
    );
    if (name == null || name.trim().isEmpty) return;
    await provider.saveCandidateList(name);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.listSaved(name.trim()))),
    );
  }

  /// FEAT-005: regola di vittoria e quorum di affluenza.
  Widget _buildRulesSection(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.victoryRuleTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.s),
        SegmentedButton<VictoryRule>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: VictoryRule.plurality,
              label: Text(l10n.rulePlurality),
            ),
            ButtonSegment(
              value: VictoryRule.absoluteMajority,
              label: Text(l10n.ruleAbsoluteMajority),
            ),
          ],
          selected: {_rule},
          onSelectionChanged: (s) => setState(() => _rule = s.first),
        ),
        if (_rule == VictoryRule.absoluteMajority)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            child: Text(
              l10n.ruleAbsoluteMajorityHint,
              style: textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: AppSpacing.s),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.quorumTitle),
          subtitle: Text(l10n.quorumSubtitle),
          value: _quorumOn,
          onChanged: (v) => setState(() => _quorumOn = v),
        ),
        if (_quorumOn)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  key: const ValueKey('eligibleVoters'),
                  controller: _eligibleController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.eligibleVotersLabel,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                flex: 2,
                child: TextField(
                  key: const ValueKey('quorumPercent'),
                  controller: _quorumController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.quorumPercentLabel,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _localeKey(Locale? locale) =>
      locale == null ? 'system' : locale.languageCode;
}

/// Nome della lista da salvare. Possiede il proprio controller: viene liberato
/// solo a fine animazione di chiusura (vedi il crash di Modifica nome).
class _ListNameDialog extends StatefulWidget {
  const _ListNameDialog();

  @override
  State<_ListNameDialog> createState() => _ListNameDialogState();
}

class _ListNameDialogState extends State<_ListNameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.saveAsList),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.listNameLabel),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
