// ARQUIVO FINAL E CORRIGIDO: lib/pages/family_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';

class FamilyPage extends StatefulWidget {
  final String houseId;
  final String currentUserRole;
  final String houseOwnerId; // <-- Novo parâmetro para saber quem é o dono

  const FamilyPage({
    super.key,
    required this.houseId,
    required this.currentUserRole,
    required this.houseOwnerId, // <-- Novo parâmetro
  });

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getMembers();
  }

  Future<void> _getMembers() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.rpc(
        'get_house_members',
        params: {'p_house_id': widget.houseId},
      );
      if (mounted) {
        setState(() {
          _members = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      // ... (lidar com erro)
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRole(String memberId, String newRole) async {
    try {
      await supabase.rpc(
        'update_member_role',
        params: {
          'member_profile_id': memberId,
          'target_house_id': widget.houseId,
          'new_role': newRole,
        },
      );
      // Atualiza a lista após a mudança para refletir na UI
      _getMembers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar papel: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _getMembers,
              child: ListView.builder(
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final profile = _members[index];
                  final fullName = profile['full_name'] ?? 'Nome não definido';
                  final userRole = profile['role'];
                 
                  final bool canManage =
                      widget.currentUserRole == 'administrador' &&
                      profile['id'] != widget.houseOwnerId;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(fullName),
                        const SizedBox(width: 8),
                        if (userRole == 'administrador')
                          Chip(
                            label: const Text('Admin'),
                            padding: EdgeInsets.zero,
                            labelStyle: const TextStyle(fontSize: 10),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    subtitle: Text(profile['username'] ?? 'Sem @usuário'),
                    trailing:
                        canManage // Usa a nova variável de lógica
                        ? PopupMenuButton<String>(
                            onSelected: (String newRole) {
                              _updateRole(profile['id'], newRole);
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  if (userRole == 'colaborador')
                                    const PopupMenuItem<String>(
                                      value: 'administrador',
                                      child: Text('Promover a Admin'),
                                    ),
                                  if (userRole == 'administrador')
                                    const PopupMenuItem<String>(
                                      value: 'colaborador',
                                      child: Text('Rebaixar a Colaborador'),
                                    ),
                                ],
                          )
                        : null,
                  );
                },
              ),
            ),
    );
  }
}
