import 'package:flutter/material.dart';

import '../services/theme_preference_service.dart';

/// Leitura e escrita da preferência de tema.
abstract class ThemeRepository {
  ThemeMode load();

  Future<void> save(ThemeMode mode);
}

/// Implementação apoiada no armazenamento local do dispositivo.
class ThemeRepositoryLocal implements ThemeRepository {
  final ThemePreferenceService _service;

  const ThemeRepositoryLocal(this._service);

  @override
  ThemeMode load() => _service.read();

  @override
  Future<void> save(ThemeMode mode) => _service.write(mode);
}
