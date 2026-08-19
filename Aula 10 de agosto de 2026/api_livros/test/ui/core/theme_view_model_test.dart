import 'package:api_livros/data/repositories/theme_repository.dart';
import 'package:api_livros/ui/core/view_model/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositório em memória, no lugar do shared_preferences.
class _FakeThemeRepository implements ThemeRepository {
  ThemeMode stored;

  _FakeThemeRepository([this.stored = ThemeMode.system]);

  @override
  ThemeMode load() => stored;

  @override
  Future<void> save(ThemeMode mode) async => stored = mode;
}

void main() {
  test('lê a preferência salva na criação', () {
    final viewModel = ThemeViewModel(_FakeThemeRepository(ThemeMode.dark));

    expect(viewModel.themeMode, ThemeMode.dark);
  });

  test('alternar a partir do modo sistema usa o brilho em tela', () async {
    final repository = _FakeThemeRepository();
    final viewModel = ThemeViewModel(repository);

    // Modo "sistema" exibindo o tema escuro: o toque deve levar ao claro, e
    // não ao escuro que já estava na tela.
    await viewModel.toggle(Brightness.dark);

    expect(viewModel.themeMode, ThemeMode.light);
    expect(repository.stored, ThemeMode.light);
  });

  test('alternar de volta persiste o modo escuro', () async {
    final repository = _FakeThemeRepository(ThemeMode.light);
    final viewModel = ThemeViewModel(repository);

    await viewModel.toggle(Brightness.light);

    expect(viewModel.themeMode, ThemeMode.dark);
    expect(repository.stored, ThemeMode.dark);
  });

  test('notifica os ouvintes ao trocar de tema', () async {
    final viewModel = ThemeViewModel(_FakeThemeRepository());
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.setThemeMode(ThemeMode.dark);
    // Repetir o mesmo modo não deve gerar reconstrução.
    await viewModel.setThemeMode(ThemeMode.dark);

    expect(notifications, 1);
  });
}
