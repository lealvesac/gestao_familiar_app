// ARQUIVO ATUALIZADO: lib/pages/family_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';

class FamilyPage extends StatefulWidget {
  final String houseId;
  final String currentUserRole;
  final String houseOwnerId;

  const FamilyPage({
    super.key,
    required this.houseId,
    required this.currentUserRole,
    required this.houseOwnerId,
  });

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  late Future<List<Map<String, dynamic>>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();
  }

  Future<List<Map<String, dynamic>>> _fetchMembers() async {
    final response = await supabase.rpc(
      'get_house_members',
      params: {'p_house_id': widget.houseId},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  // --- NOVA FUNÇÃO PARA CHAMAR A EDGE FUNCTION ---
  Future<void> _manageUser(String targetUserId, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          action == 'reset-password' ? 'Redefinir Senha' : 'Desativar Usuário',
        ),
        content: Text(
          'Tem certeza que deseja executar esta ação para este usuário?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await supabase.functions.invoke(
          'user-management',
          body: {
            'targetUserId': targetUserId,
            'houseId': widget.houseId,
            'action': action,
          },
        );

        if (response.status != 200) {
          throw Exception(response.data['error'] ?? 'Erro desconhecido');
        }
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Ação concluída!'),
            ),
          );
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Membros da Família')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Erro ao carregar membros.'));
          }
          final members = snapshot.data!;
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final profile = member['profiles'];
              final memberId = profile['id'];
              final isOwner = memberId == widget.houseOwnerId;
              final canManage =
                  widget.currentUserRole == 'administrador' &&
                  !isOwner &&
                  memberId != currentUserId;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(profile['full_name']?[0] ?? '?'),
                ),
                title: Text(profile['full_name'] ?? 'Sem nome'),
                subtitle: Text(isOwner ? 'Dono da Casa' : member['role']),
                // --- NOVO MENU DE GERENCIAMENTO ---
                trailing: canManage
                    ? PopupMenuButton<String>(
                        onSelected: (value) => _manageUser(memberId, value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'reset-password',
                            child: Text('Redefinir Senha'),
                          ),
                          // const PopupMenuItem(value: 'deactivate-user', child: Text('Desativar Usuário')),
                        ],
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
