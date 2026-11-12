import 'package:material_ui/material_ui.dart';
import 'package:voto_tracker/utils/app_constants.dart';

/// Spazio tra le fette della barra impilata.
const double _segmentGap = 2;

/// Una fetta della barra: colore e voti.
typedef BarSegment = ({Color color, int votes});

/// Barra impilata (Home, Archivio, Proiettore): una fetta per riga, lunga
/// quanto la sua quota di [total]; il resto, se c'è, è grigio.
///
/// [segments] va passato già nell'ordine voluto (di solito classifica, poi
/// bianche e nulle). Le fette a zero voti non si disegnano.
class VoteStackedBar extends StatelessWidget {
  const VoteStackedBar({
    super.key,
    required this.segments,
    required this.total,
    this.height = 12,
    this.restColor,
  });

  final List<BarSegment> segments;
  final int total;
  final double height;

  /// Colore della parte non ancora contata.
  final Color? restColor;

  @override
  Widget build(BuildContext context) {
    final shown = segments.where((s) => s.votes > 0).toList();
    final counted = shown.fold<int>(0, (sum, s) => sum + s.votes);
    final rest = (total - counted).clamp(0, total);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppShapes.small),
        child: SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, s) in shown.indexed) ...[
                Expanded(
                  flex: s.votes,
                  child: ColoredBox(color: s.color),
                ),
                if (i < shown.length - 1 || rest > 0)
                  const SizedBox(width: _segmentGap),
              ],
              if (rest > 0)
                Expanded(
                  flex: rest,
                  child: ColoredBox(
                    color:
                        restColor ??
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
