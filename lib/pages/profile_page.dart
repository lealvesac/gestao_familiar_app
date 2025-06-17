// NOVO ARQUIVO: lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Nome Completo'),
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
                  child: const Text('Salvar Alterações'),
                ),
              ],
            ),
    );
  }
}
