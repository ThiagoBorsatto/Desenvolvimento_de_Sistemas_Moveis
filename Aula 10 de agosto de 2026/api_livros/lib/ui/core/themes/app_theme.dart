import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Conjunto de cores de uma variante do tema.
///
/// As duas variantes usam os mesmos papéis (fundo, superfície, borda, acento…)
/// e o mesmo acento violeta; só mudam os valores. Assim o app inteiro é
/// construído uma única vez em [AppTheme._build] e nenhuma tela precisa saber
/// se está no claro ou no escuro — basta ler o `ColorScheme`.
class AppPalette {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color accent;
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
  });

  /// Cinza-chumbo neutro (sem preto puro) com acento violeta.
  static const dark = AppPalette(
    background: Color(0xFF121214),
    surface: Color(0xFF1B1B1F),
    surfaceElevated: Color(0xFF232329),
    border: Color(0xFF2C2C33),
    accent: Color(0xFF7C6FF0),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFF4F4F6),
    textSecondary: Color(0xFF9A9AA6),
    error: Color(0xFFEF6461),
  );

  /// Contraparte clara: fundo levemente acinzentado (não branco puro) para os
  /// cards brancos continuarem se destacando, e um violeta um pouco mais
  /// escuro que o da variante escura para manter o contraste do texto sobre o
  /// acento acima de 4.5:1.
  static const light = AppPalette(
    background: Color(0xFFF6F6F9),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEDEDF3),
    border: Color(0xFFE1E1EA),
    accent: Color(0xFF5B4CDB),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF16161A),
    textSecondary: Color(0xFF62626F),
    error: Color(0xFFC53434),
  );
}

/// Temas claro e escuro do app.
abstract final class AppTheme {
  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: palette.accent,
          brightness: brightness,
        ).copyWith(
          primary: palette.accent,
          onPrimary: palette.onAccent,
          surface: palette.surface,
          onSurface: palette.textPrimary,
          surfaceContainerHighest: palette.surfaceElevated,
          onSurfaceVariant: palette.textSecondary,
          outline: palette.border,
          error: palette.error,
        );

    final textTheme = GoogleFonts.manropeTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: palette.textPrimary, displayColor: palette.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        // Ícones da barra de status: claros sobre o tema escuro, escuros sobre
        // o claro. Trocar junto com o tema evita ícones brancos em fundo claro.
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.accent,
        side: BorderSide(color: palette.border),
        labelStyle: textTheme.labelLarge?.copyWith(color: palette.textPrimary),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: palette.onAccent,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: palette.textSecondary),
        labelStyle: TextStyle(color: palette.textSecondary),
        prefixIconColor: palette.textSecondary,
        suffixIconColor: palette.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.error, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.border),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: palette.accent),
      ),
      iconTheme: IconThemeData(color: palette.textSecondary),
      dividerColor: palette.border,
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.accent),
    );
  }
}
