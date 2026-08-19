import 'package:api_livros/data/repositories/auth_repository.dart';
import 'package:api_livros/ui/auth/view/login_screen.dart';
import 'package:api_livros/utils/result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dublê do repositório de autenticação. Antes da refatoração a tela chamava
/// `AuthService()` direto no `State`, e o teste não tinha como interceptar o
/// login — só dava para verificar que os campos apareciam.
class _FakeAuthRepository implements AuthRepository {
  final List<({String email, String password})> signInCalls = [];
  String? failureMessage;

  @override
  Stream<User?> get authStateChanges => Stream<User?>.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls.add((email: email, password: password));
    final message = failureMessage;
    return message != null ? Failure(message) : const Ok(null);
  }

  @override
  Future<Result<void>> register({
    required String name,
    required String email,
    required String password,
  }) async => const Ok(null);

  @override
  Future<void> signOut() async {}
}

void main() {
  late _FakeAuthRepository authRepository;

  setUp(() => authRepository = _FakeAuthRepository());

  Widget buildSubject() =>
      MaterialApp(home: LoginScreen(authRepository: authRepository));

  testWidgets('exibe os campos de e-mail e senha', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Catálogo de Livros'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Não tem conta? Criar conta'), findsOneWidget);
  });

  testWidgets('não chama o login quando o formulário é inválido', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(authRepository.signInCalls, isEmpty);
    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
  });

  testWidgets('envia as credenciais preenchidas ao repositório', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'leitor@exemplo.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'segredo123',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(authRepository.signInCalls, [
      (email: 'leitor@exemplo.com', password: 'segredo123'),
    ]);
  });

  testWidgets('mostra a mensagem de erro devolvida pelo repositório', (
    tester,
  ) async {
    authRepository.failureMessage = 'E-mail ou senha incorretos.';
    await tester.pumpWidget(buildSubject());

    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'leitor@exemplo.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'errada',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
  });
}
