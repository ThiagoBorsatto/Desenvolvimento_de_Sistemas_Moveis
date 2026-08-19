import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/result.dart';
import '../services/auth_service.dart';

/// Porta de entrada da autenticação para as ViewModels.
abstract class AuthRepository {
  Stream<User?> get authStateChanges;

  User? get currentUser;

  Future<Result<void>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}

/// Implementação sobre o Firebase Authentication.
///
/// É aqui que os códigos de erro do SDK viram mensagens em português: a UI
/// recebe apenas o texto pronto e não precisa conhecer `FirebaseAuthException`.
class AuthRepositoryFirebase implements AuthRepository {
  final AuthService _service;

  AuthRepositoryFirebase(this._service);

  @override
  Stream<User?> get authStateChanges => _service.authStateChanges;

  @override
  User? get currentUser => _service.currentUser;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _service.signIn(email: email, password: password);
      return const Ok(null);
    } on Exception catch (error) {
      return Failure(_friendlyError(error), cause: error);
    }
  }

  @override
  Future<Result<void>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _service.register(name: name, email: email, password: password);
      return const Ok(null);
    } on Exception catch (error) {
      return Failure(_friendlyError(error), cause: error);
    }
  }

  @override
  Future<void> signOut() => _service.signOut();

  /// Traduz erros do Firebase Auth para mensagens amigáveis em português.
  String _friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'user-disabled':
          return 'Esta conta foi desativada.';
        case 'user-not-found':
          return 'Nenhuma conta encontrada com esse e-mail.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou senha incorretos.';
        case 'email-already-in-use':
          return 'Já existe uma conta com esse e-mail.';
        case 'weak-password':
          return 'A senha precisa ter pelo menos 6 caracteres.';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente em instantes.';
        case 'network-request-failed':
          return 'Falha de conexão. Verifique sua internet.';
        default:
          return 'Não foi possível concluir. Tente novamente.';
      }
    }
    return 'Ocorreu um erro inesperado.';
  }
}
