// NOVO ARQUIVO: lib/pages/reset_password_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      // Usa a sessão de recuperação ativa para atualizar o usuário
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Senha redefinida com sucesso! Por favor, faça o login novamente.',
            ),
          ),
        );
        // Após o sucesso, desloga o usuário e o envia para a tela de login
        await supabase.auth.signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao redefinir senha: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redefinir Senha')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Digite sua nova senha abaixo.',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Nova Senha'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6)
                        return 'A senha deve ter no mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Nova Senha',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text)
                        return 'As senhas não coincidem';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _resetPassword,
                      child: const Text('Salvar Nova Senha'),
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
