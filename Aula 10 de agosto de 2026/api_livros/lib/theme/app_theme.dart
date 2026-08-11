import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta do tema escuro moderno do app: cinza-chumbo neutro (sem preto puro)
/// com um único acento violeta para ações e destaques.
class AppPalette {
  const AppPalette._();

  static const background = Color(0xFF121214);
  static const surface = Color(0xFF1B1B1F);
  static const surfaceElevated = Color(0xFF232329);
  static const border = Color(0xFF2C2C33);
  static const accent = Color(0xFF7C6FF0);
  static const textPrimary = Color(0xFFF4F4F6);
  static const textSecondary = Color(0xFF9A9AA6);
  static const error = Color(0xFFEF6461);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.accent,
    brightness: Brightness.dark,
  ).copyWith(
    surface: AppPalette.surface,
    onSurface: AppPalette.textPrimary,
    surfaceContainerHighest: AppPalette.surfaceElevated,
    onSurfaceVariant: AppPalette.textSecondary,
    outline: AppPalette.border,
    error: AppPalette.error,
  );

  final textTheme = GoogleFonts.manropeTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  ).apply(bodyColor: AppPalette.textPrimary, displayColor: AppPalette.textPrimary);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPalette.background,
    colorScheme: colorScheme,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.background,
      foregroundColor: AppPalette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      iconTheme: const IconThemeData(color: AppPalette.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppPalette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppPalette.border),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.surface,
      selectedColor: AppPalette.accent,
      side: const BorderSide(color: AppPalette.border),
      labelStyle: textTheme.labelLarge?.copyWith(color: AppPalette.textPrimary),
      secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      showCheckmark: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: AppPalette.textSecondary),
      labelStyle: const TextStyle(color: AppPalette.textSecondary),
      prefixIconColor: AppPalette.textSecondary,
      suffixIconColor: AppPalette.textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.accent, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPalette.error, width: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppPalette.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPalette.textPrimary,
        side: const BorderSide(color: AppPalette.border),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppPalette.accent),
    ),
    iconTheme: const IconThemeData(color: AppPalette.textSecondary),
    dividerColor: AppPalette.border,
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppPalette.accent),
  );
}
