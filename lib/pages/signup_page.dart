// ARQUIVO ATUALIZADO E RESPONSIVO: lib/pages/signup_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'full_name': _fullNameController.text.trim()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cadastro realizado! Verifique seu e-mail para confirmar.',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        // Adicionamos um Center para garantir a centralização vertical e horizontal
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
          // --- A MÁGICA DA RESPONSIVIDADE ACONTECE AQUI ---
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ), // Limita a largura máxima
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Crie sua Conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preencha seus dados para começar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: lightTextColor, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome Completo',
                            ),
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'Campo obrigatório'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => (value?.isEmpty ?? true)
                                ? 'Campo obrigatório'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                            ),
                            obscureText: true,
                            validator: (value) =>
                                (value == null || value.length < 6)
                                ? 'A senha deve ter no mínimo 6 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar Senha',
                            ),
                            obscureText: true,
                            validator: (value) =>
                                (value != _passwordController.text)
                                ? 'As senhas não coincidem'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            ElevatedButton(
                              onPressed: _signUp,
                              child: const Text('Cadastrar'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
