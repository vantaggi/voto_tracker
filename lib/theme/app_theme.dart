import 'package:flutter/material.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class AppTheme {
  // Modern Palette
  static const Color primaryViolet = Color(0xFF6366F1); // Indigo
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondaryTeal = Color(0xFF14B8A6);
  static const Color accentRose = Color(0xFFF43F5E);
  
  static const Color backgroundLight = Color(0xFFF1F5F9); // Slate-100
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A); // Slate-900
  static const Color textLight = Color(0xFF64748B); // Slate-500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate-200

  static const Color backgroundDark = Color(0xFF0F172A); // Slate-900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate-800
  static const Color textWhite = Color(0xFFF8FAFC); // Slate-50
  static const Color textGrey = Color(0xFF94A3B8); // Slate-400
  static const Color borderDark = Color(0xFF334155); // Slate-700

  static TextTheme _buildLightTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          fontSize: 80, fontWeight: FontWeight.bold, color: textDark, letterSpacing: -2),
      displayMedium: base.displayMedium?.copyWith(
          fontSize: 48, fontWeight: FontWeight.bold, color: textDark, letterSpacing: -1),
      displaySmall: base.displaySmall?.copyWith(
          fontSize: 36, fontWeight: FontWeight.bold, color: textDark),
      headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 30, fontWeight: FontWeight.w600, color: textDark),
      headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w600, color: textDark),
      titleLarge: base.titleLarge?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w700, color: textDark),
      titleMedium: base.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, color: textDark, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, color: textDark, height: 1.5),
      labelLarge: base.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w700, color: primaryViolet),
      labelSmall: base.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w600, color: textLight),
    );
  }

  static TextTheme _buildDarkTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          fontSize: 80, fontWeight: FontWeight.bold, color: textWhite, letterSpacing: -2),
      displayMedium: base.displayMedium?.copyWith(
          fontSize: 48, fontWeight: FontWeight.bold, color: textWhite, letterSpacing: -1),
      displaySmall: base.displaySmall?.copyWith(
          fontSize: 36, fontWeight: FontWeight.bold, color: textWhite),
      headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 30, fontWeight: FontWeight.w600, color: textWhite),
      headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w600, color: textWhite),
      titleLarge: base.titleLarge?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w700, color: textWhite),
      titleMedium: base.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: textWhite),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, color: textWhite, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, color: textWhite, height: 1.5),
      labelLarge: base.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w700, color: primaryViolet),
      labelSmall: base.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w600, color: textGrey),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryViolet,
      brightness: Brightness.light,
      surface: surfaceWhite,
      primary: primaryViolet,
      secondary: secondaryTeal,
      tertiary: accentRose,
      onSurface: textDark,
      surfaceContainerHighest: const Color(0xFFE2E8F0), 
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: textDark, fontSize: 24, fontWeight: FontWeight.w800)),
    cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: borderLight, width: 1.5),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusCard))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryViolet,
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusButton)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16))),
    dialogTheme: DialogThemeData(
        backgroundColor: surfaceWhite,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCard)),
        titleTextStyle: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w700, color: textDark)),
    iconTheme: const IconThemeData(color: textDark),
    textTheme: _buildLightTextTheme(Typography.material2021().black),
    dividerColor: borderLight,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryViolet,
      brightness: Brightness.dark,
      surface: surfaceDark,
      primary: primaryViolet,
      secondary: secondaryTeal,
      tertiary: accentRose,
      onSurface: textWhite,
      surfaceContainerHighest: const Color(0xFF334155),
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: textWhite, fontSize: 24, fontWeight: FontWeight.w800)),
    cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: borderDark, width: 1.5),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusCard))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryViolet,
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusButton)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16))),
    dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCard)),
        titleTextStyle: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w700, color: textWhite)),
    iconTheme: const IconThemeData(color: textWhite),
    textTheme: _buildDarkTextTheme(Typography.material2021().white),
    dividerColor: borderDark,
  );
}
