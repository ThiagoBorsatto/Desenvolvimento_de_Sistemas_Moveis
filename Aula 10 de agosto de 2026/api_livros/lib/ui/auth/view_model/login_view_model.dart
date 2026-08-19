import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../utils/result.dart';

/// Estado do formulário de login.
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  LoginViewModel(this._repository);

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

  /// Retorna `true` quando a autenticação deu certo. A troca de tela em si é
  /// feita pelo `AuthGate`, que observa o `authStateChanges`.
  Future<bool> signIn({required String email, required String password}) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.signIn(email: email, password: password);

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
