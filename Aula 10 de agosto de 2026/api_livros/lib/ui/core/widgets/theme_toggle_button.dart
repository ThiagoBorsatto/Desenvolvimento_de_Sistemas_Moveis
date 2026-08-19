import 'package:flutter/material.dart';

import '../view_model/theme_view_model.dart';

/// Botão de alternância de tema para a barra superior.
///
/// Mostra o ícone do tema para o qual o toque vai levar (lua quando está no
/// claro, sol quando está no escuro), que é a convenção usada pela maioria dos
/// apps — o ícone anuncia o destino, não o estado atual.
class ThemeToggleButton extends StatelessWidget {
  final ThemeViewModel viewModel;

  const ThemeToggleButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return IconButton(
      tooltip: isDark ? 'Usar tema claro' : 'Usar tema escuro',
      onPressed: () => viewModel.toggle(brightness),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          // A chave faz o AnimatedSwitcher enxergar a troca de ícone: sem ela
          // os dois Icon() seriam considerados o mesmo widget e nada animaria.
          key: ValueKey(isDark),
        ),
      ),
    );
  }
}
