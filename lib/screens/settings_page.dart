import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/models/settings.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/screens/app_settings_page.dart';
import 'package:voto_tracker/services/configuration_service.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Larghezza del campo numerico tra − e +.
const double _stepperFieldWidth = 88;

/// Votanti massimi accettati dal contatore.
const int _maxVoters = 100000;

/// Impostazioni dello scrutinio (S2): pagina intera sul telefono, finestra di
/// 560dp sul tablet (vedi `HomeActions.openSettings`). Tre gruppi: schede e
/// candidati, regole, liste. Lingua e aspetto stanno in [AppSettingsPage].
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _votersController;
  late final TextEditingController _candidatesController;
  late bool _showBlankVotes;
  late bool _showNullVotes;
  late VictoryRule _rule;
  late bool _quorumOn;
  late final TextEditingController _eligibleController;
  late final TextEditingController _quorumController;
  late bool _useAsDefaults;
  late final Settings _initial;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ScrutinyProvider>();
    final settings = provider.settings;
    _initial = settings;
    _useAsDefaults = provider.defaultSettings != null;
    _votersController = TextEditingController(
      text: settings.totalVoters.toString(),
    );
    _candidatesController = TextEditingController(
      text: settings.participantsCount.toString(),
    );
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
    _votersController.dispose();
    _candidatesController.dispose();
    _eligibleController.dispose();
    _quorumController.dispose();
    super.dispose();
  }

  int get _voters =>
      (int.tryParse(_votersController.text) ?? _initial.totalVoters).clamp(
        1,
        _maxVoters,
      );

  int get _candidates =>
      (int.tryParse(_candidatesController.text) ?? _initial.participantsCount)
          .clamp(AppStrings.minParticipants, AppStrings.maxParticipants);

  /// Le impostazioni come sono ora nel modulo.
  Settings _pendingSettings() => Settings(
    totalVoters: _voters,
    participantsCount: _candidates,
    showBlankVotes: _showBlankVotes,
    showNullVotes: _showNullVotes,
    victoryRule: _rule,
    eligibleVoters: _quorumOn ? int.tryParse(_eligibleController.text) : null,
    quorumPercent: _quorumOn
        ? int.tryParse(_quorumController.text)?.clamp(1, 100)
        : null,
  );

  void _save() {
    final newSettings = _pendingSettings();
    final provider = context.read<ScrutinyProvider>();
    final useAsDefaults = _useAsDefaults;
    final hadDefaults = provider.defaultSettings != null;
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
    // Si applica a chiusura avvenuta: la Home ricostruita non trova più la
    // pagina in mezzo all'animazione.
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // S1: avvisa prima di salvare se i voti contati si perderebbero.
    final lost = context.watch<ScrutinyProvider>().ballotsLostWith(
      _pendingSettings(),
    );
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(l10n.settingsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.m),
            child: FilledButton(
              style: lost > 0
                  ? FilledButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                    )
                  : null,
              onPressed: _save,
              child: Text(lost > 0 ? l10n.saveAndReset : l10n.save),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          children: [
            _GroupHeader(l10n.settingsGroupBallots),
            _NumberStepper(
              key: const ValueKey('votersStepper'),
              label: l10n.settingsVoters,
              hint: l10n.settingsVotersHint,
              controller: _votersController,
              min: 1,
              max: _maxVoters,
              onChanged: () => setState(() {}),
            ),
            _NumberStepper(
              key: const ValueKey('candidatesStepper'),
              label: l10n.settingsCandidates,
              hint: l10n.settingsCandidatesHint(
                AppStrings.minParticipants,
                AppStrings.maxParticipants,
              ),
              controller: _candidatesController,
              min: AppStrings.minParticipants,
              max: AppStrings.maxParticipants,
              onChanged: () => setState(() {}),
            ),
            SwitchListTile(
              title: Text(l10n.blankVotes),
              value: _showBlankVotes,
              onChanged: (value) => setState(() => _showBlankVotes = value),
            ),
            SwitchListTile(
              title: Text(l10n.spoiledVotes),
              value: _showNullVotes,
              onChanged: (value) => setState(() => _showNullVotes = value),
            ),
            if (lost > 0)
              Padding(
                key: const ValueKey('settingsResetWarning'),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.s,
                  AppSpacing.l,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: cs.error),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        l10n.settingsResetWarning(lost),
                        style: tt.bodyMedium?.copyWith(color: cs.error),
                      ),
                    ),
                  ],
                ),
              ),
            const _GroupDivider(),
            _GroupHeader(l10n.settingsGroupRules),
            _buildRulesSection(context),
            SwitchListTile(
              title: Text(l10n.useAsDefaults),
              subtitle: Text(l10n.useAsDefaultsHint),
              value: _useAsDefaults,
              onChanged: (v) => setState(() => _useAsDefaults = v),
            ),
            const _GroupDivider(),
            _GroupHeader(l10n.settingsGroupLists),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: Text(l10n.saveAsList),
              onTap: () => _saveAsList(context),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(l10n.listExportFile),
              onTap: () async {
                final provider = context.read<ScrutinyProvider>();
                await ConfigurationService.exportConfiguration(
                  provider.candidates,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(l10n.listImportFile),
              onTap: () async {
                final scrutiny = context.read<ScrutinyProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final loadedMsg = l10n.configLoaded;
                final candidates =
                    await ConfigurationService.importConfiguration();
                if (candidates != null && context.mounted) {
                  Navigator.pop(context);
                  scrutiny.loadConfiguration(candidates);
                  messenger.showSnackBar(SnackBar(content: Text(loadedMsg)));
                }
              },
            ),
            const _GroupDivider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.appSettingsTitle),
              subtitle: Text(l10n.appSettingsSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => AppSettingsPage.open(context),
            ),
          ],
        ),
      ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.victoryRuleTitle, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<VictoryRule>(
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
              ),
              if (_rule == VictoryRule.absoluteMajority)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s),
                  child: Text(
                    l10n.ruleAbsoluteMajorityHint,
                    style: textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        SwitchListTile(
          title: Text(l10n.quorumTitle),
          subtitle: Text(l10n.quorumSubtitle),
          value: _quorumOn,
          onChanged: (v) => setState(() => _quorumOn = v),
        ),
        if (_quorumOn)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              0,
              AppSpacing.l,
              AppSpacing.s,
            ),
            child: Row(
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
                      suffixText: '%',
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Titolo di un gruppo di impostazioni.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.s,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: AppSpacing.s),
    child: Divider(),
  );
}

/// Numero con − e + ai lati (S2): si tocca per cambiare di uno o si scrive.
class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int min;
  final int max;
  final VoidCallback onChanged;

  int get _value => int.tryParse(controller.text) ?? min;

  void _set(int v) {
    controller.text = v.clamp(min, max).toString();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final value = _value;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.titleMedium),
                Text(
                  hint,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton.outlined(
            tooltip: l10n.stepperDecrease(label),
            onPressed: value > min ? () => _set(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          const SizedBox(width: AppSpacing.s),
          SizedBox(
            width: _stepperFieldWidth,
            child: Semantics(
              label: label,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: tt.titleLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                decoration: const InputDecoration(isDense: true),
                onChanged: (_) => onChanged(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          IconButton.outlined(
            tooltip: l10n.stepperIncrease(label),
            onPressed: value < max ? () => _set(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
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
