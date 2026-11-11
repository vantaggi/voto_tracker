import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/utils/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/l10n/l10n_ext.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScrutinyProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
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
                IconButton(
                  // Replaced IconButton.tonal
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                  ),
                  icon: const Icon(Icons.undo),
                  onPressed: provider.canUndo
                      ? () {
                          HapticFeedback.mediumImpact();
                          provider.undo();
                        }
                      : null,
                  tooltip: context.l10n.undoTooltip,
                ),
                const SizedBox(width: AppSpacing.s),
                IconButton(
                  // Replaced IconButton.tonal
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                  ),
                  icon: const Icon(Icons.redo),
                  onPressed: provider.canRedo
                      ? () {
                          HapticFeedback.mediumImpact();
                          provider.redo();
                        }
                      : null,
                  tooltip: context.l10n.redoTooltip,
                ),
              ],
            ),

            // Reset (Hold to delete) — Flexible così la label lunga (es. in
            // italiano) si comprime invece di mandare la Row in overflow.
            Flexible(
              child: _HoldToResetButton(
                onReset: () {
                  provider.reset();
                  HapticFeedback.heavyImpact();
                },
              ),
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

class _HoldToResetButtonState extends State<_HoldToResetButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
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
            height: AppTouch.minTarget,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(
                AppShapes.extraLargeCard,
              ), // Stadium
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lPlus),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_forever, color: colorScheme.error),
                const SizedBox(width: AppSpacing.s),
                Flexible(
                  child: Text(
                    context.l10n.resetButton,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fill animation (clipped)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppShapes.extraLargeCard),
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
          ),
        ],
      ),
    );
  }
}
