import 'package:flutter/material.dart';
import 'package:voto_tracker/utils/app_constants.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryTeal = Color(0xFF059669);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color backgroundDark = Color(0xFF1E293B);
  static const Color surfaceDark = Color(0xFF334155);
  static const Color textWhite = Color(0xFFF8FAFC);
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF475569);

  static TextTheme _buildLightTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          fontSize: 96, fontWeight: FontWeight.w300, color: textDark),
      displayMedium: base.displayMedium?.copyWith(
          fontSize: 60, fontWeight: FontWeight.w400, color: textDark),
      displaySmall: base.displaySmall?.copyWith(
          fontSize: 48, fontWeight: FontWeight.w400, color: textDark),
      headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 34, fontWeight: FontWeight.w400, color: textDark),
      headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w400, color: textDark),
      titleLarge: base.titleLarge?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
      titleMedium: base.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w500, color: textDark),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, color: textDark),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, color: textDark),
      labelLarge: base.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, color: primaryBlue),
      labelSmall: base.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w400, color: textLight),
    );
  }

  static TextTheme _buildDarkTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          fontSize: 96, fontWeight: FontWeight.w300, color: textWhite),
      displayMedium: base.displayMedium?.copyWith(
          fontSize: 60, fontWeight: FontWeight.w400, color: textWhite),
      displaySmall: base.displaySmall?.copyWith(
          fontSize: 48, fontWeight: FontWeight.w400, color: textWhite),
      headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 34, fontWeight: FontWeight.w400, color: textWhite),
      headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w400, color: textWhite),
      titleLarge: base.titleLarge?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w600, color: textWhite),
      titleMedium: base.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w500, color: textWhite),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, color: textWhite),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, color: textWhite),
      labelLarge: base.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, color: primaryBlue),
      labelSmall: base.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w400, color: textGrey),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      surface: surfaceWhite,
      primary: primaryBlue,
      secondary: secondaryTeal,
      onSurface: textDark,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: textDark, fontSize: 20, fontWeight: FontWeight.w600)),
    cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusCard))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusButton)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12))),
    dialogTheme: DialogThemeData(
        backgroundColor: surfaceWhite,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCard)),
        titleTextStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: textDark)),
    iconTheme: const IconThemeData(color: textDark),
    textTheme: _buildLightTextTheme(Typography.material2021().black),
    dividerColor: borderLight,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      surface: surfaceDark,
      primary: primaryBlue,
      secondary: secondaryTeal,
      onSurface: textWhite,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: textWhite, fontSize: 20, fontWeight: FontWeight.w600)),
    cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusCard))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusButton)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12))),
    dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCard)),
        titleTextStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: textWhite)),
    iconTheme: const IconThemeData(color: textWhite),
    textTheme: _buildDarkTextTheme(Typography.material2021().white),
    dividerColor: borderDark,
  );
}
