import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste a preferência de tema do usuário no armazenamento local.
///
/// Guarda o `ThemeMode` como string (`system`/`light`/`dark`) em vez do índice
/// do enum: reordenar o enum do Flutter no futuro não corrompe o valor salvo.
class ThemePreferenceService {
  static const _key = 'theme_mode';

  final SharedPreferences _preferences;

  const ThemePreferenceService(this._preferences);

  ThemeMode read() {
    final stored = _preferences.getString(_key);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> write(ThemeMode mode) {
    return _preferences.setString(_key, mode.name);
  }
}
