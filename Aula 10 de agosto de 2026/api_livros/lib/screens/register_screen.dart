import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      // O AuthGate troca para o CatalogScreen ao ouvir o authStateChanges, mas
      // essa tela foi empilhada via Navigator.push por cima dele — sem o pop,
      // ficaria escondendo o catálogo já carregado por baixo.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      setState(() => _errorMessage = _authService.friendlyError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GothicPalette.background,
      appBar: AppBar(
        backgroundColor: GothicPalette.background,
        bottom: const GothicDivider(),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'CRIAR CONTA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: GothicPalette.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: GothicPalette.parchment),
                    cursorColor: GothicPalette.gold,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        (value ?? '').trim().isEmpty ? 'Informe seu nome.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: GothicPalette.parchment),
                    cursorColor: GothicPalette.gold,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Informe seu e-mail.';
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'E-mail inválido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: GothicPalette.parchment),
                    cursorColor: GothicPalette.gold,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').length < 6) {
                        return 'A senha precisa ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    style: const TextStyle(color: GothicPalette.parchment),
                    cursorColor: GothicPalette.gold,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Confirmar senha',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem.';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFE0889A)),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: GothicPalette.gold,
                        foregroundColor: GothicPalette.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: GothicPalette.background,
                              ),
                            )
                          : const Text(
                              'CRIAR CONTA',
                              style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
