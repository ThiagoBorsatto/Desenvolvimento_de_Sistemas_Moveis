import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/book_repository.dart';
import 'data/repositories/theme_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/book_api_service.dart';
import 'data/services/theme_preference_service.dart';
import 'firebase_options.dart';
import 'ui/auth/view/auth_gate.dart';
import 'ui/core/themes/app_theme.dart';
import 'ui/core/view_model/theme_view_model.dart';

/// Composition root: é o único lugar do app que sabe quais implementações
/// concretas existem. Daqui para baixo tudo trafega pelas interfaces
/// (`AuthRepository`, `BookRepository`, `ThemeRepository`), o que permite
/// trocar a fonte de dados ou usar dublês nos testes sem tocar nas telas.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final preferences = await SharedPreferences.getInstance();

  runApp(
    MyApp(
      authRepository: AuthRepositoryFirebase(AuthService()),
      bookRepository: BookRepositoryRemote(BookApiService()),
      themeViewModel: ThemeViewModel(
        ThemeRepositoryLocal(ThemePreferenceService(preferences)),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final BookRepository bookRepository;
  final ThemeViewModel themeViewModel;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.bookRepository,
    required this.themeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    // O ListenableBuilder aqui é o que faz o toggle de tema valer para o app
    // inteiro: ao alternar, só o MaterialApp e sua subárvore são reconstruídos.
    return ListenableBuilder(
      listenable: themeViewModel,
      builder: (context, _) => MaterialApp(
        title: 'Catálogo de Livros',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeViewModel.themeMode,
        home: AuthGate(
          authRepository: authRepository,
          bookRepository: bookRepository,
          themeViewModel: themeViewModel,
        ),
      ),
    );
  }
}
