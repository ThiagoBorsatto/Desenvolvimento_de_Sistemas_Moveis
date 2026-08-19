import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/book_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/book_api_service.dart';
import 'firebase_options.dart';
import 'ui/auth/view/auth_gate.dart';
import 'ui/core/themes/app_theme.dart';

/// Composition root: é o único lugar do app que sabe quais implementações
/// concretas existem. Daqui para baixo tudo trafega pelas interfaces
/// (`AuthRepository`, `BookRepository`), o que permite trocar a fonte de dados
/// ou usar dublês nos testes sem tocar nas telas.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MyApp(
      authRepository: AuthRepositoryFirebase(AuthService()),
      bookRepository: BookRepositoryRemote(BookApiService()),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final BookRepository bookRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.bookRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Livros',
      theme: buildAppTheme(),
      home: AuthGate(
        authRepository: authRepository,
        bookRepository: bookRepository,
      ),
    );
  }
}
