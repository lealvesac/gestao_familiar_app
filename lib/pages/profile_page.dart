// ARQUIVO ATUALIZADO: lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _getProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      _fullNameController.text = (data['full_name'] as String?) ?? '';
      _userEmail = supabase.auth.currentUser!.email ?? '';
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar perfil: $error'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase
          .from('profiles')
          .update({'full_name': _fullNameController.text.trim()})
          .eq('id', userId);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $error'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate() || _passwordController.text.isEmpty)
      return;
    setState(() => _isLoading = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
        );
        _passwordController.clear();
        _confirmPasswordController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar senha: $error'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- NOVA FUNÇÃO PARA DESATIVAR A CONTA ---
  Future<void> _deactivateAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desativar Conta'),
        content: const Text(
          'Tem certeza que deseja desativar sua conta? Você será desconectado e não poderá mais acessar a casa. Esta ação pode ser revertida por um administrador.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Desativar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final userId = supabase.auth.currentUser!.id;
        // A lógica de desativação será implementada com Edge Functions para segurança.
        // Por enquanto, vamos apenas deslogar o usuário.
        // TODO: Chamar a Edge Function para desativar o usuário.

        await supabase.auth.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao desativar conta: $e'),
              backgroundColor: Colors.red,
            ),
          );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
                    initialValue: _userEmail,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    readOnly: true, // E-mail não pode ser alterado
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Salvar Informações'),
                  ),
                  const Divider(height: 48),
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
                      if (value != null && value.isNotEmpty && value.length < 6)
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
                      if (_passwordController.text.isNotEmpty &&
                          value != _passwordController.text)
                        return 'As senhas não coincidem';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Alterar Senha'),
                  ),

                  // --- NOVA SEÇÃO PARA DESATIVAR/EXCLUIR CONTA ---
                  const Divider(height: 48),
                  const Text(
                    'Gerenciamento da Conta',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _deactivateAccount,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Desativar minha conta'),
                  ),
                ],
              ),
            ),
    );
  }
}
