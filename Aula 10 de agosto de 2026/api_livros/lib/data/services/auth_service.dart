import 'package:firebase_auth/firebase_auth.dart';

/// Camada fina sobre o Firebase Authentication (email/senha).
///
/// Repassa as chamadas do SDK sem interpretá-las: a tradução de erros e a
/// exposição para a UI ficam no [AuthRepository].
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
}
