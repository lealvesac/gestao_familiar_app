// ARQUIVO ATUALIZADO: lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  // --- NOVOS CONTROLLERS PARA A SENHA ---
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _getProfile() async {
    setState(() => _isLoading = true);
    try {
      _userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', _userId!)
          .single();

      if (mounted) {
        _usernameController.text = response['username'] ?? '';
        _fullNameController.text = response['full_name'] ?? '';
      }
    } catch (e) {
      //... (lidar com erro)
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();

    try {
      await supabase
          .from('profiles')
          .update({
            'username': username,
            'full_name': fullName,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _userId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      }
    } catch (e) {
      //... (lidar com erro)
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- NOVA FUNÇÃO PARA ALTERAR A SENHA ---
  Future<void> _changePassword() async {
    // Valida apenas a parte da senha do formulário
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newPassword = _passwordController.text.trim();
    if (newPassword.isEmpty ||
        newPassword != _confirmPasswordController.text.trim()) {
      // Validação extra
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem ou estão vazias.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
        );
        _passwordController.clear();
        _confirmPasswordController.clear();
        FocusScope.of(context).unfocus(); // Esconde o teclado
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar senha: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const Text(
                    'Informações Pessoais',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome de Usuário',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Salvar Informações'),
                  ),

                  const Divider(height: 48),

                  // --- NOVA SEÇÃO PARA ALTERAR SENHA ---
                  const Text(
                    'Alterar Senha',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Nova Senha'),
                    obscureText: true,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 6) {
                        return 'A senha deve ter no mínimo 6 caracteres';
                      }
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
                      if (_passwordController.text.isNotEmpty &&
                          value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Alterar Senha'),
                  ),
                ],
              ),
            ),
    );
  }
}
