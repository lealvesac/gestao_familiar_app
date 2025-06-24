// ARQUIVO ATUALIZADO E CORRIGIDO: lib/widgets/dashboard_cards/family_members_panel.dart

import 'package:flutter/material.dart';

class FamilyMembersPanel extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  const FamilyMembersPanel({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Membros da Casa',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          if (members.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Carregando membros...'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  // --- CORREÇÃO AQUI ---
                  // Acessamos 'full_name' diretamente do objeto 'member',
                  // pois a nossa função RPC não aninha mais os dados dentro de 'profiles'.
                  final fullName = member['full_name'] ?? 'Sem nome';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      ),
                    ),
                    title: Text(fullName),
                    subtitle: Text(
                      member['role'] == 'administrador' ? 'Admin' : 'Membro',
                    ), // Mostra o papel do usuário
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
