import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta usada no estilo "dark-gothic" do cabeçalho e dos campos de busca.
class GothicPalette {
  const GothicPalette._();

  static const background = Color(0xFF0B0A0D);
  static const surface = Color(0xFF17141A);
  static const crimson = Color(0xFF7A1F2B);
  static const gold = Color(0xFFC6A664);
  static const parchment = Color(0xFFE8E1D3);
}

final gothicAppBarTheme = AppBarTheme(
  backgroundColor: GothicPalette.background,
  foregroundColor: GothicPalette.gold,
  elevation: 0,
  centerTitle: true,
  systemOverlayStyle: SystemUiOverlayStyle.light,
  iconTheme: const IconThemeData(color: GothicPalette.gold),
  titleTextStyle: const TextStyle(
    color: GothicPalette.gold,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 3,
    fontFamily: 'serif',
  ),
);

final gothicInputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: GothicPalette.surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  hintStyle: TextStyle(
    color: GothicPalette.parchment.withValues(alpha: 0.5),
    fontStyle: FontStyle.italic,
  ),
  prefixIconColor: GothicPalette.gold,
  suffixIconColor: GothicPalette.gold,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: GothicPalette.crimson, width: 1.2),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: GothicPalette.crimson, width: 1.2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: GothicPalette.gold, width: 1.6),
  ),
);

/// Linha ornamentada usada sob o AppBar para reforçar o estilo gótico.
class GothicDivider extends StatelessWidget implements PreferredSizeWidget {
  const GothicDivider({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            GothicPalette.gold,
            GothicPalette.crimson,
            GothicPalette.gold,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
