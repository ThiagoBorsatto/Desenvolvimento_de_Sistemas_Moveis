import 'package:flutter/material.dart';

import '../../../data/repositories/theme_repository.dart';

/// Estado do tema do app (claro / escuro / seguir o sistema).
///
/// Vive acima do `MaterialApp` e é o único ponto que decide qual `ThemeData`
/// está em uso, então qualquer tela pode alternar o tema sem repassar callbacks
/// pela árvore inteira.
class ThemeViewModel extends ChangeNotifier {
  final ThemeRepository _repository;

  late ThemeMode _themeMode;

  ThemeViewModel(this._repository) {
    _themeMode = _repository.load();
  }

  ThemeMode get themeMode => _themeMode;

  /// Inverte o tema em relação ao que está sendo exibido agora.
  ///
  /// [currentBrightness] é o brilho efetivo na tela (`Theme.of(context)
  /// .brightness`). Passá-lo importa quando o modo é [ThemeMode.system]: sem
  /// ele, o primeiro toque poderia "alternar" para o tema que já estava ativo.
  Future<void> toggle(Brightness currentBrightness) {
    return setThemeMode(
      currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _repository.save(mode);
  }
}
