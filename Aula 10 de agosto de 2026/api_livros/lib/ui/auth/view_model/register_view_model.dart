import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../utils/result.dart';

/// Estado do formulário de criação de conta.
class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  RegisterViewModel(this._repository);

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Retorna `true` quando a conta foi criada, para a view desempilhar a tela.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
    );

    _isSubmitting = false;
    switch (result) {
      case Ok():
        _errorMessage = null;
      case Failure(:final message):
        _errorMessage = message;
    }
    notifyListeners();

    return result is Ok;
  }
}
