import 'package:material_ui/material_ui.dart';

/// Colori semantici per l'andamento rispetto allo scrutinio precedente
/// (swing): verde per la crescita, il ruolo `error` del tema per il calo.
/// Il verde è HCT tinta 145, croma 60, tono 40 (light) / 80 (dark): stessa
/// logica dei toni M3 per un colore "on surface" leggibile in entrambi i temi.
@immutable
class TrendColors extends ThemeExtension<TrendColors> {
  const TrendColors({required this.positive, required this.negative});

  final Color positive;
  final Color negative;

  factory TrendColors.forScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return TrendColors(
      positive: dark ? const Color(0xFF7DDC77) : const Color(0xFF006E17),
      negative: scheme.error,
    );
  }

  /// I colori del tema corrente; se il tema non li registra, li ricava dallo
  /// schema colori (utile nei test con temi minimi).
  static TrendColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<TrendColors>() ??
        TrendColors.forScheme(theme.colorScheme);
  }

  @override
  TrendColors copyWith({Color? positive, Color? negative}) => TrendColors(
    positive: positive ?? this.positive,
    negative: negative ?? this.negative,
  );

  @override
  TrendColors lerp(TrendColors? other, double t) {
    if (other == null) return this;
    return TrendColors(
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
    );
  }
}
