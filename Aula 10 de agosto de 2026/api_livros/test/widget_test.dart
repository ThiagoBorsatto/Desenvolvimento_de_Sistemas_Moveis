import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:api_livros/screens/login_screen.dart';

void main() {
  // MyApp depende do Firebase.initializeApp(), chamado em main() antes do
  // runApp(). Como isso não roda em testes de widget, testamos a LoginScreen
  // isoladamente em vez de subir o app inteiro (que exigiria mockar o Firebase).
  testWidgets('Tela de login exibe os campos de e-mail e senha', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('CATÁLOGO DE LIVROS'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('Não tem conta? Criar conta'), findsOneWidget);
  });
}
