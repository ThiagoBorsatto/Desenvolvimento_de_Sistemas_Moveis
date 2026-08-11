import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'catalog_screen.dart';
import 'login_screen.dart';

/// Mostra o catálogo quando há um usuário autenticado, ou a tela de login
/// caso contrário. Reage automaticamente a login/logout via [authStateChanges].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: GothicPalette.background,
            body: Center(
              child: CircularProgressIndicator(color: GothicPalette.gold),
            ),
          );
        }
        if (snapshot.hasData) {
          return const CatalogScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
