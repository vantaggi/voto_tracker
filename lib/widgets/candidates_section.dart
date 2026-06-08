import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/widgets/candidate_card.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';

class CandidatesSection extends StatelessWidget {
  final bool isScrollable;

  const CandidatesSection({super.key, this.isScrollable = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Stats Header
            const StatsHeader(),

            // List
            if (isScrollable)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: provider.candidates.length,
                  itemBuilder: (context, index) {
                    return CandidateCard(
                        index: index, candidate: provider.candidates[index]);
                  },
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.candidates.length,
                itemBuilder: (context, index) {
                  return CandidateCard(
                      index: index, candidate: provider.candidates[index]);
                },
              ),
            
            // Control Buttons
            const ControlButtons(),
          ],
        );
      },
    );
  }
}

class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (provider.hasWinner)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: provider.isTie
                    ? colorScheme.tertiaryContainer 
                    : colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: Column(
                children: [
                   Text(
                      localizedWinnerLabel(l10n, provider.winnerStatus) ?? '',
                      style: TextStyle(
                          color: provider.isTie
                              ? colorScheme.onTertiaryContainer
                              : colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2
                      ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                      (provider.isTie ? l10n.tie : (provider.winnerName ?? '')).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: provider.isTie
                              ? colorScheme.onTertiaryContainer 
                              : colorScheme.onPrimaryContainer,
                          height: 1.1
                      ),
                   ),
                ],
              ),
            ),

          // Main Stats Card
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, Icons.how_to_vote_outlined, l10n.scrutinisedVotes,
                      '${provider.totalVotesAssigned} / ${provider.settings.totalVoters}'),
                  Container(height: 48, width: 1, color: colorScheme.outlineVariant),
                  _buildStatItem(context, Icons.pending_outlined, l10n.remaining,
                      '${provider.remainingVotes}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Comparison Info
          _buildComparisonInfo(context, provider),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
      final colorScheme = Theme.of(context).colorScheme;
      return Column(
          children: [
              Icon(icon, color: colorScheme.primary, size: 28),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
      );
  }
  
  Widget _buildComparisonInfo(BuildContext context, ScrutinyProvider provider) {
      if (provider.votesUntilMajority == null || provider.remainingVotes <= 0) return const SizedBox.shrink();
      
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant)
          ),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                      context.l10n.votesToWin(provider.votesUntilMajority ?? 0),
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)
                  )
              ],
          )
      );
  }
}

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Undo / Redo
            Row(
              children: [
                IconButton( // Replaced IconButton.tonal
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                  ),
                  icon: const Icon(Icons.undo),
                  onPressed: provider.canUndo ? () {
                      HapticFeedback.mediumImpact();
                      provider.undo();
                  } : null,
                  tooltip: context.l10n.undoTooltip,
                ),
                const SizedBox(width: 8),
                IconButton( // Replaced IconButton.tonal
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                  ),
                  icon: const Icon(Icons.redo),
                  onPressed: provider.canRedo ? () {
                      HapticFeedback.mediumImpact();
                      provider.redo();
                  } : null,
                  tooltip: context.l10n.redoTooltip,
                ),
              ],
            ),

            // Reset (Hold to delete) — Flexible così la label lunga (es. in
            // italiano) si comprime invece di mandare la Row in overflow.
            Flexible(
              child: _HoldToResetButton(onReset: () {
                   provider.reset();
                   HapticFeedback.heavyImpact();
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldToResetButton extends StatefulWidget {
  final VoidCallback onReset;
  const _HoldToResetButton({required this.onReset});

  @override
  State<_HoldToResetButton> createState() => _HoldToResetButtonState();
}

class _HoldToResetButtonState extends State<_HoldToResetButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onReset();
        _controller.reset();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onLongPressDown: (_) => _controller.forward(),
      onLongPressEnd: (_) => _controller.reverse(),
      child: Stack(
        alignment: Alignment.center,
        children: [
           // Background container
           Container(
             height: 48,
             decoration: BoxDecoration(
               color: colorScheme.errorContainer,
               borderRadius: BorderRadius.circular(24), // Stadium
             ),
             padding: const EdgeInsets.symmetric(horizontal: 20),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(Icons.delete_forever, color: colorScheme.error),
                 const SizedBox(width: 8),
                 Flexible(
                   child: Text(
                     context.l10n.resetButton,
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
                   ),
                 )
               ],
             )
           ),
           // Fill animation (clipped)
           Positioned.fill(
             child: ClipRRect(
               borderRadius: BorderRadius.circular(24),
               child: AnimatedBuilder(
                 animation: _controller,
                 builder: (context, child) {
                   return FractionallySizedBox(
                     widthFactor: _controller.value,
                     alignment: Alignment.centerLeft,
                     child: Container(
                       color: colorScheme.error.withValues(alpha: 0.3),
                     ),
                   );
                 },
               ),
             ),
           )
        ],
      )
    );
  }
}
