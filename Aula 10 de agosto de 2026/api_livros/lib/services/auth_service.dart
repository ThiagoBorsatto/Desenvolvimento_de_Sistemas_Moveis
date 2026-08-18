import 'package:firebase_auth/firebase_auth.dart';

/// Camada fina sobre o Firebase Authentication (email/senha).
class AuthService {
  // Getter (não `final` avaliado no construtor) para que instanciar
  // AuthService não exija Firebase.initializeApp() já ter rodado —
  // importante para testes de widget que renderizam a tela sem autenticar.
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (name.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(name.trim());
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Traduz erros do Firebase Auth para mensagens amigáveis em português.
  String friendlyError(Object error) {
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
