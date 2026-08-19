import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/book_repository.dart';
import '../../catalog/view/catalog_screen.dart';
import '../../core/view_model/theme_view_model.dart';
import 'login_screen.dart';

/// Mostra o catálogo quando há um usuário autenticado, ou a tela de login
/// caso contrário. Reage automaticamente a login/logout via [authStateChanges].
///
/// É também o ponto onde as dependências criadas no `main()` são repassadas
/// para as telas — a injeção é manual, por construtor, sem container mágico.
class AuthGate extends StatelessWidget {
  final AuthRepository authRepository;
  final BookRepository bookRepository;
  final ThemeViewModel themeViewModel;

  const AuthGate({
    super.key,
    required this.authRepository,
    required this.bookRepository,
    required this.themeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return CatalogScreen(
            bookRepository: bookRepository,
            authRepository: authRepository,
            themeViewModel: themeViewModel,
          );
        }
        return LoginScreen(
          authRepository: authRepository,
          themeViewModel: themeViewModel,
        );
      },
    );
  }
}
